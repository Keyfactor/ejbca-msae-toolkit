
#$toolKitDescriptionForm.Close()

#Validation process form
$toolKitValidationProcessForm = New-Object System.Windows.Forms.Form
$toolKitValidationProcessForm.Text = ('Validation')
$toolKitValidationProcessForm.MdiParent = $toolKitApp
$toolKitValidationProcessForm.MaximizeBox = $False
$toolKitValidationProcessForm.MinimizeBox = $False
$toolKitValidationProcessForm.ControlBox = $False
$toolKitValidationProcessForm.WindowState = 'Maximized'

#Title
$toolKitValidationProcessTitle = New-Object System.Windows.Forms.Label
$toolKitValidationProcessTitle.Font = [System.Drawing.Font]::new("Times New Roman", 14, [System.Drawing.FontStyle]::Underline)
$toolKitValidationProcessTitle.Location = '20,20'
$toolKitValidationProcessTitle.AutoSize = $true
$toolKitValidationProcessTitle.Text = ('Validation and Testing')

#Description
$toolKitValidationProcessDescription = New-Object System.Windows.Forms.label
$toolKitValidationProcessDescription.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitValidationProcessDescription.Location = '20,60'
$toolKitValidationProcessDescription.Size = '725,175' 
$toolKitValidationProcessDescription.AutoSize = $false
$toolKitValidationProcessDescription.Text = ('This tool is designed to validate previously configured MSAE settings and remediate detected misconfigurations. You will be asked to input data specific to your MSAE implementation and the validation process will confirm all configurations before proceeding presenting the option to test the configuration.

If the tool is unable to make the configuration change, either due to an error or permission restriction, a text output of the change will be provided for manual implementation.

At the end of the validation steps, the option will be given to generate a support bundle for Keyfactor support.')

#Validation steps - MS Only
$toolKitValidationProcesSteps = New-Object System.Windows.Forms.Label
$toolKitValidationProcesSteps.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitValidationProcesSteps.Location = '20,250'
$toolKitValidationProcesSteps.AutoSize = $true
$toolKitValidationProcesSteps.Text = ('The following steps will be performed:

1. System Preperation
2. Environment Variables
2. Validation of 
3. Enterprise Trust Store
4. Network Connection with Policy Server
5. Certificate Template and Auto-Enroll Permissions
6. Group Policy Settings
7. Validation Summary')

#Next button
$toolKitValidationProcessNext = New-Object System.Windows.Forms.Button
$toolKitValidationProcessNext.Text = 'Next'
$toolKitValidationProcessNext.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitValidationProcessNext.Location = '525,475'
$toolKitValidationProcessNext.Size = '100,40' 
 
#Cancel button
$toolKitValidationProcessCancel = New-Object System.Windows.Forms.Button
$toolKitValidationProcessCancel.Text = "Cancel"
$toolKitValidationProcessCancel.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitValidationProcessCancel.Location = '650,475'
$toolKitValidationProcessCancel.Size = '100,40'

#Controls
$toolKitValidationProcessForm.Controls.AddRange(@($toolKitValidationProcessTitle,
$toolKitValidationProcessDescription,
$toolKitValidationProcesSteps,
$toolKitValidationProcessNext,
$toolKitValidationProcessCancel))

    $toolKitValidationProcessNext.Add_Click({
       
            . "$PSScriptRoot\system_prep.ps1"
            

    })
    $toolKitValidationProcessCancel.Add_Click({

            $toolKitApp.Close()

    })


$toolKitValidationProcessForm.Show()


#Testing Steps - MS Only
$toolKitProcessChoiceTesting = New-Object System.Windows.Forms.Label
$toolKitProcessChoiceTesting.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitProcessChoiceTesting.Location = '20,350'
$toolKitProcessChoiceTesting.AutoSize = $true
$toolKitProcessChoiceTesting.Text = ('The following testing steps will be performed:

Enable Advanced Logging
Auto-Enrollment
Gather Logging
Testing Summary')

#Validation and testing choices
$toolKitProcessChoiceOptions = New-Object System.Windows.Forms.CheckedListBox
$toolKitProcessChoiceOptions.Location = '20,60'
$toolKitProcessChoiceOptions.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitProcessChoiceOptions.Items.AddRange(@('Validation','Testing'))
$toolKitProcessChoiceOptions.CheckOnClick = $true 
$toolKitProcessChoiceOptions.BackColor = 'Control'
$toolKitProcessChoiceOptions.BorderStyle = 'None'
$toolKitProcessChoiceOptions.ClearSelected()

    $toolKitProcessChoiceOptions.Add_Click({
        if($toolKitProcessChoiceOptions.CheckedItems -eq 'Validation'){

        
        $toolKitProcessForm.Controls.Add($toolKitProcessChoiceValidationSelected)

        }

    })

    $toolKitProcessChoiceOptions.Add_Click({
        if($toolKitProcessChoiceOptions.CheckedItems -eq 'Testing'){

        $toolKitProcessForm.Controls.Add($toolKitProcessChoiceTestingSelected)

        }

    })

#Validation and Testing with EJBCA choice
$toolKitProcessChoiceEJBCAOption = New-Object System.Windows.Forms.RadioButton
$toolKitProcessChoiceEJBCAOption.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitProcessChoiceEJBCAOption.Location = '20,180'
$toolKitProcessChoiceEJBCAOption.AutoSize = $true
$toolKitProcessChoiceEJBCAOption.Text = ('Include EJBCA')
$toolKitProcessForm.Controls.Add($toolKitProcessChoiceEJBCAOption)


#Validation and Testing with EJBCA warning
$toolKitProcessChoiceEJBCAWarning = New-Object System.Windows.Forms.Label
$toolKitProcessChoiceEJBCAWarning.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitProcessChoiceEJBCAWarning.Text = ""
$toolKitProcessChoiceEJBCAWarning.ForeColor = 'red'
$toolKitProcessChoiceEJBCAWarning.Location = '20,250'
$toolKitProcessChoiceEJBCAWarning.AutoSize = $true

    $toolKitProcessChoiceEJBCAOption.Add_Click({
        if($toolKitProcessChoiceEJBCAOption.Enabled){

        $toolKitProcessChoiceEJBCAWarning.Text = 'SSH access to EJBCA is Required'
        $toolKitProcessForm.Controls.Add($toolKitProcessChoiceEJBCAWarning)
        }
})

#Validation Steps - EJBCA
$toolKitProcessChoiceEJBCAValidationSelected = New-Object System.Windows.Forms.Label
$toolKitProcessChoiceEJBCAValidationSelected.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitProcessChoiceEJBCAValidationSelected.Location = '20,240'
$toolKitProcessChoiceEJBCAValidationSelected.AutoSize = $true
$toolKitProcessChoiceEJBCAValidationSelected.Text = ('The following testing steps will be performed:

LDAP(S) and Network Connection with Active Directory')

#Testing Steps - EJBCA
$toolKitProcessChoiceEJBCATestingSelected = New-Object System.Windows.Forms.Label
$toolKitProcessChoiceEJBCATestingSelected.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitProcessChoiceEJBCATestingSelected.Location = '20,270'
$toolKitProcessChoiceEJBCATestingSelected.AutoSize = $true
$toolKitProcessChoiceEJBCATestingSelected.Text = ('The following testing steps will be performed on the EJBCA Policy Server:

Enable DEBUG Logging
Collect Log Data')

    $toolKitProcessChoiceEJBCAOption.Add_Click({
        if($toolKitProcessChoiceEJBCAOption.Checked -eq $true){

        $toolKitProcessForm.Controls.Add($toolKitProcessChoiceEJBCAValidationSelected)
        $toolKitProcessForm.Controls.Add($toolKitProcessChoiceEJBCATestingSelected)

        }
})

$toolKitValidationProcessForm.Show()