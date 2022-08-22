$toolKitDescriptionForm.Close()

#Service account form
$toolKitServiceAccountForm = New-Object System.Windows.Forms.Form
$toolKitServiceAccountForm.Text = ('Service Account')
$toolKitServiceAccountForm.MdiParent = $toolKitApp
$toolKitServiceAccountForm.WindowState = 'Maximized'

#Title
$toolKitServiceAccountTitle = New-Object System.Windows.Forms.Label
$toolKitServiceAccountTitle.Text = ('Service Account Validation')
$toolKitServiceAccountTitle.Font = [System.Drawing.Font]::new("Times New Roman", 14, [System.Drawing.FontStyle]::Underline)
$toolKitServiceAccountTitle.Location = '20,20'
$toolKitServiceAccountTitle.AutoSize = $true

#Description
$toolKitServiceAccountDescription = New-Object System.Windows.Forms.Label
$toolKitServiceAccountDescription.Text = ('Service Account sample description.')
$toolKitServiceAccountDescription.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitServiceAccountDescription.Location = '20,60'
$toolKitServiceAccountDescription.AutoSize = $true

#Next button
$toolKitServiceAccountNext = New-Object System.Windows.Forms.Button
$toolKitServiceAccountNext.Text = 'Next'
$toolKitServiceAccountNext.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitServiceAccountNext.Location = '525,475'
$toolKitServiceAccountNext.Size = '100,40' 
 
#Cancel button
$toolKitServiceAccountCancel = New-Object System.Windows.Forms.Button
$toolKitServiceAccountCancel.Text = "Cancel"
$toolKitServiceAccountCancel.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitServiceAccountCancel.Location = '650,475'
$toolKitServiceAccountCancel.Size = '100,40'


$toolKitServiceAccountForm.Controls.AddRange(@($toolKitServiceAccountTitle,
$toolKitServiceAccountDescription))

$toolKitServiceAccountForm.Controls.AddRange(@($toolKitServiceAccountNext,
$toolKitServiceAccountBack,
$toolKitServiceAccountCancel))

    $toolKitServiceAccountNext.Add_Click({
       
       . "$PSScriptRoot\process_form.ps1"
           
    })

    $toolKitServiceAccountCancel.Add_Click({

            $toolKitApp.Close()

    })



$toolKitServiceAccountForm.Show()