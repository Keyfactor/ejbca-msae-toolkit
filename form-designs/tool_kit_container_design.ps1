$toolKitApp = New-Object -TypeName System.Windows.Forms.Form

# clear out each value when the form loads
[System.Windows.Forms.MenuStrip]$toolKitAppMenu = $null
[System.Windows.Forms.UserControl]$toolKitUserControls = $null
[System.Windows.Forms.Label]$toolKitUserControlsLabel = $null

function InitializeComponent
{
# initialize each class
$toolKitAppMenu = New-Object System.Windows.Forms.MenuStrip
$toolKitUserControls = New-Object System.Windows.Forms.UserControl
$toolKitUserControlsLabel = New-Object System.Windows.Forms.Label

$toolKitApp.Name = 'ToolKitApp'
$toolKitApp.Text = ('Microsoft AutoEnrollment Tool Kit')
$toolKitApp.AutoSize = $true
$toolkitApp.Size = '1000,600'
$toolKitApp.MaximizeBox = $False
$toolKitApp.MinimizeBox = $False
$toolKitApp.BackColor = 'White'
$toolKitApp.IsMdiContainer = $true
$toolKitApp.MdiParent
#$toolKitApp.FormBorderStyle = 'FixedDialog'
$toolKitApp.MainMenuStrip = $toolKitAppMenu
$toolKitApp.StartPosition = 1

# menu bar
# created so it can be hidden
$toolKitAppMenu.Visible = $false
$toolKitAppMenu.Parent = $toolKitApp

# header
$toolKitUserControls.Dock
$toolKitUserControls.Parent = $toolKitApp
$toolKitUserControls.Location = '2,2'
$toolKitUserControls.Size = '1000,75'
$toolKitUserControls.BackColor = 'White'
$toolKitUserControls.Font = [System.Drawing.Font]::new("Times New Roman", 12)

# header label
$toolKitUserControlsLabel.Parent = $toolKitUserControls
$toolKitUserControlsLabel.BackgroundImage = $keyfactor_image
$toolKitUserControlsLabel.BackgroundImageLayout = 'None'
$toolKitUserControlsLabel.Location = '20,20'
$toolKitUserControlsLabel.Size = '250,50'
$toolKitUserControls.Controls.Add($toolKitUserControlsLabel)

# # Add controls to form
# $welcomeMenu.Controls.Add($welcomeMenuDescription)
# $welcomeMenu.Controls.Add($welcomeMenuNextButton)
# $welcomeMenu.Controls.Add($welcomeMenuCancelButton)
}
. InitializeComponent