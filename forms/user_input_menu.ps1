Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear();

$Global:svcAccount = $null
$Global:policyServer = $null
$Global:certificateTemplates = $null
$Global:templateDumpSuccess = $false
$templateDumpDirectory = "$PSScriptRoot\msae_template_dump\"


$logFile = "$PSScriptRoot\toolkit.log"
Remove-Item  $logFile -Force

# Start validation

function WriteLog
{
Param ([string]$logString)
$timeStamp = (Get-Date).toString("yyyyMMdd HH:mm:ss")
$logMessage = "$timeStamp $logString"
Add-content $logFile -value $logMessage
}

WriteLog "------BREAK-----"

# keytab file selection
$keytabBrowse_Click = {

    $Global:keytabFile = $null

    $userInputMenuKeytabInput.ShowDialog()
    $userInputMenuKeytabSelectedFile.Text = $userInputMenuKeytabInput.FileName

}

# krb5 conf file selection
$krb5_Click = {

    $Global:krb5ConfFile = $null
    
    $userInputMenuKrb5Input.ShowDialog()
    $userInputMenuKrb5SelectedFile.Text = $userInputMenuKrb5Input.FileName

}

$defaultCertificateTemplates = certutil -template

#Store certificate templates in new string and split into individual lines for parsing
$str = $defaultCertificateTemplates -split [environment]::NewLine

#Loop through each line and store the TemplatePropCommanName in the $certificate_templates variable
#Each line is trimmed to include only the name
$defaultCertificateTemplates = foreach ($line in $str) {

    if ($line -like '*TemplatePropCommonName*') {

    ($line -split "=")[1].Trim()

        }
}

