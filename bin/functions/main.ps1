
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main)

function Convert-PromptReponseBool {
    <#
    .Synopsis
        Convert message box response to boolean
    .Description
        Message boxes return integer values. This function converts certain respones, like Yes/No, to True/False. 
        This is helpful when evaluting responses in condition statements.

        Refer to the following for the available DialogResult Enums:
        https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.dialogresult?view=windowsdesktop-8.0
    .Parameter Value
        Integer to convert with Switch condition
    .Example
        $Answer | Convert-PromptResponseBool  
    #>
    param(
        [Parameter(Mandatory=$true)][int]$Value
    )
    process {
        switch ([int]$Value) {
            1 {$true}
            2 {$false}
            6 {$true}
            7 {$false}
        }
    }
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

    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
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

        $LoggerFunctions.Info("The primary group of $($Object.name) is: $($ObjectPrimaryGroup.distinguishedname)")
        $LoggerFunctions.Info("$($Object.dnshostname) is a member of: $($ObjectSecurityGroups|ConvertTo-JSON)")
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

    # Set Logger
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.GetTemplateEnrollmentPermissions"

    # Permission GUIDs for conditional matching
    $AutoenrollGuid = "a05b8cc2-17bc-4802-a710-e7c15ab866a2"
    $EnrollGuid = "0e10c968-78fb-11d2-90d4-00c04f79dc55"

    try {

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
        Write-Host $_ -ForegroundColor Red
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

    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
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

        $LoggerFunctions.Logger = "MSAE.Toolkit.Function.NewCertificateTemplate"

        $NewTemplate.put("distinguishedName","CN=$CommonName,$TemplateContainerDn")
        $NewTemplate.put("displayName","$DisplayName")
        $NewTemplate.put("msPKI-Cert-Template-OID","$($NewOid.TemplateOID)")
        $NewTemplate.put("flags","$($DuplicateTemplate.flags)")
        $NewTemplate.put("revision","100")
        $NewTemplate.put("pKIDefaultKeySpec","$($DuplicateTemplate.pKIDefaultKeySpec)")

        [void]$NewTemplate.SetInfo()
        $LoggerFunctions.Debug("Created new template $CommonName with basic information.")

        
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

        $LoggerFunctions.Info("Created certificate template '$DisplayName'.")
        $LoggerFunctions.Console("Green")
        return $true

    }
    catch [System.Management.Automation.MethodInvocationException] {
        if($_ -match "(The object already exists)"){
            $LoggerFunctions.Info("Template: $DisplayName already exists.")
            $LoggerFunctions.Console("Yellow")
            return $false
        }
    }
    catch {
        Write-Host "$($MyInvocation.InvocationName): $_" -ForegroundColor Red
        $LoggerFunctions.Exception($_)
    }
}

function New-Keytab {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)][string]$Account,
        [Parameter(Mandatory)][string]$Principal,
        [Parameter(Mandatory)][string]$Password,
        [Parameter(Mandatory)][string]$Outfile
    )

    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.NewKeytab"
    $LoggerFunctions.Debug(
        ("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|ConvertTo-JSON)").Trim()
    )
    
    try {
        $PassAsPlainText = [System.Net.NetworkCredential]::new("", $Password).Password
        $KeytabString = "ktpass -out $Outfile -mapuser $Account -kvno 0 -princ $Principal -pass $PassAsPlainText -ptype KRB5_NT_PRINCIPAL -crypto AES256-SHA1 2>&1"

        $LoggerFunctions.Debug("keytab create string: $KeytabString")

        $Keytab = $(cmd /c "$KeytabString") -split [environment]::NewLine
        foreach($Line in $Keytab){
            if($Line -match "(Aborted)"){
                $LoggerFunctions.Error($Line)
                $LoggerFunctions.Error(
                    "Failed to create keytab most likely due to a password that does not meet the complexity requires of the domain."
                )
            }
            else {
                $LoggerFunctions.Debug($Line)
            }
        }
        if($Keytab -match "(Keytab version: 0x502)"){
            $LoggerFunctions.Info(
                "Successfully created keytab file with an AES256-SHA1 encryption key and output file to $Outfile."
            )
            #$LoggerFunctions.Console("Green")
            $PassAsPlainText = $null #empty clear text password after keytab creation
            return $true
        } 
        else {
            throw "Failed to create keytab file." 
        }
    }
    catch {
        $LoggerFunctions.Exception($_)
    }
}

