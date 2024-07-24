
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main, $ToolBoxConfig.LogLevel)

function Register-PolicyServer {
    param(
        # Variables to register
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$Server,
        [Parameter(Mandatory=$false)][AllowEmptyString()][String]$Alias,

        # Messages 
        [Parameter(Mandatory=$false)][String]$ServerMessage = "Enter the FQDN of the EJBCA CEP Server",
        [Parameter(Mandatory=$false)][String]$ServerMessageColor = "Gray",
        [Parameter(Mandatory=$false)][String]$AliasMessage = "Enter the FQDN of the EJBCA MSAE alias",
        [Parameter(Mandatory=$false)][String]$AliasMessageColor = "Gray",

        # Switches
        [Parameter(Mandatory=$false)][Switch]$IncludeAlias,
        [Parameter(Mandatory=$false)][Switch]$ValidateAvailableSpn
    )

    $LoggerRegisterPolicyServer = $LoggerFunctions
    $LoggerRegisterPolicyServer.Logger = "KF.Toolkit.Function.RegisterPolicyServer"

    # Strings
    $DefaultPolicyServerMessage = "Would you like to use the default policy server '{0}'?"
    $ServicePrincipalNameNotUnique = "The EJBCA policy server service principal name '{0}' is already configured on '{1}'.`nProvide a different name"

    do {
        if([String]::IsNullOrEmpty($Server)){
            $Server = Read-HostPrompt `
                -Message $ServerMessage `
                -Color $ServerMessageColor
        } 

        # Create service principal name and search AD for existing policy server name
        $ServicePrincipalName = "HTTP/$Server"

        # Validate service principal name doesnt already exist in Active Directory
        if($ValidateAvailableSpn){
            $Searcher = [adsisearcher]"(servicePrincipalName=*)"
            $SearchResults = $Searcher.Findall()
            try {
                foreach($Result in $SearchResults){
                    $Entry = $Result.GetDirectoryEntry()
                    if(($Entry.servicePrincipalName -eq $ServicePrincipalName) -and ($Entry.Name -ne $Server)){
                        Write-Error -Message ($ServicePrincipalNameNotUnique -f ($ServicePrincipalName, $($Entry.Name)))  -ErrorAction Stop
                    }
                }
            } catch {
                $ServerMessage = $_; $ServerMessageColor = "Yellow"
                $LoggerRegisterPolicyServer.Error($_)
                $Server = $null 
            }
        }
    
    } until ($Server)

    $LoggerRegisterPolicyServer.Info("Setting PolicyServer=$Server")

    $UniversalPrincipalName = "$ServicePrincipalName@$($ToolBoxConfig.Domain.ToUpper())"
    $TlsUri = "https://$Server"
    $EjbcaUri = "https://$Server/ejbca"

    $LoggerRegisterPolicyServer.Debug("Service principal name $ServicePrincipalName is not already assigned to an account in $($ToolBoxConfig.Domain) and is free to use.") 
    if(Test-ParentDomain -and ((Get-ADDomain).ChildDomains).Length){
        $LoggerRegisterPolicyServer.Warn("It may exist in one of the child domains.")
    } else {
        $LoggerRegisterPolicyServer.Warn("It may exist somewhere in another child domain or in the parent domain.")
    }

    # Get msae alias if switch provided 
    if($IncludeAlias){
        if([String]::IsNullOrEmpty($Alias)){
            $Alias = Read-HostPrompt `
                -Message $AliasMessage `
                -Color $AliasMessageColor
        } 
        
        $LoggerRegisterPolicyServer.Info("Setting PolicyServerAlias=$Alias")
        $AliasUri = "$EjbcaUri/msae/CEPService?$Alias"
    }

    $ServerAttributesObject = [PSCustomObject]@{
        Uri = $TlsUri
        EjbcaUri = $EjbcaUri
        AliasUri = %{if([String]::IsNullOrEmpty($AliasUri)){$null}else{$AliasUri}}
        FQDN = $Server
        SPN = $ServicePrincipalName
        UPN = $UniversalPrincipalName
    }
    $LoggerRegisterPolicyServer.Debug(("Setting policy server values: $($ServerAttributesObject|Out-TableString)"))

    return $ServerAttributesObject
}

