
function Get-KerberosTicketCache {
    <#
    .Synopsis
        Retrieves cached kerberose tickets
    .Description
        Dumps local kerberos ticket cache and returns object with results
    .Parameter SPN
        ServicePrincipalName to locate in the dumped tickets
    .Example
        "Slugify Conversion" | Convert-KFSlugify
    #>
    Param(
        [Parameter(Mandatory=$false)][String]$Principal,
        [Parameter(Mandatory)][ValidateSet("Machine","User")][String]$Context
    )

    # Dump cache
    # Split the "client" line on greater than symbol and trim results
    if($Context -eq "Machine"){
        $CacheContents = $(cmd /c "klist -li 0x3e7")
    } else {
        $CacheContents = $(cmd /c "klist")
    }
    $CacheContents = $CacheContents | % `
        {if($_ -like "*#*>*"){
            $_.Split(">")[1].Trim()
        }
        else {
            $_.Trim()
        }}

    $Tickets = @()

    for($x = 0; $x -lt $CacheContents.Count; $x++){
        $Line = $CacheContents[$x]

        if($CacheContents[$x] -match "(Client:)"){
            $Client = ($Line -split ":")[1].Trim() -Replace " ",""
        }
        elseif($CacheContents[$x] -match "(Server:)"){
            $Server = ($Line -split ":")[1].Trim() -Replace " ",""
        }
        elseif($CacheContents[$x] -match "(KerbTicket Encryption Type:)"){
            $Encryption = ($Line -split ":")[1].Trim() -Replace " ",""
        }
        elseif($CacheContents[$x] -match "(Kdc Called:)"){
            $KDC = ($Line -split ":")[1].Trim() -Replace " ",""
        }
        elseif($Line -eq "" -and ($Client -or $Server -or $Encryption -or $KDC)){
            if(-not [String]::IsNullOrEmpty($Server)){
                $Ticket = [PSCustomObject]@{
                    Client = $Client
                    Server = $Server
                    Encryption = $Encryption
                    KDC = $KDC
                }
                $Tickets += $Ticket
            }
        }
    }

    $LoggerFunctions.Debug("Dumped kerberos ticket cache: $($Tickets|Out-TableString)")

    if($Principal){
        $PolicyServerTicket = $Tickets | Where {$_.Server -eq $Principal}
        if($PolicyServerTicket){
            return $PolicyServerTicket
        }
        return $false
    }
    
    return $Tickets
} 

function Get-SecurityGroups {
    <#
    .Description
        Checks the certificate template autoenrollment permissions for an Active Directory object
    .Parameter Name
        Name of Active Directory object
    .Parameter WriteLog
        Add defined log entries to log
    .Example
        Get-SecurityGroups -Computer
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ParameterSetName="Computer")][switch]$Computer,
        [Parameter(Mandatory,ParameterSetName="User")][switch]$User
    )

    try {
        # get computer attributes
        $Searcher = [adsisearcher]::new()
        if($Computer){
            $Searcher.Filter = ("name=$($env:COMPUTERNAME)") 
            $ObjectComputer = $true
        }
        else {
            $Searcher.Filter = ("name=$($env:USERNAME)") 
            $ObjectPerson = $true
        }
        
        # Get object using filtered based on Computer or user switch
        $Object = $Searcher.FindOne().properties
        $FilterPrimaryGroup = Switch ($Object.primarygroupid){
            "513" {"(&(cn=Domain Users))"}
            "515" {"(&(cn=Domain Computers))"}
            "516" {"(&(cn=Domain Controllers))"}
        }

        $Searcher.Filter = $FilterPrimaryGroup
        $ObjectPrimaryGroup = $Searcher.FindOne().properties # get primary group dn
        
        # Create primgary group table and add to Security Groups object
        $ObjectSecurityGroups = @(
            [PSCustomObject]@{
                CommonName = $ObjectPrimaryGroup.cn[0]
                IdentityReference = "$Env:USERDOMAIN\$($ObjectPrimaryGroup.cn[0])"
                Distinguishedname = $ObjectPrimaryGroup.distinguishedname[0]
            }
        ) 
        # Create common name of each security group and add it to the Security Groups object
        $ObjectSecurityGroups += foreach($member in $Object.memberof){
            $CommonNameParsed = $Member.Split(',')[0].Split('=')[1]
            [PSCustomObject]@{
                CommonName = $CommonNameParsed
                IdentityReference = "$Env:USERDOMAIN\$CommonNameParsed"
                Distinguishedname = $Member
            }
        }

        $LoggerFunctions.Info("The primary security group of Windows Server $($Object.name) is: $($ObjectPrimaryGroup.distinguishedname)")
        $LoggerFunctions.Info("$($Object.name) is a member of the following security groups: $($ObjectSecurityGroups|ConvertTo-JSON)")
    }
    catch {
        $LoggerMain.Exception($_)
    }

    # dispose ASDI searcher no matter what
    finally {
        $Searcher.Dispose() 
    }

    return $ObjectSecurityGroups

}

function Get-TemplateEnrollmentPermissions {
    <#
    .Description
        Check if a security group is allowed to enroll and autoenroll a template
    .Parameter Template
        Certificate template name to check
    .Parameter Group
        Security group to gather the permissions for
    .Example
        Test-EnrollmentPermissions -Template Computer -Group Computer-Enrollment-Group
    #>
    param(
        [Parameter(Mandatory)][String]$Template,
        [Parameter(Mandatory)][String]$Group,
        [Parameter(Mandatory)][String]$ForestDn
    )    

    try {


        # Permission GUIDs for conditional matching
        $AutoenrollGuid = "a05b8cc2-17bc-4802-a710-e7c15ab866a2"
        $EnrollGuid = "0e10c968-78fb-11d2-90d4-00c04f79dc55"

        # Return object for updating during loop
        $TemplatePermissions = [PSCustomObject]@{
            Group = $Group
            Enroll = $False
            Autoenroll = $False
        }
    
        # Get template directory object
        $CertificateTemplates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ForestDn"
        $ProvidedTemplate = $CertificateTemplates.Children.where({$_.Name -eq $Template})

        # Loop through Access rules that only contain the name of the provided security group
        $ProvidedTemplate.ObjectSecurity.Access.where({$_.IdentityReference -match "($Group)"}).foreach{

            $LoggerFunctions.Debug("Object access rule: $($_|Out-TableString)")

            # Update autoenroll to true if "Autoenroll" GUID and "Allow (ExtendedRighe)" exist in the access rule 
            if($_.ObjectType.ToString() -eq $AutoenrollGuid -and $_.ActiveDirectoryRights -match "(ExtendedRight)"){
                $TemplatePermissions.AutoEnroll = $True
            }
            # Update enroll to true if "Enroll" GUID and "Allow (ExtendedRighe)" exist in the access rule 
            if($_.ObjectType.ToString() -eq $EnrollGuid -and $_.ActiveDirectoryRights -match "(ExtendedRight)"){
                $TemplatePermissions.Enroll = $True
            }
        }

        $LoggerFunctions.Debug("$Group enrollment permissions: $($TemplatePermissions|Out-TableString)")

        return $TemplatePermissions

    }
    catch {
        $LoggerMain.Exception($_)
    } 
}

function Get-ForestDomains {
    <#
    .Synopsis
        Gets all domains in forest
    .Description
        Creates an array of domains with a forest and returns a list of unique names.
    #>

    $Forest = Get-ADForest
    $LoggerFunctions.Debug("Active directory forest '$($Forest.RootDomain)' attributes: $($Forest|Out-ListString)")

    $DomainsObject = [PSCustomObject]@{
        Root = $Forest.RootDomain
        Domains = @($Forest.RootDomain) + @($Forest.Domains) | Get-Unique # Combine root domain and domains objects and filter out duplicates
    }
    $LoggerFunctions.Info("Active directory forest '$($Forest.RootDomain)'domains: $($DomainsObject|Out-TableString)")
    return $DomainsObject
}

function New-ServiceAccount {
    param(
        # Variables to register
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$true)][String]$Spn,
        [Parameter(Mandatory=$false)][String]$Password,
        [Parameter(Mandatory=$false)][String]$OrgUnit,
        [Parameter(Mandatory=$false)][Int]$Expiration=$ServiceAccountExpiration,
        [Parameter(Mandatory=$false)][Bool]$NoConfirm = $false
    )

    $LoggerFunctions.Debug("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|Out-TableString)")
    $LoggerFunctions.Info("Attemping to create service account '$Name'.")

    # Get password
    [System.Security.SecureString]$Password = Register-ServiceAccountPassword `
        -Account $Name `
        -Password $Password `
        -Secure

    # Get ad orginzation unit path
    $ServiceAccountOrgUnitPath = Register-ServiceAccountOrgUnit `
        -OrgUnit $OrgUnit
    
    # Construct attributes table for verification before creation
    $CreateObject = [PSCustomObject]@{
        Name = $Name
        Expiration = (Get-Date).AddDays($Expiration)
        ServicePrincipalName = $Spn
        Path = $ServiceAccountOrgUnitPath
    }

    Write-Host "`n[Review and Confirm]"

    if(-not $NoConfirm){
        Write-Host "Review the following attributes for account creation. Clear your session, or update your configuration file, if a cached value is incorrect: `n$($CreateObject|Out-ListString)`n" 
        $CreateConfirmation = Read-HostChoice `
            -Choices "create account","exit script" `
            -Default 0 `
            -ReturnBool
    }
    
    if($CreateConfirmation -or $NoConfirm){
        $ResultCreateServiceAccount = New-AdUser `
            -Name $CreateObject.Name `
            -AccountExpirationDate $CreateObject.Expiration `
            -AccountPassword $Password `
            -ServicePrincipalNames $Spn `
            -KerberosEncryptionType $ToolBoxConfig.KeytabEncryptionTypes `
            -Path $CreateObject.Path `
            -PasswordNeverExpires:$true `
            -Enabled:$true 

        $LoggerFunctions.Success("`nSuccessfully created service account '$Name'.")
        return $true
    } else {
        $LoggerFunctions.Info("User chose not to create service account '$Name'.")
    }
}

