
# Initialize logger
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main, $ToolBoxConfig.LogLevel)

function Assert-DesktopMode {
    Param (
        [Parameter(Mandatory=$false)][Switch]$LoadAssembly
    )
    $NonInteractive = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonI*' }
    $Windows = ([Environment]::OSVersion.Platform -like "Win*")
    if ([Environment]::UserInteractive -and $Windows -and -not $NonInteractive) {
        $LoggerMain.Info("Powershell is running in Interactive mode. Message boxes are enabled.")

        if($LoadAssembly){
            [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 
            $LoggerMain.Info("Loaded System.Reflection.Assembly: System.Windows.Forms")

        }
        return $true

    }
    $LoggerMain.Info("Powershell is running in non-Interactive mode. Message boxes are disabled.")
    return $false
} 

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

    $LoggerFunctions.Logger = "KF.Toolkit.Function.GetKerberosTicketCache"

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
        Get-SecurityGroups
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ParameterSetName="Computer")][switch]$Computer,
        [Parameter(Mandatory,ParameterSetName="User")][switch]$User
    )

    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.GetSecurityGroups"

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

        # Set Logger
        $LoggerFunctions.Logger = "MSAE.Toolkit.Function.GetTemplateEnrollmentPermissions"

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

function New-ServiceAccount {
    param(
        # Variables to register
        [Parameter(Mandatory=$true)][String]$Name,
        [Parameter(Mandatory=$true)][String]$Spn,
        [Parameter(Mandatory=$false)][String]$Password,
        [Parameter(Mandatory=$false)][String]$OrgUnit,
        [Parameter(Mandatory=$false)][Int]$Expiration=$ServiceAccountExpiration,
        [Parameter(Mandatory=$false)][Bool]$NoConfirm = $false,

        # Messages 
        [Parameter(Mandatory=$false)][String]$OrgUnitMessage = "Enter the full path, common name, or a partial common name, of the AD OU to create {0} in",
        [Parameter(Mandatory=$false)][String]$OrgUnitMessageColor = "Gray"
    )

    $LoggerNewServiceAccount = $LoggerFunctions
    $LoggerNewServiceAccount.Logger = "KF.Toolkit.Function.NewServiceAccount"

    $PathMessage = "Multiple organizational units matching the '{0}' query were returned. Select one of the following choices:"
    $NonExistentMessage = "Org unit '{0}' does not match any existing AD OU. Please provide another org unit"

    $LoggerNewServiceAccount.Info("Attemping to create service account '$Name'.")

    # Get password
    [System.Security.SecureString]$Password = Register-ServiceAccountPassword `
        -Account $Name `
        -Password $Password `
        -Secure
    
    # Get service account orginization unit path
    do {
        if([String]::IsNullOrEmpty($OrgUnit)){
            $OrgUnit = Read-HostPrompt `
                -Message $($OrgUnitMessage -f $Name) `
                -Color $OrgUnitMessageColor
        }

        # search organization units based on provided search string
        #$ResultsServiceAccountOrgUnitSearch = (Get-ADOrganizationalUnit -Filter "Name -like '*$($OrgUnit)*'").DistinguishedName
        $LoggerNewServiceAccount.Info("Searching for organization units like '$OrgUnit'.")
        $ResultsServiceAccountOrgUnitSearch = (Get-ADOrganizationalUnit -Filter "Name -like '*$($OrgUnit)*'").DistinguishedName

        # multiple results found
        if($ResultsServiceAccountOrgUnitSearch.Count -gt 1){
            $ServiceAccountOrgUnitPath = Read-PromptSelection `
                -Message "$($PathMessage -f $OrgUnit)" `
                -Selections $ResultsServiceAccountOrgUnitSearch
        
        # no results found
        } elseif(-not $ResultsServiceAccountOrgUnitSearch.Count) {
            $OrgUnitMessage = "$($NonExistentMessage -f $OrgUnit)" ; $OrgUnitMessageColor = "Yellow"
            $LoggerFunctions.Error($Message)
            $OrgUnit = $null

        } else {
            $ServiceAccountOrgUnitPath = $ResultsServiceAccountOrgUnitSearch
        }

    } until ($OrgUnit)

    # Construct attributes table for verification before creation
    $CreateObject = [PSCustomObject]@{
        Name = $Name
        Expiration = (Get-Date).AddDays($Expiration)
        ServicePrincipalName = $Spn
        Path = $ServiceAccountOrgUnitPath
    }

    if(-not $NoConfirm){
        $LoggerNewServiceAccount.Info("Account Attributes: `n$($CreateObject|Out-TableString)"); $LoggerNewServiceAccount.Console()
        $CreateConfirmation = Read-HostChoice `
            -Message "`nReview the above attributes for account creation. Clear your session, or update your configuration file, if a cached value is incorrect." `
            -Default 1 `
            -ReturnBool
    }
    
    if($CreateConfirmation -or $NoConfirm -eq $false){

        $ResultCreateServiceAccount = New-AdUser `
            -Name $CreateObject.Name `
            -AccountExpirationDate $CreateObject.Expiration `
            -AccountPassword $Password `
            -ServicePrincipalNames $Spn `
            -KerberosEncryptionType $ToolBoxConfig.KeytabEncryptionTypes `
            -Path $CreateObject.Path `
            -PasswordNeverExpires:$true `
            -Enabled:$true 

        $LoggerNewServiceAccount.Success("Successfully created service account '$Name'.")
        return $true
    }      
}

function New-CertificateTemplate {
    param(
        [Parameter(Mandatory)][String]$DisplayName,
        [Parameter(Mandatory)][String]$DomainController,
        [Parameter(Mandatory)][String]$ForestDn,
        [Parameter(Mandatory=$false)][String]$Group,
        [Parameter(Mandatory=$false)][String]$Duplicate,
        [Parameter(Mandatory=$false)][switch]$Computer,
        [Parameter(Mandatory=$false)][switch]$User
    )

    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.NewCertificateTemplate"

    $BaseTemplateComputer = "Computer"
    $BaseTemplateUser = "User"

    try {

        # throw error if duplicate template name not provided and 
        if(-not $Duplicate){
            if(-not ($Computer -or $User)){
                throw "If not duplicating a template, the Computer or the User switch is required."
            }
            elseif ($Computer -and $User) {
                throw "The Computer and User switches cannot be used at the same time."
            }
        }
        
        # Build Certificate Templates object
        $ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
        $TemplateContainerDn = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
        $TemplatePath = [ADSI]"LDAP://$TemplateContainerDn"
        # Get certificate template attributes if duplicating existing template
        if($Duplicate){
            $LoggerFunctions.Debug("$($Duplicate|ConvertTo-JSON)")
            $DuplicateTemplate = $TemplatePath.Children.where({$_.displayName -eq $Duplicate})
            
        }
        else {

            # if no duplicate set use default machine and user
            if($Computer){
                $DuplicateTemplate = $TemplatePath.Children.where({ $_.displayName -eq $BaseTemplateComputer})
            }
            else { 
                $DuplicateTemplate = $TemplatePath.Children.where({ $_.displayName -eq $BaseTemplateUser})
            }
            $LoggerFunctions.Debug("Duplicating base template: $($DuplicateTemplate.Name)")
            
        }
        $LoggerFunctions.Debug(("$($DuplicateTemplate.Name) attributes: $(($DuplicateTemplate|Select *)|Out-String)").Trim())

        # Create Template and populate initial values
        $CommonName = $DisplayName.Replace(" ","") # Remove whitespaces from name
        $NewTemplate = $TemplatePath.Create("pKICertificateTemplate", "CN=$CommonName")
        
        $NewOid = New-TemplateOID `
            -DomainController $DomainController `
            -Context $ConfigContext

        $NewTemplate.put("distinguishedName","CN=$CommonName,$TemplateContainerDn")
        $NewTemplate.put("displayName","$DisplayName")
        $NewTemplate.put("msPKI-Cert-Template-OID","$($NewOid.TemplateOID)")
        $NewTemplate.put("flags","$($DuplicateTemplate.flags)")
        $NewTemplate.put("revision","100")
        $NewTemplate.put("pKIDefaultKeySpec","$($DuplicateTemplate.pKIDefaultKeySpec)")

        [void]$NewTemplate.SetInfo()
        
        # create properties with default values
        if($DuplicateTemplate.pKICriticalExtensions){ 
            $NewTemplate.pKICriticalExtensions = $DuplicateTemplate.pKICriticalExtensions 
        }
        if($DuplicateTemplate.pKIDefaultCSPs){ 
            $NewTemplate.pKIDefaultCSPs = $DuplicateTemplate.pKIDefaultCSPs 
        }
        if($DuplicateTemplate.pKIMaxIssuingDepth){ 
            $NewTemplate.pKIMaxIssuingDepth = $DuplicateTemplate.pKIMaxIssuingDepth 
        }
        if($DuplicateTemplate.pKIExtendedKeyUsage){ 
            $NewTemplate.pKIExtendedKeyUsage = $DuplicateTemplate.pKIExtendedKeyUsage 
        }
        if($DuplicateTemplate.'msPKI-Certificate-Application-Policy'){ 
            $NewTemplate.'msPKI-Certificate-Application-Policy' = $DuplicateTemplate.'msPKI-Certificate-Application-Policy' 
        }
        if($DuplicateTemplate.'msPKI-Certificate-Name-Flag'){ 
            $NewTemplate.'msPKI-Certificate-Name-Flag' = $DuplicateTemplate.'msPKI-Certificate-Name-Flag' 
        }
        if($DuplicateTemplate.'msPKI-Enrollment-Flag'){ 
            $NewTemplate.'msPKI-Enrollment-Flag' = $DuplicateTemplate.'msPKI-Enrollment-Flag'
        }
        $NewTemplate.'msPKI-Minimal-Key-Size' = $DuplicateTemplate.'msPKI-Minimal-Key-Size'
        $NewTemplate.'msPKI-Private-Key-Flag' = $DuplicateTemplate.'msPKI-Private-Key-Flag'
        $NewTemplate.'msPKI-Template-Minor-Revision' = $DuplicateTemplate.'msPKI-Template-Minor-Revision'

        $NewTemplate.put('msPKI-Template-Schema-Version', "4")
        $NewTemplate.'msPKI-RA-Signature' = $DuplicateTemplate.'msPKI-RA-Signature'
        $NewTemplate.SetInfo()

        $DuplicateByteProps = $TemplatePath.Children.where({ $_.displayName -eq $DuplicateTemplate.DisplayName}) | Select-Object pKIKeyUsage,pKIExpirationPeriod,pKIOverlapPeriod

        # update properties values thats cant be set with put
        $NewTemplate.pKIKeyUsage = $DuplicateByteProps.pKIKeyUsage
        $NewTemplate.pKIExpirationPeriod = $DuplicateByteProps.pKIExpirationPeriod
        $NewTemplate.pKIOverlapPeriod = $DuplicateByteProps.pKIOverlapPeriod
        $NewTemplate.SetInfo()

        $LoggerFunctions.Info($StringsObject.Created -f ("certificate template", $DisplayName))
        $LoggerFunctions.Console("Green")
        return $true

    }
    catch [System.Management.Automation.MethodInvocationException] {
        if($_ -match "(The object already exists)"){
            $LoggerFunctions.Info($Strings.AlreadyExists -f $DisplayName, $True)
            return $false
        }
    }
    catch {
        $LoggerFunctions.Exception($_)
        throw $Strings.GeneralException
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

    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.NewKeytab"
    $LoggerFunctions.Debug(
        ("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|ConvertTo-JSON)").Trim()
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

        $Keytab = $(cmd /c $KeytabString) -split [environment]::NewLine
        foreach($Line in $Keytab){
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
        if($Keytab -match "(Keytab version: 0x502)"){
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

    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.NewKrb5Conf"
    $LoggerFunctions.Debug(
        ("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|ConvertTo-JSON)").Trim()
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
        $LoggerFunctions.Info
    }
    catch {
        $LoggerFunctions.Exception($_)
        $LoggerFunctions.Error(
            "Failed to create Krb5 conf file."
        )
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
        Write-Host "$($MyInvocation.InvocationName): $_" -ForegroundColor Red
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

    $LoggerOutKeytab = $LoggerFunctions
    $LoggerOutKeytab.Logger = "MSAE.Toolkit.Function.OutKeytab"
    $LoggerOutKeytab.Debug(("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|Out-TableString)").Trim())

    try {

        # test provided path and catch exception if path is invalud
        Test-Path $Path -ErrorAction Stop | Out-Null

        # Initialize keytab content object
        $KeytabTable = @()

        # Dump keytab to error log stream
        # Required to keep contents from printing to console
        $KeytabDump = ktpass -in $Path 2>&1

        $KeytabContents = $KeytabDump -split ([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)
        $LoggerOutKeytab.Info("Dumping $Path contents...")

        foreach($Line in $KeytabContents){
            if($Line -like "*keysize*"){
                $LoggerOutKeytab.Debug($Line)

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
                    $LoggerOutKeytab.Error($ErrorMessage); Write-Error $ErrorMessage -ErrorAction Stop
                    
                } elseif([String]::IsNullOrEmpty($Principal) -or [String]::IsNullOrEmpty($Version)){
                    $ErrorMessage = "One of the following required values failed to parse correctly and is empty. Type='$Type', Principal='$Principal', Version='$Version'."
                    $LoggerOutKeytab.Error($ErrorMessage); Write-Error $ErrorMessage -ErrorAction Stop

                } else {
                    # store encryption key name in table
                    $EncKeyHashTable = [PSCustomObject]@{
                        "Key Type" = ($KerberosEncryptionTypes.where({$Type -eq $_.Type})).Name
                        Principal = $Principal
                        Version = $Version
                    }
                }
                # add each hashtable to main array for return
                $KeytabTable += $EncKeyHashTable
            }
        }
    } catch {
        $LoggerOutKeytab.Exception($_)
        throw
    }
    
    $LoggerOutKeytab.Success("The keytab contains the following encryption keys: $($KeytabTable|Out-TableString)")
    return $KeytabTable
}

function Set-AutoEnrollmentPermissions {
    param(
        [Parameter(Mandatory)][String]$Template,
        [Parameter(Mandatory)][String]$Group,
        [Parameter(Mandatory)][String]$ForestDn
    )

    $LoggerSetAutoEnrollmentPermissions = $LoggerFunctions
    $LoggerSetAutoEnrollmentPermissions.Logger = "MSAE.Toolkit.Function.SetCertificateTemplatePermissions"
    try {

        
        # Get short name of current AD domain
        $NetBiosName = (Get-ADDomain -Current LocalComputer).NetBIOSName

        # Retrieve template
        $ParentDomainDn = (Get-ADRootDSE).rootDomainNamingContext
        $CertificateTemplates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ParentDomainDn"
        $TemplateObject = $CertificateTemplates.Children.where({$_.displayName -eq $Template})

        # set autoenroll permissions
        $ActiveDirectoryObject = New-Object System.Security.Principal.NTAccount($NetBiosName,$Group)
        $LoggerSetAutoEnrollmentPermissions.Debug("Created NTAccount object for: $(($ActiveDirectoryObject).Value)")
        $Identity = $ActiveDirectoryObject.Translate([System.Security.Principal.SecurityIdentifier])
        $ObjectType = "a05b8cc2-17bc-4802-a710-e7c15ab866a2"
        $Rights = "ExtendedRight"
        $Type = "Allow"

        # create access rule
        $ActiveDirectoryAccessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity,$Rights,$Type)
        $LoggerSetAutoEnrollmentPermissions.Debug("Created access rule for $($ActiveDirectoryObject): $($ActiveDirectoryAccessRule|Out-TableString)")
        $TemplateObject.ObjectSecurity.SetAccessRule($ActiveDirectoryAccessRule)
        $TemplateObject.CommitChanges()

        $LoggerSetAutoEnrollmentPermissions.Debug("Committed ACL changes on '$Template'.")
        
        # verify permissions were set
        $ResultVerification = Test-AutoEnrollmentPermissions `
            -Template $Template `
            -Group $Group `
            -ForestDn $ForestDn

        if($ResultVerification){
            $LoggerSetAutoEnrollmentPermissions.Success("Successfully granted $TemplateComputerGroup autoenrollment permissions on $TemplateComputer")
        } else {
            $LoggerSetAutoEnrollmentPermissions.Error(
                "Failed to grant autoenrollment permission on '$TemplateComputer' for security group: $TemplateComputerGroup. If the template was just created and '$($ToolBoxConfig.ParentDomain)' is a parent domain, this is most likely do to replication.")
            $LoggerSetAutoEnrollmentPermissions.Console("Red")
        }

    } catch {
        $LoggerSetAutoEnrollmentPermissions.Exception($_)
        throw
    }
}

