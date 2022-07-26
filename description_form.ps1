

#Form
$toolKitDescriptionForm = New-Object System.Windows.Forms.Form
$toolKitDescriptionForm.Name = 'Description'
$toolKitDescriptionForm.Text = ('Description')
$toolKitDescriptionForm.Size = '800,800'
$toolKitDescriptionForm.MaximizeBox = $False
$toolKitDescriptionForm.MinimizeBox = $False
$toolKitDescriptionForm.ControlBox = $true
$toolKitDescriptionForm.BackColor = 'Ivory'
$toolKitDescriptionForm.StartPosition = 1
#$toolKitDescriptionForm.MdiParent = $toolKitApp
#$toolKitDescriptionForm.IsMdiChild

#Title
$toolKitDescriptionTitle = New-Object System.Windows.Forms.Label
$toolKitDescriptionTitle.Text = ('Description')
$toolKitDescriptionTitle.Font = [System.Drawing.Font]::new("Times New Roman", 14, [System.Drawing.FontStyle]::Underline)
$toolKitDescriptionTitle.Location = '20,20'
$toolKitDescriptionTitle.AutoSize = $false

#Description
$toolKitDescription = New-Object System.Windows.Forms.Label
$toolKitDescription.Text = ('This is description of the MS AutoEnrollment Tool Kit. This took kit contains the tools listed below. Select one
of the options to view the permission requirements before using this tool. Select one of the options to continue.')
$toolKitDescription.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitDescription.Location = '20,60'
$toolKitDescription.AutoSize = $true

#Tool selection
#Config
$RadioButtonConfig = New-Object System.Windows.Forms.RadioButton
$RadioButtonConfig.Location = '30,120'
$RadioButtonConfig.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$RadioButtonConfig.Text = "Configuration"
$RadioButtonConfig.AutoSize = $true

#Validation
$RadioButtonValidation = New-Object System.Windows.Forms.RadioButton
$RadioButtonValidation.Location = '30,160'
$RadioButtonValidation.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$RadioButtonValidation.Text = "Validation and Testing"
$RadioButtonValidation.AutoSize = $true

#Description
$toolSelectionDescription = New-Object System.Windows.Forms.Label
$toolSelectionDescription.Text = ""
$toolSelectionDescription.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolSelectionDescription.Location = '20,200'
$toolSelectionDescription.Size = '700,400'
$toolSelectionDescription.AutoSize = $false

#Next button
$toolKitDescriptionNext = New-Object System.Windows.Forms.Button
$toolKitDescriptionNext.Text = 'Next'
$toolKitDescriptionNext.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitDescriptionNext.Location = '525,675'
$toolKitDescriptionNext.BackColor = 'White'
$toolKitDescriptionNext.Size = '100,40'

 
#Cancel button
$toolKitDescriptionCancel = New-Object System.Windows.Forms.Button
$toolKitDescriptionCancel.Text = "Cancel"
$toolKitDescriptionCancel.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitDescriptionCancel.Location = '650,675'
$toolKitDescriptionCancel.BackColor = 'White'
$toolKitDescriptionCancel.Size = '100,40'

$toolKitDescriptionForm.Controls.AddRange(@($toolKitDescriptionTitle,
$toolKitDescription,
$RadioButtonConfig,
$RadioButtonValidation))


    $RadioButtonConfig.Add_Click({
        If ($RadioButtonConfig.Enabled) {
            $toolSelectionDescription.Text ='Configuration sample text'
            $toolKitDescriptionForm.Controls.Add($toolKitDescriptionNext)
        }
    })

    $RadioButtonValidation.Add_Click({
        If ($RadioButtonValidation.Enabled) {
            $toolSelectionDescription.Text ='This tool is designed to validate previously configured MSAE settings and remediate detected misconfigurations. You will be asked to input data specific to your MSAE implementation and the validation process will confirm all configurations before proceeding presenting the option to test the configuration.

If the tool is unable to make the configuration change, either due to an error or permission restriction, a text output of the change will be provided for manual implementation.

At the end of the validation steps, the option will be given to generate a support bundle for Keyfactor support.

The following steps will be performed:

1. System Preperation
2. Environment Variables
2. Validation of 
3. Enterprise Trust Store
4. Network Connection with Policy Server
5. Certificate Template and Auto-Enroll Permissions
6. Group Policy Settings
7. Validation Summary'

            $toolKitDescriptionForm.Controls.Add($toolKitDescriptionNext)
        }
    })



$toolKitDescriptionConfirmed = New-Object System.Windows.Forms.CheckBox
#$toolKitDescriptionConfirmed.CheckState

$toolKitDescriptionForm.Controls.AddRange(@($toolSelectionDescription,
$toolKitDescriptionCancel))

    $toolKitDescriptionNext.Add_Click({

        $toolKitDescriptionForm.Close()
           
    })
    $toolKitDescriptionCancel.Add_Click({

        $toolKitDescriptionForm.Close()

    })



$toolKitDescriptionForm.ShowDialog()
#$toolKitDescriptionForm.Show()