function New-Krb5Conf {
    param(
        [Parameter(Mandatory)][string]$OutFile,
        [Parameter(Mandatory)][string]$Domain,
        [Parameter(Mandatory=$false)][string]$KDC
    )

    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.NewKrb5Conf"
    $LoggerFunctions.Debug(
        ("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|ConvertTo-JSON)").Trim()
    )

    $Domain = $Domain.ToUpper()
    $LowerDomain = $Domain.ToLower()
    if([string]::IsNullOrEmpty($KDC)){
        $KDC = $Domain
    }
    try {

        $Krb5Conf = (
            "[libdefaults]",
            "default_realm = $Domain",
            "default_tkt_enctypes = aes256-cts-hmac-sha1-96",
            "default_tgs_enctypes = aes256-cts-hmac-sha1-96",
            "permitted_enctypes = aes256-cts-hmac-sha1-96",

            "`n[realms]",
            "$Domain = {",
                "`tkdc = $KDC",
                "`tdefault_domain = $Domain",
            "}",

            "`n[domain_realm]",
            ".$LowerDomain = $Domain"
        ) -join "`r`n"

        $LoggerFunctions.Debug(("Krb5Conf file: `n$($Krb5Conf)").Trim())
        Write-Output $Krb5Conf | Out-File -FilePath $OutFile
        if(Test-Path $OutFile){
            $LoggerFunctions.Info(
                "Successfully created Krb5 conf and output file to $Outfile."
            )
            #$LoggerFunctions.Console("Green")
            return $true
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
    return $true
}

function New-TemplateOid {
    param(
        [Parameter(Mandatory)][String]$DomainController,
        [Parameter(Mandatory)][String]$Context
    )

    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.NewTemplateOid"

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

function Set-AutoEnrollmentPermissions {
    param(
        [Parameter(Mandatory)][String]$Template,
        [Parameter(Mandatory)][String]$Group,
        [Parameter(Mandatory)][String]$ForestDn
    )

    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.SetCertificateTemplatePermissions"

    try {

        $CertificateTemplates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ForestDn"
        $TemplateObject = $CertificateTemplates.Children.where({$_.displayName -eq $Template})

        # set autoenroll permissions
        $ActiveDirectoryObject = New-Object System.Security.Principal.NTAccount($Group)
        $Identity = $ActiveDirectoryObject.Translate([System.Security.Principal.SecurityIdentifier])
        $Rights = "ExtendedRight"
        $Type = "Allow"
    
        $ActiveDirectoryAccessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity,$Rights,$Type)
        $TemplateObject.ObjectSecurity.SetAccessRule($ActiveDirectoryAccessRule)
        $TemplateObject.CommitChanges()
        $LoggerFunctions.Debug("Committed ACL changes on '$Template'.")
        
        $ResultVerification = Test-AutoEnrollmentPermissions -Template $Template -Group $Group -ForestDn $ForestDn
        if($ResultVerification){
            $LoggerFunctions.Debug("Successfully granted autoenrollment permission on '$Template' for security group: $Group.")
            $LoggerFunctions.Console("Green")
            #return $true
        }
        else{
            $LoggerFunctions.Error("Failed to grant autoenrollment permission on '$Template' for security group: $Group")
            $LoggerFunctions.Console("Red")
            #return $false
        }
    }
    catch {
        Write-Host $_ -ForegroundColor Red
    }
}

function Test-AutoEnrollmentPermissions {
    param(
        [Parameter(Mandatory)][String]$Template,
        [Parameter(Mandatory)][String]$Group,
        [Parameter(Mandatory)][String]$ForestDn
    )    

    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.TestAutoEnrollmentPermissions"

    # Permission GUIDs for conditional matching
    $Guids = @(
        "a05b8cc2-17bc-4802-a710-e7c15ab866a2",
        "00000000-0000-0000-0000-000000000000"
    )

    try {

        # Get template directory object
        $CertificateTemplates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ForestDn"
        $ProvidedTemplate = $CertificateTemplates.Children.where({$_.Name -eq $Template})

        # Loop through Access rules that only contain the name of the provided security group
        $ProvidedTemplate.ObjectSecurity.Access.where({$_.IdentityReference -match "($Group)"}).foreach{

            # Return true if autoenrollment and allow permissions found
            if($_.ObjectType.ToString() -in $Guids -and $_.ActiveDirectoryRights -match "(ExtendedRight)"){ 
                return $true
            }
        }
    }
    catch {
        Write-Host $_ -ForegroundColor Red
    } 
}

function Test-UniqueOid {
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][String]$TemplateOID,
        [Parameter(Mandatory)][String]$DomainController,
        [Parameter(Mandatory)][String]$Context
    )
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.NewUniqueOid"

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

function Out-TableString {
    param(
        [Parameter(Mandatory,ValueFromPipeline)][Object]$Table
    )
    process {
        "`n$(($Table|Format-List|Out-String).Trim())"
    }
}