function Register-ServiceAccount {
    param(
        # Variables to register
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$Account,

        # Messages 
        [Parameter(Mandatory=$false)][String]$Message = "Enter the name of the MSAE Service Account",
        [Parameter(Mandatory=$false)][String]$MessageColor = "Gray",
        # Switches
        [Parameter(Mandatory=$false)][Switch]$ValidateNonExistent,
        [Parameter(Mandatory=$false)][Switch]$ValidateExists
    )

    $LoggerRegisterServiceAccount = $LoggerFunctions
    $LoggerRegisterServiceAccount.Logger = "KF.Toolkit.Function.ServiceAccount"

    do {
        # get service account name if it doesnt already exist
        if([String]::IsNullOrEmpty($Account)){
            $Account = Read-HostPrompt `
                -Message $Message `
                -Color $MessageColor 
        }
        try {

            # test account for white space
            $Account = Test-WhiteSpace `
                -Message "The service account cannot contain any white spaces. Would you like to use '{0}' instead" `
                -Value $Account

            # Test for existing account
            $LoggerRegisterServiceAccount.Debug("Attempting to validate provided ServiceAccount=$Account")
            Get-AdUser -Identity $Account | Out-Null

            if(-not $ValidateExists){ # empty account name and try again if it already exists
                $Message = "Service account '$($Account)' already exists. Please provide another name"; $MessageColor = "Yellow"
                $LoggerRegisterServiceAccount.Info($Message)
                $Account = $null
            }
        
        } catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            if($SValidateExists){
                $Message = "Service account '$($Account)' does not exist. Please provide a different service account name."; $MessageColor = "Yellow"
                $LoggerRegisterServiceAccount.Error($Message)
                $Account = $null
            }
        }

    } until ($Account)

    $LoggerRegisterServiceAccount.Info("Setting ServiceAccount=$Account")
    return $Account
}

