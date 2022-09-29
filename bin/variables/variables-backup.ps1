# Frameworks to add
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# System variables
$Global:ScriptOperator = $ENV:USERNAME
$Global:ScriptComputer = $ENV:COMPUTERNAME

# Logging
$LogFileDir = "$PSScriptRoot\logs"
#$LogFile = "$LogFileDir\toolkit.log"
$LogFileToolKit = "$LogFileDir\toolkit.log"
$LogFileValidation = "$LogFileDir\validation.log"
$LogFileTesting = "$LogFileDir\testing.log"
$LogFiles = @(
    "toolkit.log",
    "validation.log",
    "testing.log"
)



# Cep Validation
$CepCert = "$ScriptRoot\tmp\cepserver.crt"
$CertOutputDir = "$ScriptRoot\tmp\"

# Support Bundle
$SupportBundleDir = "$ScriptRoot\Support-Bundle"
$SupportBundleSourceDirs = @(
    $LogFileDir
)

## Service Account
# Name
$Global:SvcAccount = $null
# Attributes to query
$SvcAccountAttributes = @(
    "UserPrincipalName",
    "DistinguishedName",
    "ServicePrincipalNames",
    "MemberOf",
    "KerberosEncryptionType"
)
$Global:PolicyServer = $null
$Global:policyServerSPN = $null
$Global:policyServerPN = $null
$Global:MsaeAlias = $null
$Global:CepUrl = "https://$Global:PolicyServer/ejbca/msae/CEPService?$Global:MsaeAlias"

## Prompts
# README
$ReadMeConfirmationText = "Have you read the README accompanied with this script? The README contains important" + 
"on how the script functions, required authorization, tools, and EJBCA MSAE configuration information the script asks for?"
# Service Account
$PromptSvcAccountText = "Enter the Service Account name used for MSAE"
# Cep Server
$PromptCepServerText = "Enter the Certificate Enrollment Policy (CEP) FQDN used for MSAE"

# # global variables set when running tool
# $forestName = Get-ADDomain
# $Global:forestName = ($forestName.Forest).ToUpper()

# $Global:policyServerSPN = "HTTP/" + $Global:policyServer
# $Global:policyServerPN = $Global:policyServerSPN + '@' + $Global:forestName
# # $Global:keytabFile = $null
# $Global:keytabFile = Get-Item "C:\users\jamie\desktop\aes256_account_good.keytab"
# # $Global:krb5ConfFile = $null
# $Global:krb5ConfFile = Get-Item "C:\users\jamie\desktop\krb5-working.conf"
# # $Global:certificateTemplates = @()
# $Global:certificateTemplates = @(
#   "MSAE - Domain Controller Authentication",
#   "MSAE - Computer"
# )

# $Global:templateDumpSuccess = $false
# # ejbca certificate
# $Global:tlsServerIssuer = $null
# $Global:certCaCheck = $false

# # service account
# $Global:svcAccountAttrs = $null
# $Global:svcAccountDN = $null
# $Global:svcAccountSPN = $null
# $Global:svcAccountUPN = $null
# $Global:svcAccountSG = $null
# $Global:svcAccountKerbType = $null

# # keytab file
# $Global:keytabFileContents = $null
# $Global:keytabFileEncType = $null
# $Global:keytabFilePN = $null

# # computer account
# $Global:clientComputerAttrs = $null
# $Global:clientComputerPG = $null
# $Global:clientComputerSG = @()
# $Global:clientComputereAutoEnrollGroups = @()

# # user account
# $Global:clientUserAttrs = $null
# $Global:clientUserPG = $null
# $Global:clientUserSG = @()
# $Global:certTemplateAutoEnrollGroups = @()

# <# validation checks #>
# # service account
# [bool]$Global:svcAccountSPNSuccess = $false
# [bool]$Global:svcAccountKerbSuccess = $false
# [bool]$Global:svcAccountSGSuccess = $false

# # keytab
# [bool]$Global:keytabAESSuccess = $false
# [bool]$Global:keytabPNSuccess = $false

# # computer account
# [bool]$Global:compAccountSGSuccess = $false
# [bool]$Global:compAccountAutoEnrollSuccess = $false
# [bool]$Global:compAccountSuccess = $false

# # certificate templates
# [bool]$Global:certTemplateSubjectNameSuccess = $false
# # group policy
# [bool]$Global:groupPolicyCEPConfiguredSuccess = $false
# [bool]$Global:groupPolicyAutoEnrollEnabledSuccess = $false
# # certificate trust store
# [bool]$Global:rootTrustStoreUpdatedSuccess = $false
# [bool]$Global:intermediateTrustStoreUpdatedSuccess = $false
# # crl
# [bool]$Global:downloadEjbacCrlSuccess = $false

# <# testing checks #>
# # enrollment test
# $Global:enrollmentTestTempalate

# # policy server tls valid common name
# [bool]$Global:policyServerTlsValidCNSuccess = $false
# # gpo enforcement of aes256
# [bool]$Global:groupPolicyAES256EnforcedSuccess = $false