function New-Keytab {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][String]$Account,
        [Parameter(Mandatory)][String]$Principal,
        [Parameter(Mandatory)][String]$Password,
        [Parameter(Mandatory)][String]$Outfile,
        [Parameter(Mandatory=$false)][Switch]$ReturnContents
    )

    $Strings = @{
        FailedTargetDomain = "A Domain value was not specified, or the wrong one was provided, for service account {0} when attempting to create to the keytab. Refer to the log for more details." 
        FailedGeneral = "Failed to create keytab most likely due to a password that does not meet the complexity requires of the domain."
    }
    
    try {
        # Get domain
        $Domain = (Get-ADDomain -Current LocalComputer).DNSRoot
        $LoggerFunctions.Debug("Using $Domain as the DNS Root.")

        # Create keytab string
        $KeytabString = "ktpass -out $Outfile -mapuser $Account@$Domain -kvno 0 -princ $Principal -pass $Password -ptype KRB5_NT_PRINCIPAL -crypto AES256-SHA1 2>&1"
        $LoggerFunctions.Debug("keytab create string: $KeytabString")

        $KerberosKeytab = $(cmd /c $KeytabString) -split [environment]::NewLine
        foreach($Line in $KerberosKeytab){
            if($Line -match "(Aborted)"){
                $LoggerFunctions.Error($String.FailedGeneral)
                $LoggerFunctions.Error($Line)
                Write-Error $($Line) -ErrorAction Stop

            } elseif($Line -match "(ktpass:failed getting target domain for specified user)"){
                $ErrorString = $($Strings.FailedTargetDomain -f $Account)
                $LoggerFunctions.Error($ErrorString)
                Write-Error $($Strings.FailedTargetDomain -f $Account) -ErrorAction Stop

            } else {
                $LoggerFunctions.Debug($Line)
            }
        }
        if($KerberosKeytab -match "(Keytab version: 0x502)"){
            $LoggerFunctions.Info("Successfully created Keytab file and saved to $Outfile.")
            $LoggerFunctions.Console("Green")
            $Password = $null #empty clear text password after keytab creation
            return $true
        } 
    }
    catch {
        $LoggerFunctions.Exception($_)
        throw
    }
}

