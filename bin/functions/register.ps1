function Register-PolicyServer {
    param(
        # Variables to register
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$Server,
        [Parameter(Mandatory=$false)][AllowEmptyString()][String]$Alias,

        # Messages 
        [Parameter(Mandatory=$false)][String]$ServerMessage = "Enter the FQDN of the EJBCA CEP Server",
        [Parameter(Mandatory=$false)][String]$ServerMessageColor = $FontColor.Base,
        [Parameter(Mandatory=$false)][String]$AliasMessage = "Enter the name of the configured EJBCA MSAE alias",
        [Parameter(Mandatory=$false)][String]$AliasMessageColor = $FontColor.Base,
        
        # Options
        [Parameter(Mandatory=$false)][Switch]$IncludeAlias,
        [Parameter(Mandatory=$false)][Switch]$ValidateAvailableSpn
    )

    $RegistrationType = "Policy Server"
    $RegistrationVariable = $RegistrationType.Replace(' ','')
    $ServicePrincipalNameNotUnique = "{0}: {1} already exists as an SPN on {2}. Provide a different hostname"

    do {
        if($NonInteractive -and [String]::IsNullOrEmpty($Server)){
            $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
            exit
        
        } elseif([String]::IsNullOrEmpty($Server)){
            $Server = Read-HostPrompt `
                -Message $ServerMessage `
                -Color $ServerMessageColor
            $RegistrationServer = "$($Strings.RegisterUserProvided -f ($RegistrationType, $Server))"

        } else { $RegistrationServer = "$($Strings.RegisterImported -f ($RegistrationType, $Server))" }

        # Create service principal name and search AD for existing policy server name
        $ServicePrincipalName = "HTTP/$Server"

        # Validate service principal name doesnt already exist in Active Directory
        if($ValidateAvailableSpn){
            $Searcher = [adsisearcher]"(servicePrincipalName=*)"
            $SearchResults = $Searcher.Findall()
            foreach($Result in $SearchResults){
                $Entry = $Result.GetDirectoryEntry()
                if(($Entry.servicePrincipalName -eq $ServicePrincipalName) -and ($Entry.Name -ne $Server)){
                    $ServerMessage = $ServicePrincipalNameNotUnique -f ($RegistrationType, $Server, $($Entry.Name)); $ServerMessageColor = $FontColor.Warn
                    $LoggerFunctions.Error($ServerMessage, $NonInteractive)
                    $Server = $null 
                }
            }
        }
    
    } until ($Server)

    $UniversalPrincipalName = "$ServicePrincipalName@$($ToolBoxConfig.Domain.ToUpper())"
    $TlsUri = "https://$Server"
    $EjbcaUri = "https://$Server/ejbca"

    $LoggerFunctions.Debug("Service principal name $ServicePrincipalName is not already assigned to an account in $($ToolBoxConfig.Domain) and is free to use.") 
    if(Test-ParentDomain -and ((Get-ADDomain).ChildDomains).Length){
        $LoggerFunctions.Warn("It may exist in one of the child domains.")
    } else {
        $LoggerFunctions.Warn("It may exist somewhere in another child domain or in the parent domain.")
    }

    $LoggerFunctions.Register($RegistrationServer)

    # Get msae alias if switch provided 
    if($IncludeAlias){
        $RegistrationType = "Policy Server Alias"
        $RegistrationVariable = $RegistrationType.Replace(' ','')

        if($NonInteractive -and [String]::IsNullOrEmpty($Alias)){
            $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
            exit
        
        } elseif([String]::IsNullOrEmpty($Alias)){
            $Alias = Read-HostPrompt `
                -Message $AliasMessage `
                -Color $AliasMessageColor
            $RegisterAlias = "$($Strings.RegisterUserProvided -f ($RegistrationType, $Alias))" 
            
        } else { $RegisterAlias = "$($Strings.RegisterImported -f ($RegistrationType, $Alias))" }
        
        $LoggerFunctions.Register($RegisterAlias)
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

    $LoggerFunctions.Debug(("${$RegistrationType}: $($ServerAttributesObject|Out-ListString)"))

    return $ServerAttributesObject
}

function Register-ServiceAccount {
    param(
        # Variables to register
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$Account,

        # Messages 
        [Parameter(Mandatory=$false)][String]$Message = "Enter the name of the MSAE Service Account",
        [Parameter(Mandatory=$false)][String]$MessageColor = $FontColor.Base,

        # Options
        [Parameter(Mandatory=$false)][Switch]$ValidateNonExistent,
        [Parameter(Mandatory=$false)][Switch]$ValidateExists
    )

    $RegistrationType = "Account Name"
    $RegistrationVariable = $RegistrationType.Replace(' ','')

    do {
        if($NonInteractive -and [String]::IsNullOrEmpty($Account)){
            $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
            exit
        
        } elseif([String]::IsNullOrEmpty($Account)){
            $Account = Read-HostPrompt `
                -Message $Message `
                -Color $MessageColor 
            $RegistrationAccount = "$($Strings.RegisterUserProvided -f ($RegistrationType, $Account))"

        } else { $RegistrationAccount = "$($Strings.RegisterImported -f ($RegistrationType, $Account))" }
        try {

            # test account for white space
            $Account = Test-WhiteSpace `
                -Message "The service account cannot contain any white spaces. Would you like to use '{0}' instead" `
                -Value $Account

            # Test for existing account
            $LoggerFunctions.Debug("Attempting to validate provided $RegistrationType '$Account'")
            Get-AdUser -Identity $Account -ErrorAction Stop | Out-Null

            if(-not $ValidateExists){ # empty account name and try again if it already exists
                $Message = "$($Strings.AlreadyExists -f ($RegistrationType, $Account))"; $MessageColor = $FontColor.Warn
                $LoggerFunctions.Error($Message, $NonInteractive)
                $Account = $null
            }
        
        } catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            if($ValidateExists){
                $Message = "$($Strings.DoesNotExist -f ($RegistrationType, $Account))"; $MessageColor = $FontColor.Warn
                $LoggerFunctions.Error($Message, $NonInteractive)
                $Account = $null
            }
        }

    } until ($Account)

    $LoggerFunctions.Register($RegistrationAccount)
    return $Account
}

