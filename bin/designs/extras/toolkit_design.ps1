$ToolKitApp = New-Object -TypeName System.Windows.Forms.Form

# clear out each value when the form loads
[System.Windows.Forms.Panel]$ToolKitAppNavigationPane = $null
[System.Windows.Forms.MenuStrip]$ToolKitAppMenu = $null
#[System.Windows.Forms.UserControl]$ToolKitAppControl = $null
[System.Windows.Forms.Panel]$ToolKitAppControl = $null
[System.Windows.Forms.Label]$ToolKitAppControlLabel = $null

function InitializeComponent
{

# initialize each class
$ToolKitAppNavigationPane = New-Object System.Windows.Forms.Panel
$ToolKitAppMenu = New-Object System.Windows.Forms.MenuStrip
#$ToolKitAppControl = New-Object System.Windows.Forms.UserControl
$ToolKitAppControl = New-Object System.Windows.Forms.Panel
$ToolKitAppControlLabel = New-Object System.Windows.Forms.Label

# navigation panel
$ToolKitAppNavigationPane.Dock = 'Left'
$ToolKitAppNavigationPane.Parent = $ToolKitApp
$ToolKitAppNavigationPane.Size = '200,800'
$ToolKitAppNavigationPane.BorderStyle = 'FixedSingle'
$ToolKitAppNavigationPane.BackColor = 'white'
$ToolKitAppNavigationPane.Font = [System.Drawing.Font]::new("Times New Roman", 12)

# container
$ToolKitApp.Name = 'ToolKitApp'
$ToolKitApp.Text = ('Microsoft AutoEnrollment Tool Kit')
$ToolKitApp.AutoSize = $true
$ToolKitApp.Size = '1200,800'
$ToolKitApp.MaximizeBox = $False
$ToolKitApp.MinimizeBox = $False
$ToolKitApp.BackColor = 'White'
$ToolKitApp.IsMdiContainer = $true
$ToolKitApp.MdiParent
$ToolKitApp.FormBorderStyle = 'FixedSingle'
$ToolKitApp.MainMenuStrip = $ToolKitAppMenu
$ToolKitApp.StartPosition = 1
$ToolKitApp.TopMost = $true
$ToolKitApp.ShowInTaskbar = $true

# menu bar
# created so it can be hidden
$ToolKitAppMenu.Visible = $false
$ToolKitAppMenu.Parent = $ToolKitApp

# header
$ToolKitAppControl.Dock = 'Top'
$ToolKitAppControl.Parent = $ToolKitApp
#$ToolKitAppControl.Location = '202,2'
$ToolKitAppControl.Size = '1000,75'
$ToolKitAppControl.BackColor = 'White'
$ToolKitAppControl.Font = [System.Drawing.Font]::new("Times New Roman", 12)

# header label
$ToolKitAppControlLabel.Parent = $ToolKitAppControl
$ToolKitAppControlLabel.BackgroundImage = $KeyfactorImage
$ToolKitAppControlLabel.BackgroundImageLayout = 'None'
$ToolKitAppControlLabel.Location = '20,10'
$ToolKitAppControlLabel.Size = '250,50'
$ToolKitAppControl.Controls.Add($ToolKitAppControlLabel)

}
. InitializeComponent

