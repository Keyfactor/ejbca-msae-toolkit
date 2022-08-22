$welcomeMenu = New-Object -TypeName System.Windows.Forms.Form

# Clear out each value when the form loads
[System.Windows.Forms.Label]$welcomeMenuDescription = $null
[System.Windows.Forms.Button]$welcomeMenuNextButton = $null
[System.Windows.Forms.Button]$welcomeMenuCancelButton = $null

function InitializeComponent
{
# Initialize each class
$welcomeMenuDescription = New-Object System.Windows.Forms.Label
$welcomeMenuNextButton = New-Object System.Windows.Forms.Button
$welcomeMenuCancelButton = New-Object System.Windows.Forms.Button

# Description
$welcomeMenuDescription.Text = ("Welcome to Keyfactor's Microsoft Auto Enrollment Tool Kit. This tool is designed to validate, configure, and test an enterprise contfiguration of the EJBCA MSAE integration.")
$welcomeMenuDescription.Location = '20,100'
$welcomeMenuDescription.Size = '950,50'
$welcomeMenuDescription.AutoSize = $false

# Next Button
$welcomeMenuNextButton.Text = 'Next'
$welcomeMenuNextButton.Location = '750,500'
$welcomeMenuNextButton.BackColor = 'WhiteSmoke'
$welcomeMenuNextButton.Size = '100,40'
$welcomeMenuNextButton.Add_Click($next_Click)

# Cancel Button
$welcomeMenuCancelButton.Text = 'Cancel'
$welcomeMenuCancelButton.Location = '875,500'
$welcomeMenuCancelButton.BackColor = 'WhiteSmoke'
$welcomeMenuCancelButton.Size = '100,40'
$welcomeMenuCancelButton.Add_Click($cancel_Click)

# MDI Child Form
$welcomeMenu.WindowState = 'Maximized'
$welcomeMenu.MinimizeBox = $false
$welcomeMenu.BackColor = 'White'
$welcomeMenu.MdiParent = $toolKitApp
$welcomeMenu.IsMdiChild
$welcomeMenu.FormBorderStyle = 'FixedDialog'
$welcomeMenu.Font = [System.Drawing.Font]::new("Times New Roman", 12)

# Add controls to form
$welcomeMenu.Controls.Add($welcomeMenuDescription)
$welcomeMenu.Controls.Add($welcomeMenuNextButton)
$welcomeMenu.Controls.Add($welcomeMenuCancelButton)

}
. InitializeComponent