function Test-AutoEnrollmentPermissions {
    param(
        [Parameter(Mandatory)][String]$Template,
        [Parameter(Mandatory)][String]$Group,
        [Parameter(Mandatory)][String]$ForestDn
    )    

    $LoggerTestAutoEnrollPermissions = $LoggerFunctions
    $LoggerTestAutoEnrollPermissions.Logger = "MSAE.Toolkit.Function.TestAutoEnrollmentPermissions"

    # Permission GUIDs for conditional matching
    $Guids = @(
        "a05b8cc2-17bc-4802-a710-e7c15ab866a2",
        "00000000-0000-0000-0000-000000000000"
    )

    # Get template directory object
    $ConfigContext = (Get-ADRootDSE).rootDomainNamingContext
    $CertificateTemplates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ConfigContext"
    $ProvidedTemplate = $CertificateTemplates.Children.where({$_.Name -eq $Template})

    $LoggerTestAutoEnrollPermissions.Debug($($ProvidedTemplate.ObjectSecurity.Access|Out-TableString))

    # Loop through Access rules that only contain the name of the provided security group
    $ProvidedTemplate.ObjectSecurity.Access.where({$_.IdentityReference -match "($Group)"}).foreach{

        # Return true if autoenrollment and allow permissions found
        if($_.ObjectType.ToString() -in $Guids -and $_.ActiveDirectoryRights -match "(ExtendedRight)"){ 
            $LoggerTestAutoEnrollPermissions.Info("$Group is configured for autoenrollment on $Template")
            return $true
        }
    }
}