function New-Krb5Conf {
    param(
        [Parameter(Mandatory)][string]$OutFile,
        [Parameter(Mandatory)][string]$Forest,
        [Parameter(Mandatory=$false)][string]$KDC,
        [Parameter(Mandatory=$false)][Switch]$ReturnContents
    )

    $Forest = $Forest.ToUpper()
    $lowerForest = $Forest.ToLower()
    if([string]::IsNullOrEmpty($KDC)){
        $KDC = $Domain
    }
    try {

        $Krb5Conf = (
            "[libdefaults]",
            "default_realm = $Forest",
            "default_tkt_enctypes = aes256-cts-hmac-sha1-96",
            "default_tgs_enctypes = aes256-cts-hmac-sha1-96",
            "permitted_enctypes = aes256-cts-hmac-sha1-96",

            "`n[realms]",
            "$Forest = {",
                "`tkdc = $KDC",
                "`tdefault_domain = $Forest",
            "}",

            "`n[domain_realm]",
            ".$lowerForest = $Forest"
        ) -join "`r`n"

        $LoggerFunctions.Debug(("Krb5Conf file: `n$($Krb5Conf)").Trim())
        Write-Output $Krb5Conf | Out-File -FilePath $OutFile
        if(Test-Path $OutFile){
            $LoggerFunctions.Info("Successfully created Krb5 conf and saved to $Outfile.")
            $LoggerFunctions.Console("Green")
            if($ReturnContents){
                Write-Host "`n$($Krb5Conf)" `
                    -NoNewLine `
                    -ForegroundColor Green
            } else {
                return $True
            }
        }
        else {
            throw "Failed to create Krb5 conf file."
        }
    }
    catch {
        $LoggerFunctions.Exception($_)
        $LoggerFunctions.Error("Failed to create Krb5 conf file.")
    }
}

