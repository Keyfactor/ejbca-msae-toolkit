<#
MSAE Auto-Enrollment Support Script

Description:
This script is designed to validate an already configured MS Auto-Autoenrollment (MSAE) EJBCA Integration. 

Author:
Jamie Garner
Initial write date 7/19/22

Change Log:
Date             Author              Changes
 
#>

## Log Level ##
#Change to 'DEBUG' for additional logging
$logLevel= 'INFO'

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

## README Confirmation for User ##
$readme_verify=[System.Windows.Forms.MessageBox]::Show("Have you read the README accompanied with this script?

The README contains important on how the script functions, required authorization, tools, and EJBCA MSAE configuration information the script asks for.

If you have not the README, select 'No' to exit the script.", 'README Verification', 'YesNo', 'Info')

if($readme_verify -eq 'No'){
Exit
}

## Variables ##
#Script Operator
$scriptOperator=$env:UserName

#Timestamp for log and files
$tfile = Get-Date -Format "yyyyMMdd"

#Support bundle dir
$supportBundleDir = "$PSScriptRoot\msae_support_bundle"

#Remove old support bundle directory and create a new one
Remove-Item $supportBundleDir -Recurse -ErrorAction SilentlyContinue | Out-Null
New-Item $supportBundleDir -ItemType Directory | Out-Null
Write-Host "Sucessfully created the Support Bundle directory" -ForegroundColor Yellow

#Certificate template dump dir
$supportCertTemplatesDir = "$supportBundleDir\certificate_templates"
New-Item $supportCertTemplatesDir -ItemType Directory | Out-Null
Write-Host "Sucessfully created the Certificate Templates directory" -ForegroundColor Yellow
  
#MSAE default dir and log name
$msaeLog = "msae.log"
New-Item $PSScriptRoot\$msaeLog -ErrorAction SilentlyContinue| Out-Null
Write-Host "Sucessfully created the MSAE Log file" -ForegroundColor Yellow

#Import information gathering script
. "$PSScriptRoot\supporting_scripts\information_gathering.ps1"

##Checks##
#SPN Check
#Service account is correct
if($svcAccountSPN -eq $policyServerSPN){
$tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][1/10] The service account SPN matches the required Server Principal Name: $policyServerSPN"
[bool]$spnCheck=$true

    #Service account is incorrect
    if($svcAccountSPN -ne $policyServerSPN){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- ERROR: [VALDATION CHECK][1/10] The service account SPN does not match the required Server Principal Name: $policyServerSPN"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][1/10] Update the service account SPN to match required Server Principal Name: $policyServerSPN"
    [bool]$spnCheck=$false
    }
}

#Principal Name Check
#Build policyserverUPN by adding the SPN and domainSuffix
$policyServerUPN = "$policyServerSPN"+"$domainSuffix"

#Parse keytab UPN for domain suffix
$keytabUPNCase = $keytabUPN.Substring($keytabUPN.IndexOf('@')+1)

#Build keytab UPN lower case domain suffix for comparison
$keytabUPNLowerCase = $keytabUPNCase.ToLower()

#Compare keytab UPN with lowercase UPN and build variable to insert into logs
if($keytabUPNCase -eq $keytabUPNLowerCase){$keytabUPNLowerCase2="Make sure to capitalize '$keytabUPNLowerCase'."}