$selectTemplate_Click = {

    $Global:certificateTemplates = $null

    $userInputMenuCertTemplatesSelectForm = New-Object System.Windows.Forms.Form
    $userInputMenuCertTemplatesSelectForm.Text = 'MSAE Mapped Certificate Templates'
    $userInputMenuCertTemplatesSelectForm.Size = '400,415'
    $userInputMenuCertTemplatesSelectForm.StartPosition = 'CenterScreen'

    $userInputMenuCertTemplatesSelectOk = New-Object System.Windows.Forms.Button
    $userInputMenuCertTemplatesSelectOk.Location = '150,340'
    $userInputMenuCertTemplatesSelectOk.Size = '60,23'
    $userInputMenuCertTemplatesSelectOk.Text = 'Select'
    $userInputMenuCertTemplatesSelectOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $userInputMenuCertTemplatesSelectForm.AcceptButton = $userInputMenuCertTemplatesSelectOk
    $userInputMenuCertTemplatesSelectForm.Controls.Add($userInputMenuCertTemplatesSelectOk)

    $userInputMenuCertTemplatesSelectCancel = New-Object System.Windows.Forms.Button
    $userInputMenuCertTemplatesSelectCancel.Location = '250,340'
    $userInputMenuCertTemplatesSelectCancel.Size = '75,23'
    $userInputMenuCertTemplatesSelectCancel.Text = 'Cancel'
    $userInputMenuCertTemplatesSelectCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $userInputMenuCertTemplatesSelectForm.CancelButton = $userInputMenuCertTemplatesSelectCancel
    $userInputMenuCertTemplatesSelectForm.Controls.Add($userInputMenuCertTemplatesSelectCancel)

    $userInputMenuCertTemplatesSelectTitle = New-Object System.Windows.Forms.Label
    $userInputMenuCertTemplatesSelectTitle.Location = '10,20'
    $userInputMenuCertTemplatesSelectTitle.Size = '350,20'
    $userInputMenuCertTemplatesSelectTitle.Text = 'Select the certificate templates mapped in the EJBCA MS alias:'
    $userInputMenuCertTemplatesSelectForm.Controls.Add($userInputMenuCertTemplatesSelectTitle)

    $userInputMenuCertTemplatesSelectList.SelectionMode = 'MultiExtended'

    foreach($template in $defaultCertificateTemplates){

    [void] $userInputMenuCertTemplatesSelectList.Items.Add($template)

    }

    $userInputMenuCertTemplatesSelectList.Height = 275
    $userInputMenuCertTemplatesSelectForm.Controls.Add($userInputMenuCertTemplatesSelectList)
    $userInputMenuCertTemplatesSelectForm.Topmost = $true

    $result = $userInputMenuCertTemplatesSelectForm.ShowDialog()

    # check the dialog result
    if ($result -eq [System.Windows.Forms.DialogResult]::OK){

        # result boolean value after new selection
        $Global:templateDumpSuccess = $false

        # set selection to orange and load items to text field
        $userInputMenuCertTemplatesSelected.ForeColor = 'orange'
        $userInputMenuCertTemplatesSelected.Text = $userInputMenuCertTemplatesSelectList.SelectedItems

        # place selected certificate templates into the global variable
        $Global:certificateTemplates = $userInputMenuCertTemplatesSelectList.SelectedItems

        # write to log
        WriteLog "INFO: $Global:certificateTemplates has been selected as the certificate templates"

        if([string]::IsNullOrEmpty($userInputMenuKeytabInput.FileName) -ne 'False' -and `
           [string]::IsNullOrEmpty($userInputMenuKrb5Input.FileName) -ne 'False'){

           $userInputMenu.Controls.Add($userInputMenuCheckButton)

            }

    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
        $userInputMenuCertTemplatesSelectForm.Close()
        
        }

    }

}

$check_Click = {

# remove status title and next button if check clicked again
$userInputMenu.Controls.Remove($userInputMenuNextButton)

# clear check status if check is clicked again
$userInputMenuCheckStatus.Text = $null

<# 
    
service account - validate service account is accesible, exists, and is enabled

#>

# if service account has not been validated
if([string]::IsNullOrEmpty($Global:svcAccount)){

    # if text has not been entered, user is informed
    if([string]::IsNullOrEmpty($userInputMenuSvcAcctInput.Text)){
    
        # change color to orange, inform user validation is occuring, and write to log
        $userInputMenuSvcAcctInputValidate.ForeColor = 'red'
        $userInputMenuSvcAcctInputValidate.Text = "Service account name field cannot be empty"

        # reset global policy server variable if previously validated but cleared by user
        $Global:svcAccount = $null
        
        } 

    if([string]::IsNullOrEmpty($userInputMenuSvcAcctInput.Text) -ne 'False'){

        # write to log
        WriteLog "INFO: '$($userInputMenuSvcAcctInputValidate.Text)' has been selected as the service account"

        # change color to orange and inform user validation is occuring
        $userInputMenuSvcAcctInputValidate.ForeColor = 'orange'
        $userInputMenuSvcAcctInputValidate.Text = "Verifying '$($userInputMenuSvcAcctInput.Text)' exists..."

        try {

        # add suspense
        start-sleep -s 1

        # check if the dns record exists and stop if it does not exists
        $svcAccountExists = Get-ADUser $userInputMenuSvcAcctInput.Text -Properties * -ErrorAction Stop

        # write to log
        WriteLog "INFO: '$($userInputMenuSvcAcctInputValidate.Text)' was found in $((get-addomain).forest)"

        # add suspense
        start-sleep -s 1
        
        # check if account status is enabled
        switch($svcAccountExists.Enabled){

            'True'{

                # if text has been entered, the name is stored in a global variable
                $userInputMenuSvcAcctInputValidate.ForeColor = 'green'
                $userInputMenuSvcAcctInputValidate.Text = "'$($userInputMenuSvcAcctInput.Text)' is a valid and enabled account!"

                # store file in global var
                $Global:svcAccount = $userInputMenuSvcAcctInput.Text

                # write to log
                WriteLog "INFO: $($userInputMenuSvcAcctInputValidate.Text)"
            }

            'False'{

                # text color changed to red if service account is disabled
                $userInputMenuSvcAcctInputValidate.ForeColor = 'red'
                $userInputMenuSvcAcctInputValidate.Text = "'$($userInputMenuSvcAcctInput.Text)' is disabled. Re-enable before running the 'Check' again."

                # write to log
                WriteLog "INFO: $($userInputMenuSvcAcctInputValidate.Text)"

            }

            $null {

                # text color changed to red if user doesnt have right to read the account
                $userInputMenuSvcAcctInputValidate.ForeColor = 'red'
                $userInputMenuSvcAcctInputValidate.Text = "'$env:username' cannot read the 'Enabled' attribute due to insufficient rights."

                # write to log
                WriteLog "INFO: $($userInputMenuSvcAcctInputValidate.Text)"
                
            }

        }

        # add suspense
        start-sleep -s 1

            } catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            
                # change text to red and inform user
                $userInputMenuSvcAcctInputValidate.ForeColor = 'red'
                $userInputMenuSvcAcctInputValidate.Text = "'$($userInputMenuSvcAcctInput.Text)' does not exist in Active Directory"

                # write to log
                WriteLog "ERROR: $($userInputMenuSvcAcctInputValidate.Text)"

            } catch {

                # change text to red and inform user
                $userInputMenuSvcAcctInputValidate.ForeColor = 'red'
                $userInputMenuSvcAcctInputValidate.Text = "'$env:username does not have access to read '$($userInputMenuSvcAcctInput.Text)'"

                # write to log
                WriteLog "ERROR: $($userInputMenuSvcAcctInputValidate.Text)"

            }
        }
    }

<# 
   
policy server - validate policy server input, name resolution, and remote port 443

#>

# if policy server field has not been validated
if([string]::IsNullOrEmpty($Global:policyServer)){

    # if policy server field is empty, inform user
    if([string]::IsNullOrEmpty($userInputMenuPolicyServerInput.Text)){

        # change color to orange, inform user validation is occuring, and write to log
        $userInputMenuPolicyServerInputValidate.ForeColor = 'red'
        $userInputMenuPolicyServerInputValidate.Text = "Policy server name field cannot be empty"

        # reset global policy server variable if previously validated but cleared by user
        $Global:policyServer = $null
        
        } 

        if([string]::IsNullOrEmpty($userInputMenuPolicyServerInput.Text) -ne 'False'){

        # write to log policy server name has been stored
        WriteLog "INFO: '$userInputMenuPolicyServerInput' has been selected as the policy server"

        # change color to orange and inform user validation is occuring
        $userInputMenuPolicyServerInputValidate.ForeColor = 'orange'
        $userInputMenuPolicyServerInputValidate.Text = "Validating '$($userInputMenuPolicyServerInputValidate.Text)' network connection..."

        # write to log
        WriteLog "INFO: $($userInputMenuPolicyServerInputValidate.Text)"

        # add suspense
        start-sleep -s 1

        # try to resolved the provide policy server
        try {

            # check if the dns record exists and stop if it does not exists
            $policyServerDNS = Resolve-DnsName $userInputMenuPolicyServerInput.Text -Type A -ErrorAction Stop

            # add suspense
            start-sleep -s 1

            # inform user the dns record exists
            $userInputMenuPolicyServerInputValidate.Text = "A DNS record exists for '$($userInputMenuPolicyServerInput.Text)'. Checking if port 443 is open..."
            WriteLog "INFO: $($userInputMenuPolicyServerInputValidate.Text)"

            # check if port 443 is open and stop if the remote port is not listening
            Test-NetConnection -ComputerName $policyServerDNS.IPAddress -Port '443' -WarningAction Stop

            # change color to green and inform user the validation is success
            $userInputMenuPolicyServerInputValidate.ForeColor = 'green'
            $userInputMenuPolicyServerInputValidate.Text = "'$($userInputMenuPolicyServerInput.Text)' is reachable over port 443!" 

            # store in variable
            $Global:policyServer = $userInputMenuPolicyServerInput.Text

            # write to log
            WriteLog "INFO: $policyServerTemp can be resolved by DNS and is reachable over port 443"
        
            # catch dns error
            } catch [System.ComponentModel.Win32Exception] {

                # change text to red and inform user
                $userInputMenuPolicyServerInputValidate.ForeColor = 'red'
                $userInputMenuPolicyServerInputValidate.Text = "A DNS record does not exist for '$($userInputMenuPolicyServerInput.Text)'"

                # write to log
                WriteLog "ERROR: $($userInputMenuPolicyServerInputValidate.Text)"
            
            # catch remote port not listening warning
            } catch {
            
                # change text to red and inform user
                $userInputMenuPolicyServerInputValidate.ForeColor = 'red'
                $userInputMenuPolicyServerInputValidate.Text = "'$($userInputMenuPolicyServerInput.Text)' is unreachable over port 443!"



                # write to log
                WriteLog "ERROR: A DNS record for '$($userInputMenuPolicyServerInput.Text)' exists, but it unreachable over port 443!"
                
                }
            }
        }

<# 

keytab - validate keytab file has been selected based on file extension

#>

# checks selected keytab file extension is keytab
if((Get-Item $userInputMenuKeytabInput.FileName).Extension -ne ".keytab"){

    # if the file type is not keytab, the user is informed
    $userInputMenuKeytabSelectedFile.ForeColor = 'red'
    $userInputMenuKeytabSelectedFile.Text = "The selected file is not a keytab file. Select a validate keytab file!"

    } else {

        # if a valid keytab file has been selected, the text is changed to green and user informed
        $userInputMenuKeytabSelectedFile.ForeColor = 'green'
        $userInputMenuKeytabSelectedFile.Text = "$($userInputMenuKeytabInput.SafeFileName) is a valid keytab file!"

        # store file in global var
        $Global:keytabFile = $userInputMenuKeytabInput.FileName

        # write to log
        WriteLog "INFO: $Global:keytabFile has been selected as the keytab file"
    
        }

<# 

krb5 - validate krb5 conf file has been selected based on file extension

#>

# checks selected krb5 file extension is conf
if((Get-Item $userInputMenuKrb5Input.FileName).Extension -ne ".conf"){

    # if the file type is not conf, the user is informed
    $userInputMenuKrb5SelectedFile.ForeColor = 'red'
    $userInputMenuKrb5SelectedFile.Text = "The selected file is not a krb5 conf file. Select a validate krb5 conf file!"

    } else {

        # if a valid keytab file has been selected, the text is changed to green and user informed
        $userInputMenuKrb5SelectedFile.ForeColor = 'green'
        $userInputMenuKrb5SelectedFile.Text = "$($userInputMenuKrb5Input.SafeFileName) is a valid conf file!"

        # store file in global var
        $Global:krb5ConfFile = $userInputMenuKrb5Input.FileName

        # write to log
        WriteLog "INFO: $($userInputMenuKrb5SelectedFile.Text)"

        }

<# 

certificate templates - dump selected certificate templates to output directory

#>

# check if certificate template dump is already succesful
if($Global:templateDumpSuccess -ne $true){

    # remove existing certificate template dump directory if exists
    try {

        # add suspense
        start-sleep -s 1

        # if not already orange, change color, check if dump directory already exists, inform user, and catch on error
        $userInputMenuCertTemplatesSelected.ForeColor = 'orange'
        $userInputMenuCertTemplatesSelected.Text = "Checking for existing certificate template dump directory..."
        $templateDumpDirectoryStatus = Test-Path $templateDumpDirectory -ErrorAction Stop

        # if directory exists
        if($templateDumpDirectoryStatus -eq 'True'){

            # write to log
            WriteLog "INFO: $templateDumpDirectory directory already exists"

            # add suspense
            start-sleep -s 1

            # remove directory, inform user, and catch on error
            $userInputMenuCertTemplatesSelected.Text = "Removed existing certificate template dump directory..."
            Remove-Item $templateDumpDirectory -Confirm:$false -Recurse -ErrorAction Stop

            # write to log
            WriteLog "INFO: Removed existing $templateDumpDirectory directory"

            }

        # catch any error
        } catch {

            # change text to red, and inform user
            $userInputMenuCertTemplatesSelected.ForeColor = 'red'
            $userInputMenuCertTemplatesSelected.Text = "Unable to access path $templateDumpDirectory. Confirm permissions to the directory location."

            # write to log
            WriteLog "ERROR: $($userInputMenuCertTemplatesSelected.Text)"

            }
                
    # create certificate dump directory
    try {

        # add suspense
        start-sleep -s 1

        # inform user and write to log
        $userInputMenuCertTemplatesSelected.Text = "Attempting to create certificate template dump directory..."

        # write to log
        WriteLog "INFO: $($userInputMenuCertTemplatesSelected.Text)"

        # create directory
        $templateDumpDirectoryCreate = New-Item -ItemType Directory -Force -Path $templateDumpDirectory -ErrorAction Stop

        # add suspense
        start-sleep -s 1

        # inform user and write to log
        $userInputMenuCertTemplatesSelected.Text = "Successfully created certificate template dump directory..."

        # write to log
        WriteLog "INFO: $($userInputMenuCertTemplatesSelected.Text)"

            } catch {

                # change text to red and inform user
                $userInputMenuCertTemplatesSelected.ForeColor = 'red'
                $userInputMenuCertTemplatesSelected.Text = "Unable to create $templateDumpDirectory. Confirm permissions to the directory location."

                # write to log
                WriteLog "ERROR: $($userInputMenuCertTemplatesSelected.Text)"    
            
                }

        # add suspense
        start-sleep -s 1

        # inform user of certificate template dump
        $userInputMenuCertTemplatesSelected.Text = "Dumping certificate templates to directory..."

        # loop global var
        foreach($template in $Global:certificateTemplates){

            try {

                # dump certificate tempate into dump directory and stop on error
                certutil -v -template $template | Out-File "$templateDumpDirectory\$template.txt" -ErrorAction Stop
                WriteLog "INFO: Succesfully dumped the $template"

                # set bool to true so it runs again
                $Global:templateDumpSuccess = $true


                # catch error
                } catch {

                    # check text to red and inform user
                    $userInputMenuCertTemplatesSelected.Text = "Unable to dump the $template template. Refer to the log for more details."

                    # write to log
                    WriteLog "ERROR: Failed to dump the $template template"
                    WriteLog "ERROR: $Error[0].Exception"

                    # set bool to true so it runs again
                    $Global:templateDumpSuccess = $false

                    }
                }

                # add suspense
                start-sleep -s 1

        # check if all certificates dumped successfully
        if($templateDumpSuccess -eq $true){

            # change color and write successful
            $userInputMenuCertTemplatesSelected.ForeColor = 'green'
            $userInputMenuCertTemplatesSelected.Text = "Certificate templates successful dumped!"
            WriteLog "INFO: $($userInputMenuCertTemplatesSelected.Text)"
            
            }
    }

    # add results label
    $userInputMenu.Controls.Add($userInputMenuCheckStatusTitle)

    # validate all selections until user can proceed and repeate until validation succeeds          
    # end do until loop when all variables are populated
    if($Global:svcAccount -ne $null -and `
        $Global:policyServer -ne $null -and `
        $Global:keytabFile -ne $null -and `
        $Global:krb5ConfFile -ne $null -and `
        $templateDumpSuccess -eq $true){
    
        # set text to green and inform use checks passed
        $userInputMenuCheckStatus.ForeColor = 'green'
        $userInputMenuCheckStatus.Text = "All checks have passed. Click 'Next' to continue"
        $userInputMenu.Controls.Add($userInputMenuNextButton)

        # write to log 
        WriteLog "INFO: $($userInputMenuCheckStatus.Text)"

        } else {
    
            # set text to red and inform use checks failed
            $userInputMenuCheckStatus.ForeColor = 'red'
            $userInputMenuCheckStatus.Text = "One, or more, of the checks have failed. Update any values that have might have failed or quit the tool and reference $logFile to fix any issues before running the tool again."
    
        }
}

$next_Click = {

    # show validation menu form
    $validationMenu.Focus()

}

$cancel_Click = {

    $userInputMenu.Close()
    # $toolKitApp.Close() | Out-Null

}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot '..\form-designs\user_input_menu_design.ps1')

#$userInputMenu.Show()
$userInputMenu.ShowDialog()