function New-TemplateOid {
    param(
        [Parameter(Mandatory)][String]$DomainController,
        [Parameter(Mandatory)][String]$Context
    )

    try {
        do {
            $Part1 = Get-Random -Minimum 10000000 -Maximum 99999999
            $Part2 = Get-Random -Minimum 10000000 -Maximum 99999999
            $Part3 = ""
            $Hex = '0123456789ABCDEF'
            for($i=1;$i -le 32;$i++) {
                $Part3 += $Hex.Substring((Get-Random -Minimum 0 -Maximum 16),1)
            }
            $OID_Forest = Get-ADObject `
                -Identity "CN=OID,CN=Public Key Services,CN=Services,$Context" `
                -Properties msPKI-Cert-Template-OID | Select-Object -ExpandProperty msPKI-Cert-Template-OID
            $msPKICertTemplateOID = "$OID_Forest.$Part1.$Part2"
            $Name = "$Part2.$Part3"
        } 
        until (
            Test-UniqueOid `
                -Name $Name `
                -TemplateOID $msPKICertTemplateOID `
                -DomainController $DomainController `
                -Context $Context
        )
        $LoggerFunctions.Debug("Created new template OID $($msPKICertTemplateOID)")
        return @{TemplateOID  = $msPKICertTemplateOID;Name = $Name}

    }
    catch {
        $LoggerFunctions.Exception($_)
    }
}