#Both are correct
if(($keytabUPN -eq $policyServerUPN) -and ($svcAccountUPN -eq $policyServerUPN)){
$tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][2/10] The keytab file and service account both contain the correct Principal Name and they match the required Principal Name: $policyServerUPN"
[bool]$keytabUpnCheck=$true

    #The keytab is correct and the service account is incorrect
    if(($keytabUPN -eq $policyServerUPN) -and ($svcAccountUPN -ne $policyServerUPN)){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- ERROR: [VALDATION CHECK][2/10] The keytab file contains the correct Principal Name, but the service account does not match. Current: $keytabUPN, Required: $policyServerUPN"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][2/10] Update the service account Principal. Current: $keytabUPN, Required: $policyServerUPN"
    [bool]$keytabUpnCheck=$false

        #The keytab is incorrect and the service account is correct
        if(($keytabUPN -ne $policyServerUPN) -and ($svcAccountUPN -eq $policyServerUPN)){
        $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
        Add-Content $PSScriptRootr\$msaeLog "$tlog -- ERROR: [VALDATION CHECK]2/10] The service account is set to the correct Principal Name, but the keytab file does not match. Current: $keytabUPN, Required: $policyServerUPN"
        Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][2/10] Recreate the keytab file with the correct Principal Name. $keytabUPNLowerCase2 Current: $keytabUPN, Required: $policyServerUPN" 
        [bool]$keytabUpnCheck=$false

            #Both are incorrect
            if(($keytabUPN -ne $policyServerUPN) -and ($svcAccountUPN -ne $policyServerUPN)){
            $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
            Add-Content $PSScriptRoot\$msaeLog "$tlog -- ERROR: [VALDATION CHECK][2/10] Neither the keytab file or the service are match the required Principal Name: $policyServerUPN"
            Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][2/10] Update the service account Principal Name. Current: $keytabUPN, Required: $policyServerUPN"
            Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][2/10] Recreate the keytab file with the correct Principal Name. $keytabUPNLowerCase2 Current: $keytabUPN, Required: $policyServerUPN" 
            [bool]$keytabUpnCheck=$false
            }
        }
    }
}

#Service Account and AES-256 Key Check [1/10]

#Both support AES256
if($keytabNoAES -eq $true -and $svcAccountKerb -contains 'AES256'){
$tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][3/10] The keytab file and service account both support AES-256 "
[bool]$encKeyCheck=$true
    
    #Only service account supports AES256
    if($keytabNoAES -eq $false -and $svcAccountKerb -contains 'AES256'){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- ERROR: [VALDATION CHECK][3/10] The keytab file does not contain an AES-256 key but the service account supports AES-256"
    Add-Content $PSScriptRootr\$msaeLog "$tlog -- INFO: [VALDATION CHECK][3/10] Recreate the keytab file with the argument '-crypto' set to 'AES-256'"
    [bool]$encKeyCheck=$false
        
        #Only keytab file supports AES256
        if($keytabNoAES -eq $true -and $svcAccountKerb -notcontains 'AES256'){
        $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
        Add-Content $PSScriptRoot\$msaeLog "$tlog -- ERROR: [VALDATION CHECK][3/10] The keytab file contains an AES-256 key, but the service account does not supports AES-256"
        Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][3/10] Update the service account 'Profile' tab to 'This account supports Kerberos AES 256 bit encryption'"
        [bool]$encKeyCheck=$false

            #Neither support AES256
            if($keytabNoAES -eq $true -and $svcAccountKerb -notcontains 'AES256'){
            $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
            Add-Content $PSScriptRoot\$msaeLog "$tlog -- ERROR: [VALDATION CHECK][3/10] The keytab file contains an AES-256 key, but the service account does not supports AES-256"
            Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][3/10] Recreate the keytab file with the argument '-crypto' set to 'AES-256'"
            Add-Content $PSScriptRoot\$msaeLog "$tlog -- INFO: [VALDATION CHECK][3/10] Update the service account 'Profile' tab to 'This account supports Kerberos AES 256 bit encryption'"
            [bool]$encKeyCheck=$false
            }
        }
    }
}

#KRB5.conf Check

#Computer Permissions Check


#Confirmation of Prelimingary Checks before proceeding with auto-enrollment test
[System.Windows.Forms.MessageBox]::Show("The following valid checks have been performed and failed:

$validation_checks

All logging and validation checks have been written to the $PSScriptRoot\$msaeLog and a compressed support bundle has been generated. 

You can now proceed with the following before running the 'Testing Tool':

- Provide the Support Bundle to KF Product Support for a new or open case
- Review the $msaeLog for any failures and make any necessary changes
- Run the 'Configuration Tool' automate the remediation of any failed check"
,'Validation Checks','OK', 'Info') | Out-Null


Write-Host "Copying msae.log file to Support Bundle..." -ForegroundColor Yellow

#Copy msae.log to 
Copy-Item $PSScriptRoot\$msaeLog $supportBundleDir
Write-Host "Compressing Support Bundle..." -ForegroundColor Yellow

#Create archive path with current date
$supportArchive="msae_support_" + (Get-Date).tostring("dd-MMM-yyyy")
Compress-Archive -Path $supportBundleDir -DestinationPath $PSScriptRoot\$supportArchive -CompressionLevel Optimal -Force
Write-Host "Support bundle $supportArchive has been generated and is located in the $PSScriptRoot directory." -ForegroundColor Yellow