function Register-ServiceAccountPassword {
    param(
        [Parameter(Mandatory=$true)][String]$Account,
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$Password,
        [Parameter(Mandatory=$false)][String]$Message = "Enter the password for the MSAE service account",
        [Parameter(Mandatory=$false)][String]$Color = $FontColor.Base,
        [Parameter(Mandatory=$false)][Switch]$Validate,
        [Parameter(Mandatory=$false)][Switch]$Secure
    )

    $RegistrationType = "Account Password"
    $RegistrationVariable = $RegistrationType.Replace(' ','')

    try{
        do {
            if($NonInteractive -and [String]::IsNullOrEmpty($Password)){
                $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
                exit
        
            } elseif([String]::IsNullOrEmpty($Password)){
                if($Secure){
                    $Password = Read-HostPrompt -Secure `
                        -Message $Message `
                        -Color $Color
                } else { 
                    $Password = Read-HostPrompt `
                        -Message $Message `
                        -Color $Color
                }
                $RegistrationPassword = $($Strings.RegisterUserProvided -f ($RegistrationType, $Password))

            } else { $RegistrationPassword = $($Strings.RegisterImported -f ($RegistrationType, $Password)) }

            # Convert to secure string
            if($Secure -or $Validate){
                $SecurePassword = ConvertTo-SecureString `
                    -String $Password `
                    -AsPlainText `
                    -Force

                $LoggerFunctions.Debug("Converted plaint text password to a secure string.")
            }
            
            if($Validate){
                $LoggerFunctions.Debug("Testing password for service account: $Account.")

                # Build PSCredential and test password
                $Credential = New-Object `
                    -TypeName System.Management.Automation.PSCredential `
                    -ArgumentList $Account, $Password 

                try {

                    Get-ADUser -Identity $Account -Credential $Credential | Out-Null
                    $LoggerFunctions.Debug("Successfully tested $Account password.")

                } catch [System.Security.Authentication.AuthenticationException] {
                    $Message = "Incorrect password provided for $Account. Provide a different password"; $MessageColor = $FontColor.Warn
                    $LoggerFunctions.Error($Message, $NonInteractive)
                    $Password = $null
                }
            } 
        } until($Password)

        $LoggerFunctions.Register($RegistrationPassword)

        if($Secure){
            return $SecurePassword
        } else {
            return $Password
        }
    } catch {
        $LoggerFunctions.Exception($_)
        throw
    }
}

function Register-ServiceAccountOrgUnit {
    param(
        # Variables to register
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$OrgUnit,

        # Messages 
        [Parameter(Mandatory=$false)][String]$Message = "Enter the common name, or a partial common name, of the Active Directory Organization Unit to create {0} in",
        [Parameter(Mandatory=$false)][String]$MessageColor = $FontColor.Base

    )

    $RegistrationType = "Account Org Unit"
    $RegistrationVariable = $RegistrationType.Replace(' ','')
    $PathMessage = "Multiple organizational units matching the '{0}' query were returned. Select one of the following choices:"
    $NonExistentMessage = "${RegistrationType}: '{0}' does not match any existing AD OU. Please provide another org unit"

    do {
        if($NonInteractive -and [String]::IsNullOrEmpty($OrgUnit)){
            $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
            exit
        
        } elseif([String]::IsNullOrEmpty($OrgUnit)){
            $OrgUnit = Read-HostPrompt `
                -Message $($Message -f $Name) `
                -Color $MessageColor
                $RegistrationOrgUnit = $($Strings.RegisterUserProvided -f ($RegistrationType, $OrgUnit))

        } else { $RegistrationOrgUnit = $($Strings.RegisterImported -f ($RegistrationType, $OrgUnit)) }

        # search organization units based on provided search string
        $LoggerFunctions.Info("Searching for organization units like '$OrgUnit'.")
        $ResultsServiceAccountOrgUnitSearch = (Get-ADOrganizationalUnit -Filter "Name -like '*$($OrgUnit)*'").DistinguishedName

        # multiple results found
        if($ResultsServiceAccountOrgUnitSearch.Count -gt 1){
            $ServiceAccountOrgUnitPath = Read-HostPromptMultiSelection `
                -Message "$($PathMessage -f $OrgUnit)" `
                -Selections $ResultsServiceAccountOrgUnitSearch
        
        # no results found
        } elseif(-not $ResultsServiceAccountOrgUnitSearch.Count) {
            $Message = "$($NonExistentMessage -f $OrgUnit)"; $MessageColor = $FontColor.Warn
            $LoggerFunctions.Error($Message, $NonInteractive)
            $OrgUnit = $null

        } else {
            $ServiceAccountOrgUnitPath = $ResultsServiceAccountOrgUnitSearch
        }

    } until ($OrgUnit)

    $LoggerFunctions.Register($RegistrationOrgUnit)
    
    return $ServiceAccountOrgUnitPath
}

function Register-File {
    param(
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$FilePath,
        [Parameter(Mandatory=$true)][String]$FileType,
        [Parameter(Mandatory=$false)][String]$Message="Enter the file path",
        [Parameter(Mandatory=$false)][String]$MessageColor=$FontColor.Base,
        [Parameter(Mandatory=$false)][Switch]$Validate
    )

    $RegistrationType = $FileType
    $RegistrationVariable = $RegistrationType.Replace(' ','')

    do {
        try {
            if($NonInteractive -and [String]::IsNullOrEmpty($FilePath)){
                $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
                exit
        
            } elseif([String]::IsNullOrEmpty($FilePath) -or ($ToolBoxConfig.UseDefaults -eq $false)){
                $FilePath = Read-HostPrompt `
                    -Message $Message `
                    -Color $MessageColor

                $RegistrationFile = "$($Strings.RegisterUserProvided -f ($RegistrationType, $FilePath))"
            } else {  $RegistrationFile= "$($Strings.RegisterImported -f ($RegistrationType, $FilePath))" }
            
            if($Validate){
                $File = Get-Childitem -Path $FilePath -ErrorAction Stop
                $LoggerFunctions.Info($Strings.NotValidated -f ($RegistrationType, $FilePath))
                $FilePath = $File.FullName
            }
        }
        catch [System.Management.Automation.ItemNotFoundException]{
            if($Validate){
                $Message = $Strings.DoesNotExist -f ($RegistrationType, $FilePath); $MessageColor = $FontColor.Warn
                $LoggerFunctions.Error($Message, $NonInteractive)
                $FilePath = $null
            } else {
                $LoggerFunctions.Warn($Strings.NotValidated -f ($RegistrationType, $FilePath))
            }
        }   
    } until($FilePath)

    $LoggerFunctions.Register($RegistrationFile)
    return $FilePath
}

function Register-AutoenrollSecurityGroup {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$Group,
        [Parameter(Mandatory=$false)][String]$Message = "Enter the name for the Security Group to add to the certificate template with autoenrollment permissions",
        [Parameter(Mandatory=$false)][String]$MessageColor = $FontColor.Base,
        [Parameter(Mandatory=$false)][ValidateSet("Computer","User")][String]$Context = "Computer",
        [Parameter(Mandatory=$false)][Switch]$Validate
    )

    $RegistrationType = "$Context Security Group"
    $RegistrationVariable = $RegistrationType.Replace(' ','')

    do{
        try {
            if($NonInteractive -and [String]::IsNullOrEmpty($Group)){
                $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
                exit
        
            } elseif([String]::IsNullOrEmpty($Group)){
                $Group = Read-HostPrompt `
                    -Message $Message `
                    -Color $MessageColor
                $RegistrationGroup = "$($Strings.RegisterUserProvided -f ($RegistrationType, $Group))"

            } else { $RegistrationGroup = "$($Strings.RegisterImported -f ($RegistrationType, $Group))" }

            if($Validate){
                $Group = (Get-ADGroup -Identity $Group).Name
                $LoggerFunctions.Info(($Strings.Found -f ($RegistrationType, $Group)))
            }
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            $Message = $Strings.DoesNotExist -f ($RegistrationType, $Group); $MessageColor = $FontColor.Warn
            $LoggerFunctions.Error($Message, $NonInteractive)
            $Group = $null
        } 
    } until($Group)

    $LoggerFunctions.Register($RegistrationGroup)
    return $Group
}

function Register-CertificateTemplate {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$Template,
        [Parameter(Mandatory=$false)][String]$Message="Enter the name for the new {0} context certiticate template",
        [Parameter(Mandatory=$false)][String]$MessageColor = $FontColor.Base,
        [Parameter(Mandatory=$true)][ValidateSet("Computer","User")][String]$Context="Computer",
        [Parameter(Mandatory=$false)][Bool]$CheckAlreadyExists = $false
    )

    $RegistrationType = "Template $Context"
    $RegistrationVariable = $RegistrationType.Replace(' ','')
    $LoggerFunctions.Info("Checking for existing certificates is set to: $CheckAlreadyExists.")

    do {
        if($NonInteractive -and [String]::IsNullOrEmpty($Template)){
            $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
            exit
        
        } elseif([String]::IsNullOrEmpty($Template)){
            $Template = Read-HostPrompt `
                -Message "$($Message -f $Context)" `
                -Color $MessageColor
            $RegistrationTemplate = "$($Strings.RegisterUserProvided -f ($RegistrationType, $Template))"
        } else { $RegistrationTemplate = "$($Strings.RegisterImported -f ($RegistrationType, $Template))" }

        # Check for existing template
        $ExistingTemplateCheck = Test-CertificateTemplateExists $Template

        if($CheckAlreadyExists -and $ExistingTemplateCheck){
            $LoggerFunctions.Info(($Strings.Found -f ($RegistrationType, $Template)))

        } elseif($CheckAlreadyExists -and -not $ExistingTemplateCheck) {
            $Message = "$($Strings.DoesNotExist -f ($RegistrationType, $Template))"; $MessageColor = $FontColor.Warn
            $LoggerFunctions.Error($Message, $NonInteractive)
            $Template = $null

        } elseif(-not $CheckAlreadyExists -and $ExistingTemplateCheck) {
            $Message = "$($Strings.AlreadyExists -f ($RegistrationType, $Template))"; $MessageColor = $FontColor.Warn,
            $LoggerFunctions.Error($Message, $NonInteractive)
            $Template = $null

        } elseif(-not $CheckAlreadyExists -and -not $ExistingTemplateCheck)  {
            $LoggerFunctions.Info(($Strings.Available -f $Template))

        } else {
            throw [System.Exception] $Exception.ConditionalChecks
        }
    } until($Template)

    $LoggerFunctions.Register($RegistrationTemplate)
    return $Template
}

function Register-CertificateTemplateContext {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$Context,
        [Parameter(Mandatory=$false)][String]$Message = "Select the certificate enrollment context",
        [Parameter(Mandatory=$false)][String]$MessageColor = $FontColor.Base
    )

    $LoggerFunctions.Debug(("Current Computer: $($env:COMPUTERNAME)","Current User: $($env:USERNAME)"))

    $RegistrationType = "Template Context"
    $RegistrationVariable = $RegistrationType.Replace(' ','')
    
    do {
        if($NonInteractive -and [String]::IsNullOrEmpty($Context)){
                $LoggerFunctions.Error(($Strings.UndefinedNonInterfactive -f ($RegistrationType, $RegistrationVariable)), $NonInteractive)
                exit
        
        } elseif([String]::IsNullOrEmpty($Context)){
            $LoggerFunctions.Debug("Getting certificate template context value from user input.")

            $Context = Read-HostChoice `
                -Message $Message `
                -Choices "Computer","User" `
                -HelpText "Uses '$($env:COMPUTERNAME)' permissions for computer enrollment","Uses '$($env:USERNAME)' permissions for user enrollment" `
                -Default 1

            $RegistrationTemplate = "$($Strings.RegisterUserProvided -f ($RegistrationType, $Context))"

        } else { 
            if($Context -notin  ("Computer","User")){
                $LoggerFunctions.Error("Provided ertificate template context was '$Context'. It mmust be either 'Computer' or 'User'.", $NonInteractive)
                $Context = $null
            } else {
                $RegistrationTemplate = "$($Strings.RegisterImported -f ($RegistrationType, $Context))" 
            }
        }

    } until($Context)

    $LoggerFunctions.Register($RegistrationTemplate)
    return $Context
}

function Register-CertificateEnrollmentPolicyServer {
    param(
        [Parameter(Mandatory)][Uri]$AliasUri,
        [Parameter(Mandatory)][ValidateSet("Machine","User")][String]$Context
    )

    $RegistrationType = "Certificate Enrollment Policy Server"
    try {

        $ResultsAddCep = Add-CertificateEnrollmentPolicyServer `
            -Url $AliasUri `
            -Context $Context `
            -AutoEnrollmentEnabled `
            -RequireStrongValidation

        return $True

    } catch {

        #$LoggerFunctions.Exception($_)

        # Convert error record to string
        $ErrorMessage = $_.Exception.Message | Out-String
        $LoggerFunctions.Error($ErrorMessage)

        # Substring exception message
        $ErrorSearch = $ErrorMessage.Substring(0,$ErrorMessage.IndexOf("0x"))
        $ErrorSearch.Substring($ErrorSearch.LastIndexOf(":")+1).Trim()
        #$ErrorHexCode = $ErrorSearch.Split('')[0]
        #$ErrorMessage = $ErrorSearch.Substring($ErrorSearch.LastIndexOf(":").Split()).Trim()
        
        # $ErrorMessage = $ErrorSearch.Split('')[1]

        # $ErrorMessageSearch = $ErrorMessage.Substring(0,$ErrorMessage.IndexOf("0x"))
        # $ErrorRecord = [PSCustomObject]@{
        #     ErrorCode = $ErrorHexSearch.Split()[0]
        #     ErrorMessage = $ErrorMessageSearch.Substring($ErrorMessage.LastIndexOf(":")+1).Trim()
        # }

        # $LoggerFunctions.Debug("Parsed policy server configuration error: $($ErrorRecord|Out-TableString)")
        return $ErrorHexCode
    }
}