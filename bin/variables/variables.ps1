# Script Root
$ScriptRoot = "\\surface\Users\jamie\OneDrive\Documents\Programming\MSAE-Tool"

# Form image
$KeyfactorImage = [System.Drawing.Image]::FromFile("$ScriptRoot\images\keyfactor_logo.png")

# System variables
$Global:Operator = $ENV:USERNAME
$Global:Computer = $ENV:COMPUTERNAME
$Global:Domain = ((Get-ADDomain).Forest).ToUpper()

# Logging
$LogFileDir = "$ScriptRoot\logs"
#$LogFile = "$LogFileDir\toolkit.log"
$LogFileToolKit = "$LogFileDir\toolkit.log"
$LogFileValidation = "$LogFileDir\validation.log"
$LogFileTesting = "$LogFileDir\testing.log"
$LogFiles = @(
    "toolkit.log",
    "validation.log",
    "testing.log"
)

# Tool selection
$ToolKitConfigurationSelected = $true
$ToolKitValidationSelection = $null
$ToolKitTestingSelected = $null
$ToolKitSupportBundleSelected = $null

# Form answers provided by user
$Global:ServiceAccountCreateNew = $null

# Cep Validation
$CepCert = "$ScriptRoot\tmp\cepserver.crt"
$CertOutputDir = "$ScriptRoot\tmp\"

# Support Bundle
$SupportBundleDir = "$ScriptRoot\Support-Bundle"
$SupportBundleSourceDirs = @(
    $LogFileDir
)

## Service Account
$Global:ServiceAccount = $null
$Global:ServiceAccountPassword = $null
$Global:ServiceAccountOrgUnitDN = $null
$Global:ServiceAccountPasswordExpiry = $null
$Global:ServiceAccountCertPublisher = $null
$Global:SvcAccountAttributes = $null
$Global:SvcAccountExists = $null
$Global:SvcAccountCreate = $null

# Attributes to query
$Global:ServiceAccountAttributes = @(
    "UserPrincipalName",
    "DistinguishedName",
    "ServicePrincipalNames",
    "MemberOf",
    "KerberosEncryptionType"
)
$Global:ValidatedServiceAccount = $null

# Cep Server
$Global:CepServer = 'policy.keyfactor.com'
$Global:CepServerSPN = "HTTP/$Global:CepServer"
$Global:CepServerUPN = "$Global:CepServerSPN@$Global:Domain"
$Global:MsaeAlias = "working-alias"
$Global:CepUrl = "https://$Global:PolicyServer/ejbca/msae/CEPService?$Global:MsaeAlias"

$Global:ValidationCepServer = $null


## Prompts and Messageboxes
# Windows forms or console input
$WindowsForms = $false

# Enable all prompts. Set to true to override all individual settings listed below
$EnableAllPrompts = $true

# README
$PromptReadMe = $false
$ReadMeConfirmationText = "Have you read the README accompanied with this script? The README contains important" + 
"on how the script functions, required authorization, tools, and EJBCA MSAE configuration information the script asks for?"

# Service Account
$PromptSvcAccountGet = $false
$PromptSvcAccountGetText = "Enter the Service Account name used for MSAE"
$PromptSvcAccountCreate = $true
$Global:LdapDnTextDefault = 'A partial or complete of an OU is required to Search'

# Cep Server
$PromptCepServer = $false
$PromptCepServerText = "Enter the Certificate Enrollment Policy (CEP) FQDN used for MSAE"

## Other testing switches
$TestingEnableAllSwitches = $false
$TestingDomainJoinedComputer = $false