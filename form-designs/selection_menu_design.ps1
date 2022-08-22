$selectionMenu = New-Object -TypeName System.Windows.Forms.Form

# Clear out each value when the form loads
[System.Windows.Forms.Label]$selectionMenuDescription = $null
[System.Windows.Forms.RadioButton]$selectionMenuRadioConfig = $null
[System.Windows.Forms.RadioButton]$selectionMenuRadioValidation = $null
[System.Windows.Forms.Label]$selectionMenuToolDescription = $null
[System.Windows.Forms.Button]$selectionMenuNextButton = $null
[System.Windows.Forms.Button]$selectionMenuCancelButton = $null

function InitializeComponent
{
# Initialize each class
$selectionMenuDescription = New-Object System.Windows.Forms.Label
$selectionMenuRadioConfig = New-Object System.Windows.Forms.RadioButton
$selectionMenuRadioValidation = New-Object System.Windows.Forms.RadioButton
$selectionMenuToolDescription = New-Object System.Windows.Forms.Label
$selectionMenuNextButton = New-Object System.Windows.Forms.Button
$selectionMenuCancelButton = New-Object System.Windows.Forms.Button

# Description
$selectionMenuDescription.Text = ('This Tool Kit is capable of performing the actions below. Select one of the options to view the permission requirements and description of the tool. Select one of the options to continue.')
$selectionMenuDescription.Location = '20,100'
$selectionMenuDescription.Size = '950,50'
$selectionMenuDescription.AutoSize = $false

# Config button
$selectionMenuRadioConfig.Location = '30,180'
$selectionMenuRadioConfig.Text = "Configuration"
$selectionMenuRadioConfig.AutoSize = $true
$selectionMenuRadioConfig.Add_Click($config_Click)

# Validation button
$selectionMenuRadioValidation.Location = '30,220'
$selectionMenuRadioValidation.Text = "Validation and Testing"
$selectionMenuRadioValidation.AutoSize = $true
$selectionMenuRadioValidation.Add_Click($validation_Click)

#Description
$selectionMenuToolDescription.Location = '20,280'
$selectionMenuToolDescription.Size = '950,50'
$selectionMenuToolDescription.AutoSize = $false

# Next Button
$selectionMenuNextButton.Text = 'Next'
$selectionMenuNextButton.Location = '750,500'
$selectionMenuNextButton.BackColor = 'WhiteSmoke'
$selectionMenuNextButton.Size = '100,40'
$selectionMenuNextButton.Add_Click($next_Click)

# Cancel Button
$selectionMenuCancelButton.Text = 'Cancel'
$selectionMenuCancelButton.Location = '875,500'
$selectionMenuCancelButton.BackColor = 'WhiteSmoke'
$selectionMenuCancelButton.Size = '100,40'
$selectionMenuCancelButton.Add_Click($cancel_Click)

# MDI Child Form
$selectionMenu.WindowState = 'Maximized'
$selectionMenu.MinimizeBox = $false
$selectionMenu.BackColor = 'White'
$selectionMenu.MdiParent = $toolKitApp
$selectionMenu.IsMdiChild
$selectionMenu.FormBorderStyle = 'FixedDialog'
$selectionMenu.Font = [System.Drawing.Font]::new("Times New Roman", 12)

# Add controls to form
$selectionMenu.Controls.Add($selectionMenuDescription)
$selectionMenu.Controls.Add($selectionMenuRadioConfig)
$selectionMenu.Controls.Add($selectionMenuRadioValidation)
$selectionMenu.Controls.Add($selectionMenuToolDescription)
$selectionMenu.Controls.Add($selectionMenuCancelButton)

}
. InitializeComponent