function Out-Keytab {
    <#
    .Synopsis
        Dumps a keytab file
    .Description
        Dumps keytab file contents to the console.
    .Example
        Dump-Keytab -Path C:\Users\Administrator\ra-service.keytab
    #>
    param (
        [Parameter(Mandatory)][String]$Path
    )

    $LoggerFunctions.Debug(("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|Out-TableString)").Trim())

    try {

        # test provided path and catch exception if path is invalud
        Test-Path $Path -ErrorAction Stop | Out-Null

        # Initialize keytab content object
        $KeytabTable = @()

        # Dump keytab to error log stream
        # Required to keep contents from printing to console
        $KeytabDump = ktpass -in $Path 2>&1

        $KeytabContents = $KeytabDump -split ([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)
        $LoggerFunctions.Info("Dumping $Path contents...")

        foreach($Line in $KeytabContents){
            if($Line -like "*keysize*"){
                $LoggerFunctions.Debug($Line)

                # Substring encryption type
                # Get index of ETYPE, add 5 index spaces to trim 'etype' from the beginning, assume the next 5 indexes are the encryption type (with whitespace buffer).
                # Trim to remove whitespace buffer
                $Type = $Line.Substring($Line.LastIndexOf("etype")+5).Substring(0,5).Trim()

                # Substring principal name
                # Get index HTTP by trimming beginning and split on first space following principal to isolate string.
                # Trim to remove extra whitespaces
                $Principal = $Line.Substring($Line.IndexOf("HTTP")).Split('')[0].Trim()

                # Substring principal name
                # Get index VNO by getting string value between etype, then getting index value of 'vno' plus 3 index spaces.
                # Trim to remove extra whitespaces
                $Version = $Line.Substring(0,$Line.IndexOf("etype")).Substring($Line.IndexOf("vno")+3).Trim()

                # Fail if any of the substrings failed to parse
                if($Type -notin $KerberosEncryptionTypes.Type){
                    $ErrorMessage = "The parsed encryption key does not match one of the listed values hardcoded in the variables.ps1."
                    $LoggerFunctions.Error($ErrorMessage); Write-Error $ErrorMessage -ErrorAction Stop
                    
                } elseif([String]::IsNullOrEmpty($Principal) -or [String]::IsNullOrEmpty($Version)){
                    $ErrorMessage = "One of the following required values failed to parse correctly and is empty. Type='$Type', Principal='$Principal', Version='$Version'."
                    $LoggerFunctions.Error($ErrorMessage); Write-Error $ErrorMessage -ErrorAction Stop

                } else {
                    # store encryption key name in table
                    $EncKeyHashTable = [PSCustomObject]@{
                        Keys = ($KerberosEncryptionTypes.where({$Type -eq $_.Type})).Name
                        Principal = $Principal
                        Version = $Version
                    }
                }
                # add each hashtable to main array for return
                $KeytabTable += $EncKeyHashTable
            }
        }
    } catch {
        $LoggerFunctions.Exception($_)
        throw
    }
    
    $LoggerFunctions.Info("The keytab contains the following encryption keys: $($KeytabTable|Out-TableString)")
    return $KeytabTable
}

function Out-Krb5Conf {
    param(
        [Parameter(Mandatory)][String]$Path
    )

    $LoggerFunctions.Debug(("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|Out-TableString)").Trim())

    $Contents = [PSCustomObject]@{
        DefaultDomain = ""
        PermittedKeyTypes = ""
        Realms = @()
        DomainRealms = @() 
    }

    try {

        $Domain = (Get-ADDomain -Current LocalComputer).DNSRoot
        $Krb5Item = Get-Content $Path
        $LoggerFunctions.Info("Dumping $Path contents...")
        $LoggerFunctions.Debug("${Krb5}: `n$($Krb5Item|Out-String)")
        $Kdcs = @()

        for ($x = 0; $x -lt $Krb5Item.Count; $x++){
            $Line = $Krb5Item[$x]

            # Default Realm
            if($Line -match "(default_realm)+"){
                $Contents.DefaultDomain = $Line.Split("=").Trim()[1] 
            }
            
            # Permitted encryption types
            if($Line -match "(permitted_enctypes)+"){
                if($Line -like "*aes256-cts-hmac-sha1-96*"){
                    $Contents.PermittedKeyTypes = $Line.Split("=").Trim()[1] 
                }
            }

            # Realms
            if($Line -eq "[realms]"){
                $Realm = [PSCustomObject]@{Name = ""; Kdcs = @(); Default = ""}
                while($Line.Trim() -ne "}"){
                    if($Line.Split('=')[0].Trim() -like $Domain){
                        $Realm.Name = $Line.Split('=')[0].Trim()
                    }
                    if($Line.Trim() -match "(kdc)+"){
                        $Realm.Kdcs += $Line.Split('=')[1].Trim()
                    }
                    if($Line.Trim() -match "(default_domain)+"){
                        $Realm.Default += $Line.Split('=')[1].Trim()
                    }
                    $Line = $Krb5Item[$x++] 
                }
                $Contents.Realms += $Realm
            }

            # Default Domains
            if($Line -eq "[domain_realm]"){
                while($Line.Count -ne 0){
                    if($Line.Split("=")[1].Length){
                        $Contents.DomainRealms += $Line
                    }
                    $Line = $Krb5Item[$x++]
                }
            }
            continue
        }
    } catch {
        $LoggerFunctions.Exception($_)
    }

    $LoggerFunctions.Info("The krb5 conf contains the following values: $($Contents|Out-TableString)")

    return $Contents
}

function Test-ImportedModule {
    <#
    .Synopsis
        Checks if a module is imported
    .Description
        Gets modules imported in the current session and checks if the provided module name is listed.
    .Parameter Module
        Modules to check
    .Example
        Test-ImportedModule DnsClient
    #>
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline)][String]$Module
    )
    $ImportedModules = Get-Module
    $LoggerFunctions.Debug("Installed modules: $($ImportedModules|Out-ListString)")
    
    process{
        if($ImportedModules.Name -notcontains $Module){
            return $false
        } else {
            return $true
        }
    }
}

