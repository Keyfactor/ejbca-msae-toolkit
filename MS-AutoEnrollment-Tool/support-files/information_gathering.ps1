<#
MSAE Auto-Enrollment Support Script - Information Gathering script

Description:
This script is called by the "main" script and contains all the information gathering steps on the domain.

Author:
Jamie Garner
Initial write date 7/19/22

Change Log:
Date             Author              Changes

#>

#The powershell modules included with Windows Server Remote Server Administration Tools are necessary to query Active Directory
#NEED ERROR HANLDING
Write-Host "Checking to see if the AD DS and LDS tool is installed..." -ForegroundColor Yellow
$rsatAdldsInstalled = Get-WindowsFeature -Name RSAT-ADDS-Tools | select InstallState
    
if($rsatAdldsInstalled.InstallState -ne 'Installed'){
try{
     
    Install-WindowsFeature -Name RSAT-ADDS-Tools -ErrorAction Stop Sucessfully
    Write-Host "The AD DS and LDS tool successfully installed..." -ForegroundColor Yellow
    
    }
    catch {
    [System.Windows.Forms.Messagebox]::Show("The AD DS and LDS tool DID NOT successfully install!`n

You need to manually install the tool using Server Manager and run the script again. The script will now exit.")
    
    Exit
    }
}    

## Manually Inputs ##
<#
#Service Account
$svcAccount=[Microsoft.VisualBasic.Interaction]::InputBox("Enter the Service Account name used for MSAE.","Service Account Name")
    if([string]::IsNullOrEmpty($svcAccount) -eq $true){
    [System.Windows.Forms.MessageBox]::Show("You have not entered a Service Account name. You will need to run this script again.")
        Exit
}

#Policy Server
$policyServerFQDN=[Microsoft.VisualBasic.Interaction]::InputBox("Enter the FQDN of the Policy Server or Load Balancer for EJBCA.", "Policy Server Endpoint")
    if([string]::IsNullOrEmpty($policyServerFQDN) -eq $true){
    [System.Windows.Forms.MessageBox]::Show("You have not entered a Policy Server FQDN. You will need to run this script again.")
        Exit 
}
#>

$svcAccount = "svc_account"
$policyServerFQDN = "policyserver.local.host"

#Combine provided Policy Server FQDN in HTTP to create SPN to match with during checks
$policyServerSPN = "HTTP/"+"$policyServerFQDN"

##SERVICE ACCOUNT##
# Query service account for necessary attributes
$svcAccountAttrs = Get-ADUser $svcAccount -Properties * | Select DistinguishedName,UserPrincipalName,KerberosEncryptionType,ServicePrincipalNames,MemberOf
$svcAccountDN = $svcAccountAttrs.DistinguishedName

#Add to log if DEBUG enabled
if($logLevel -eq "DEBUG"){
$tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
Add-Content $PSScriptRoot\$msaeLog "$tlog -- DEBUG: [SERVICE ACCOUNT] The $svcAccount Distinguished Name is $svAccountDN"
}

$svcAccountUPN = $svcAccountAttrs.UserPrincipalName
$domainSuffix = $svcAccountUPN.Substring($svcAccountUPN.IndexOf("@"))

#Add to log if DEBUG enabled
if($logLevel -eq "DEBUG"){
$tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
Add-Content $PSScriptRoot\$msaeLog "$tlog -- DEBUG: [SERVICE ACCOUNT] The $svcAccount UPN is $svcAccountUPN"
}

$svcAccountKerb=$svcAccountAttrs.KerberosEncryptionType
$svcAccountKerb=foreach($kerb in $svcAccountKerb){

    ($kerb -split ",").Trim()

    #Add to log if DEBUG enabled
    if($logLevel -eq "DEBUG"){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- DEBUG: [SERVICE ACCOUNT] $svc_account supports key type $kerb"
        }
    }

#Grab Service Principal Names
$svcAccountSPN=$svcAccountAttrs.ServicePrincipalNames
$svcAccountSPN=foreach($spn in $svcAccountSPN){

    ($spn -split " ")

    #Add to log if DEBUG enabled
    if($logLevel -eq "DEBUG"){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- DEBUG: [SERVICE ACCOUNT] $svc_account contains the the Service Principal Name $spn"
        }
    }

#Grab Security Group membership
$svcAccountSG=$svcAccountAttrs.MemberOf
$svcAccountSG=foreach($sg in $svcAccountSG){

    ($sg -split "CN")

    #Add to log if DEBUG enabled
    if($logLevel -eq "DEBUG"){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- DEBUG: [SERVICE ACCOUNT] $svc_account is a member of the following group $sg"
        }
    }

##Keytab File##
#Get Keytab file and output to support bundle directory
<#
Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = “All files (*.*)| *.*”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename

}

#Write-Host "Next select the keytab file for this domain that is associated with the MSAE alias in EJBCA. Hit enter to continue..." -ForegroundColor Yellow -NoNewline; Read-Host