function Test-CertificateTemplate {
    param(
        [Parameter(Mandatory)][String]$DisplayName
    )

    $ConfigContext = (Get-ADRootDSE).rootDomainNamingContext
    $CertificateTempates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ConfigContext"
    $Template = $CertificateTempates.Children.where({$_.displayName -eq $DisplayName})
    if($Template){
        return $true
    } else {
        return $false
    }
}

function Test-ElevatedPowerShell {
    $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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

    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.TestServicePrincipalName"
    $LoggerFunctions.Debug("$($StringsObject.Search -f ("Service Prinipcal Name", $Name))")

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
                "$($StringsObject.Found -f ("Service Prinipcal Name", $Name))",
                "'$($Entry.Name)' is configured with '$Name'."
            )
            return $Entry.Name
        }
    }
    $LoggerFunctions.Info("$($StringsObject.Available -f $Name)")
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

function Test-RemoteHost {
     <#
    .Synopsis
        Test secure connectivity with remote host
    .Description
        Invoke web request with remote host to determine if it is accessible over 443
    .Parameter Hostname
        Fully qualified sever name
    .Parameter Port
        Port for connectivty test
    .Parameter Timeout
        Amount of milliseconds before the request times out and reports false.
    .Example
        Test-RemoteHost -Hostname policy-server.local
    #>
    param(
        [Parameter(Mandatory)][String]$Hostname,
        [Parameter(Mandatory=$false)][Switch]$ResolveDns,
        [Parameter(Mandatory=$false)][Int]$Port=443,
        [Parameter(Mandatory=$false)][Int]$Timeout=500
	)

    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.TestRemoteHost"
    $LoggerFunctions.Debug("Testing connectivity with endpoint '$Hostname' over port: $Port")
		
    try {
        if($ResolveDns){
            Get-Command 'Resolve-DnsName' -ErrorAction Stop | Out-Null
            $TestDns = Resolve-DnsName $Hostname -ErrorAction Stop
            $LoggerFunctions.Debug("$($Hostname.ToUpper()) name resolution test results: $($TestDns|Out-TableString)")
        }
        $RequestCallback = $State = $Null
        $Client = New-Object System.Net.Sockets.TcpClient
        $BeginConnect = $Client.BeginConnect($Hostname,$Port,$RequestCallback,$State)
        Start-Sleep -milliseconds $Timeout
        if($Client.Connected){
            $Client.Close()
            $LoggerFunctions.Info("'$Hostname' is reachable over port $Port.")
            return $true
        }
        else {
            Write-Error -ErrorAction Stop `
                -Message "Policy server endpoint 'https://$($PolicyServerAttributes.Fqdn)' is unreachable. Verify the route is open and try again." `
                -Category ResourceUnavailable
        }
    } catch {
        $LoggerFunctions.Exception($_)
        Write-Host $_ -ForegroundColor Red
    }
}

function Confirm-RequiredParameters {
    param(
        [Parameter(Mandatory)][String[]]$RequiredParameters,
        [Parameter(Mandatory)][Hashtable]$BoundParameters
    )

    if("NonInteractive" -in $BoundParameters.Keys){
        foreach($Param in $RequiredParameters){
            if($Param -notin $BoundParameters.Keys){
                Write-Error "The $Param parameter is required for the 'cep-config' tool when using Non-Interactive mode."
            } else {
                # Create pairing with parameter and value
                #Write-Host"$Param=$(($BoundParameters.GetEnumerator()|Where-Object{$_.Key -eq $Param}).Value)"
            }
        }
    }
}