function Test-ParentDomain {
    <#
    .Synopsis
        Tests if current domain is Parent domain
    .Description
        Tests if current domain is Parent domain and outputs boolean value if DnsRoot and ParentDomain match
    .Example
        Test-ParentDomain
    #>
    $CurrentDomain = (Get-ADDomain -Current LocalComputer)
    if($CurrentDomain.DnsRoot -eq $CurrentDomain.ParentDomain){
        return $True
    } else {
        return $False
    }
}

function Test-ServicePrincipalName {
    <#
    .Description
        Find all Service Principal Names in Active Directory and check if it matches the provided name
    .Parameter Name
        Service Principal Name to check. Do not include the HTTP prefix.
    .Outputs
        None. Empty result if none found
        System.String. Account name configured with provided Service Principal Name
    .Example
        Test-ServicePrincipalNamme policy-server.local
    
    #>
    param(
        [Parameter(Mandatory)][String]$Name
    ) 

    $LoggerFunctions.Debug("$($Strings.Search -f ("Service Prinipcal Name", $Name))")

    $Searcher = [adsisearcher]::new()
    $Searcher.filter = "(servicePrincipalName=*)"
    $SearchResults = $Searcher.Findall()

    # Dispose of searcher
    $Searcher.Dispose() 

    # Loop results
    foreach($Result in $SearchResults){
        $Entry = $Result.GetDirectoryEntry()
        if($Entry.servicePrincipalName -eq $Name){
            $LoggerFunctions.Info(
                "$($Strings.Found -f ("Service Prinipcal Name", $Name))",
                "'$($Entry.Name)' is configured with '$Name'."
            )
            return $Entry.Name
        }
    }
    $LoggerFunctions.Info("$($Strings.Available -f $Name)")
    return # Return empty result if none found
}

function Test-UniqueOid {
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$TemplateOID,
        [Parameter(Mandatory)][String]$DomainController,
        [Parameter(Mandatory)][String]$Context
    )

    try {
        $Search = Get-ADObject `
            -Server $DomainController `
            -SearchBase "CN=OID,CN=Public Key Services,CN=Services,$Context" `
            -Filter {cn -eq $Name -and msPKI-Cert-Template-OID -eq $TemplateOID}
        if($Search){ return $false }
        else { return $true }
    }
    catch {
        Write-Host "$($MyInvocation.InvocationName): $_" -ForegroundColor Red
        $LoggerFunctions.Exception($_)
    }
}

function Test-RemoteEndpoint {
     <#
    .Synopsis
        Test secure connectivity with remote host
    .Description
        Invoke web request with remote host to determine if it is accessible over 443
    .Parameter Uri
        Fully qualified sever name
    .Parameter Timeout
        Amount of milliseconds before the request times out and reports false.
    .Example
        Test-RemoteHost -Hostname policy-server.local
    #>
    param(
        [Parameter(Mandatory=$true)][Uri]$Uri,
        [Parameter(Mandatory=$false)][Int]$Timeout=500
	)

    $LoggerFunctions.Debug("Testing connectivity with endpoint '$($Uri.Host)' over port: $($Uri.Port)")
		
    try {
        $RequestCallback = $State = $Null
        $Client = New-Object System.Net.Sockets.TcpClient
        $BeginConnect = $Client.BeginConnect($Uri.Host,$Uri.Port,$RequestCallback,$State)
        Start-Sleep -milliseconds $Timeout

        if($Client.Connected){
            $Client.Close()
            $LoggerFunctions.Info("'$($Uri.Host)' is reachable over port $($Uri.Port).")
            return $true
        }
        else {
            return $false
        }
    } catch {
        $LoggerFunctions.Exception($_)
    }
}

function Test-WindowsFeature {
    <#
    .Synopsis
        Checks if a windows feature is installed
    .Description
        Checks if a windows feature is installed on the machine the toolkit is being run on.
    .Parameter Feature
        Feature to check
    .Example
        Test-WindowsFeature RSAT-ADCS-Mgmt
    #>
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline)][String]$Feature
    )

    process {
        $InstalledFeature = Get-WindowsFeature -Name $Feature | Select Name,DisplayName,Description,Installed,InstallState
        if($InstalledFeature){
            $LoggerFunctions.Debug("Retrieved windows feature: $($InstalledFeature|Out-ListString)")
            return ($InstalledFeature.Installed)
        } else {
            $LoggerFunctions.Error("Provided windows feature '$Feature' does not exist.")
        }
    }
}