function Register-ServiceAccountPassword {
    param(
        [Parameter(Mandatory=$true)][String]$Account,
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$Password,
        [Parameter(Mandatory=$false)][String]$Message = "Enter the password for the MSAE service account",
        [Parameter(Mandatory=$false)][String]$Color = "Gray",
        [Parameter(Mandatory=$false)][Switch]$Validate,
        [Parameter(Mandatory=$false)][Switch]$Secure
    )

    $LoggerRegisterServiceAccountPassword = $LoggerFunctions
    $LoggerRegisterServiceAccountPassword.Logger = "KF.Toolkit.Function.RegisterServiceAccountPassword"

    try{
        do {
            if([String]::IsNullOrEmpty($Password)){
                $Password = Read-HostPrompt `
                    -Message $Message `
                    -Color $Color
            }

            # Convert to secure string
            if($Secure -or $Validate){
                $SecurePassword = ConvertTo-SecureString `
                    -String $Password `
                    -AsPlainText `
                    -Force

                $LoggerRegisterServiceAccountPassword.Debug("Converted plaint text password to a secure string.")
            }
            
            if($Validate){
                $LoggerRegisterServiceAccountPassword.Debug("Testing password for service account: $Account.")

                # Build PSCredential and test password
                $Credential = New-Object `
                    -TypeName System.Management.Automation.PSCredential `
                    -ArgumentList $Account, $Password 

                try {

                    Get-ADUser -Identity $Account -Credential $Credential | Out-Null
                    $LoggerRegisterServiceAccountPassword.Debug("Successfully tested $Account password.")

                } catch [System.Security.Authentication.AuthenticationException] {
                    $Message = "Incorrect password provided for $Account. Provide a different password"; $MessageColor = "Yellow"
                    $LoggerRegisterServiceAccountPassword.Error($Message)
                    $Password = $null
                }
            } 
        } until($Password)

        $LoggerRegisterServiceAccountPassword.Info("Setting ServiceAccountPassword=$Password")

        if($Secure){
            return $SecurePassword
        } else {
            return $Password
        }
    } catch {
        $LoggerRegisterServiceAccountPassword.Exception($_)
        throw
    }
}

function Register-File {
    param(
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$FilePath,
        [Parameter(Mandatory=$true)][String]$FileType,
        [Parameter(Mandatory=$false)][String]$Message="Enter the file path",
        [Parameter(Mandatory=$false)][String]$MessageColor="Gray",
        [Parameter(Mandatory=$false)][Switch]$Validate
    )

    $LoggerFile = $LoggerFunctions
    $LoggerFile.Logger = "KF.Toolkit.Function.RegisterFile"

    do {
        try {
            if([String]::IsNullOrEmpty($FilePath) -or ($ToolBoxConfig.UseDefaults -eq $false)){
                $FilePath = Read-HostPrompt `
                    -Message $Message `
                    -Color $MessageColor
            }
            if($Validate){
                $File = Get-Childitem -Path $FilePath -ErrorAction Stop
                $LoggerFile.Info("Found $FileType $FilePath")
                $FilePath = $File.FullName
            }
        }
        catch [System.Management.Automation.ItemNotFoundException]{
            if($Validate){
                $Message = "Provided path '$($FilePath)' does not exist. Please provide a different path"; $MessageColor = "Yellow"
                $LoggerFile.Error($Message)
                $FilePath = $null
            } else {
                $LoggerFile.Info("Provided $FilePath path was not validated")
            }
        }   
    } until($FilePath)

    $LoggerFile.Info("Setting $FileType=$FilePath")
    return $FilePath
}

function Register-AutoenrollSecurityGroup {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$Group,
        [Parameter(Mandatory=$false)][String]$Message = "Enter the name for the Security Group to add to the certificate template with autoenrollment permissions",
        [Parameter(Mandatory=$false)][String]$MessageColor = "Gray",
        [Parameter(Mandatory=$false)][Switch]$Validate
    )

    $LoggerAutoenrollSecurityGroup = $LoggerFunctions
    $LoggerAutoenrollSecurityGroup.Logger = "KF.Toolkit.Function.RegisterAutoenrollSecurityGroup"

    do{
        try {
            if([String]::IsNullOrEmpty($Group)){
                $Group = Read-HostPrompt `
                    -Message $Message `
                    -Color $MessageColor
            }
            if($Validate){
                $Group = (Get-ADGroup -Identity $Group).Name
                $LoggerAutoenrollSecurityGroup.Info("Found '$Group' in active directory")
            }
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            $Message = "Security group: '$SecurityGroup' does not exist. Provide another name"; $MessageColor = "Yellow"
            $LoggerAutoenrollSecurityGroup.Error($Message)
            $Group = $null
        } 
    } until($Group)

    $LoggerAutoenrollSecurityGroup.Info("Setting TemplateGroup=$Group")

    return $SecurityGroup
}

function Register-CertificateTemplate {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$Template,
        [Parameter(Mandatory=$false)][String]$Message=$StringsPrompts.GetCertificateTemplate,
        [Parameter(Mandatory=$false)][Bool]$Existing=$true
    )
    $LoggerCertificateTemplate = $LoggerFunctions
    $LoggerCertificateTemplate.Logger = "KF.Toolkit.Function.RegisterCertificateTemplate"

    do {

        if([String]::IsNullOrEmpty($Template)){
            $Template = Read-HostPrompt `
                -Message $Message `
                -Color $MessageColor
        }

        # Check for existing template
        $ExistingTemplateCheck = Test-CertificateTemplate $Template

        if($Existing -and $ExistingTemplateCheck){
            $LoggerCertificateTemplate.Info(($StringsObject.Found -f ("Certificate template",$Template)))

        } elseif($Existing -and -not $ExistingTemplateCheck) {
            $LoggerCertificateTemplate.Error(($StringsObject.DoesNotExist -f ("Certificate template",$Template)), $True)
            $Template = $null

        } elseif(-not $Existing -and $ExistingTemplateCheck) {
            $Message = "$($StringsObject.AlreadyExists -f ("Certificate template",$Template))"; $MessageColor = "Yellow"
            $LoggerCertificateTemplate.Error($Message)
            $Template = $null

        } elseif(-not $Existing -and -not $ExistingTemplateCheck)  {
            $LoggerCertificateTemplate.Info(($StringsObject.ObjectAvailable -f $ServiceAccount))

        } else {
            throw "Failed all conditional checks when registering Certificate Template."
        }
    } until($Template)

    return $Template
}

function Register-CertificateEnrollmentPolicyServer {
    <#
    .Synopsis
        Configure enrollment policy server
    .Description
        Configures EJBCA policy server endpoint for autoenrollment. Returns a 'true' result if successful or a Windows error code if unsuccessful.
    .Parameter PolicyServerObject
        Object containing the different values derived from the EJBCA hostname
    .Parameter Context
        Configures policy server for Machine or User context
    .Example
       Register-CertificateEnrollmentPolicyServer -PolicyServerObject $PolicyServerAttributes -Context $EnrollmentContext
    #>
    param(
        [Parameter(Mandatory)][Object]$PolicyServerObject,
        [Parameter(Mandatory)][ValidateSet("Machine","User")][String]$Context
    )

    $LoggerCertificateEnrollmentPolicyServer = $LoggerFunctions
    $LoggerCertificateEnrollmentPolicyServer.Logger = "KF.Toolkit.Function.RegisterCertificateEnrollmentPolicyServer"
    $LoggerFunctions.Debug("$($MyInvocation.InvocationName) parameters: $($MyInvocation.BoundParameters|Out-TableString)")

    try {

        $ResultsAddCep = Add-CertificateEnrollmentPolicyServer `
            -Url $PolicyServerObject.AliasUri `
            -Context $Context `
            -AutoEnrollmentEnabled `
            -RequireStrongValidation

        return $True

    } catch {
        $LoggerFunctions.Exception($_)

        # Convert error record to string
        $ErrorMessage = $_.Exception | Out-String

        # Substring exception message
        $ErrorHexSearch = $ErrorMessage.Substring($ErrorMessage.IndexOf("0x"))
        $ErrorMessageSearch = $ErrorMessage.Substring(0,$ErrorMessage.IndexOf("0x"))
        $ErrorRecord = [PSCustomObject]@{
            ErrorCode = $ErrorHexSearch.Split()[0]
            ErrorMessage = $ErrorMessageSearch.Substring($ErrorMessage.LastIndexOf(":")+1).Trim()
        }

        $LoggerFunctions.Debug("Parsed policy server configuration error: $($ErrorRecord|Out-TableString)")

        return $ErrorRecord
    }
}