[System.Windows.Forms.Messagebox]::Show("Next select the keytab file for this domain that is associated with the MSAE alias in EJBCA")
$keytab_file = Get-FileName -initialDirectory 'C:\'
#>
$keytabFile = Get-Item "C:\svc_account.keytab"

#Dump keytab file and output to support bundle directory
#The dump is necesssary because NativeOutputErrors will not store the dump directory in a variable
ktpass -in $keytabFile > "$supportBundleDir\tmp_keytab_dump" 2>&1

#Import keytab file as csv
$keytabFileContents = Import-Csv "$supportBundleDir\tmp_keytab_dump"

#Store NativeOutputError lines in new string and split into individual lines for parsing
$str = $keytabFileContents -split [environment]::NewLine

#Loop through each line and look only for the ktpass output identified by 'keysize' in the $keytab_file_contents variable
#Each line is trimmed to include only the name
foreach ($line in $str) {

    if($line -like '*keysize*') {

    #Cleaning string to exclude excess ktpass contents
    ($line = $line.Substring($line.IndexOf('=')+1)) | Out-Null
        
    #Spliting string to parse for keytabUPN and keytabSPN
    ($line2 = $line.Split(" ")) | Out-Null
    
    foreach($princ in $line2){

        #Filter for HTTP line in split string variable
        if($princ -like 'HTTP*'){
            
            #Used to capture SPN and domain suffix for case-sensitive check
            $keytabUPN = $princ

            #Used in capture SPN for match with service account SPN
            ($princ=$princ.Substring(0,$princ.IndexOf('@'))) | Out-Null
            $keytabSPN = $princ
        }}

    #Add to log if DEBUG enabled
    if($logLevel -eq "DEBUG"){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msaeLog "$tlog -- DEBUG: [KEYTAB] The keytab dump contains: $line"
    }
    
    #Check for an AES-256 key in the keytab
    if ($line -like '*0x12*') {

    $keytabFileContents = $line

    #Store for later use in a check
    [bool]$keytabNoAES=$true

        }
    }
} 


# Remove temporary keytab file after contents are imported to variable and written to msae.log
#Remove-Item "$supportBundleDir\tmp_keytab_dump"

#$keytab_file_contents = New-Item "C:\svc2_account.keytab" -Force

## AutoEnroll Computer ##
#Get computer security memberships
$computer = Get-ADComputer $env:COMPUTERNAME -Property * | Select *
if($computer.PrimaryGroup -like '*Domain Controllers*'){
    [bool]$computerIsDC=$true

    #Add to log if DEBUG enabled
    if($logLevel -eq "DEBUG"){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msae_log "$tlog -- DEBUG: [COMPUTER] $env:COMPUTERNAME is a Domain Controller"
        }
    }

#Split into individual lines for parsing
$str = $computer.MemberOf -split [environment]::NewLine

#Each line is trimmed to include only the name
$supportCompSG = foreach($group in $str){

    $group=$group.Substring(0,$group.IndexOf(','))
    ($group=$group.Substring($group.IndexOf('=')+1))

    #Add to log if DEBUG enabled
    if($logLevel -eq "DEBUG"){
    $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
    Add-Content $PSScriptRoot\$msae_log "$tlog -- DEBUG: [COMPUTER] $env:COMPUTERNAME is a member of the security group: $group"
    }
}

##Certificate Templates##
#Get Certificate templates used for MSAE
$certificateTemplates = certutil -template

#Store certificate templates in new string and split into individual lines for parsing
$str = $certificateTemplates -split [environment]::NewLine

#Loop through each line and store the TemplatePropCommanName in the $certificate_templates variable
#Each line is trimmed to include only the name
$certificateTemplates = foreach ($line in $str) {

    if ($line -like '*TemplatePropCommonName*') {

    ($line -split "=")[1].Trim()

    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'MSAE Mapped Certificate Templates'
$form.Size = New-Object System.Drawing.Size(400,415)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(90,340)
$okButton.Size = New-Object System.Drawing.Size(32,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(135,340)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select the certificate templates in Active Directory that are mapped in EJBCA":'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(360,20)

$listBox.SelectionMode = 'MultiExtended'

foreach($template in $certificateTemplates){

[void] $listBox.Items.Add($template)

}

$listBox.Height = 300
$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

#Log selected certificate templates in $selected_cert_templates
if ($result -eq [System.Windows.Forms.DialogResult]::OK){
    $selectedCertTemplates = $listBox.SelectedItems
}

#Exit script if cancelled or dialog box was closed was selected in the MSAE Mapped Certificate Templates
if ($result -ne [System.Windows.Forms.DialogResult]::OK){
    exit
}

#Dump each certificate template into support bundle
foreach($template in $selectedCertTemplates){

    certutil -v -template "$template" | Out-File "$supportCertTemplatesDir\$template.txt"
    Write-Host "$template successfully dumped!" -ForegroundColor Yellow

}