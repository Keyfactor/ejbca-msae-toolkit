$prerequisitesCheck = New-Object -TypeName System.Windows.Forms.Form

# Clear out each value when the form loads
[System.Windows.Forms.Label]$prerequisitesCheckLogFile = $null
[System.Windows.Forms.Label]$prerequisitesCheckServer = $null
[System.Windows.Forms.Label]$prerequisitesCheckADDS = $null
[System.Windows.Forms.Label]$prerequisitesCheckADCS = $null
[System.Windows.Forms.Button]$prerequisitesCheckCloseButton = $null

function InitializeComponent
{

$prerequisitesCheckLogFile = New-Object System.Windows.Forms.Label
$prerequisitesCheckServer = New-Object System.Windows.Forms.Label
$prerequisitesCheckADDS = New-Object System.Windows.Forms.Label
$prerequisitesCheckADCS = New-Object System.Windows.Forms.Label
$prerequisitesCheckCloseButton = New-Object System.Windows.Forms.Button

# Create Log File
$prerequisitesCheckLogFile.Location = '5,5'
$prerequisitesCheckLogFile.AutoSize = $true

# Member Server Check
$prerequisitesCheckServer.Location = '5,30'
$prerequisitesCheckServer.AutoSize = $true

# ADDS Check
$prerequisitesCheckADDS.Location = '5,55'
$prerequisitesCheckADDS.AutoSize = $true

# ADCS Check
$prerequisitesCheckADCS.Location = '5,80'
$prerequisitesCheckADCS.AutoSize = $true

# Close Button
$prerequisitesCheckCloseButton.Text = 'Close'
$prerequisitesCheckCloseButton.Location = '475,85'
$prerequisitesCheckCloseButton.BackColor = 'WhiteSmoke'
$prerequisitesCheckCloseButton.Size = '100,40'
$prerequisitesCheckCloseButton.Add_Click($close_Click)

# Form
$prerequisitesCheck.MaximizeBox = $false
$prerequisitesCheck.MinimizeBox = $false
$prerequisitesCheck.Size = '600,180'
$prerequisitesCheck.BackColor = 'White'
$prerequisitesCheck.AutoSize = $true
$prerequisitesCheck.ShowIcon = $false
$prerequisitesCheck.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$prerequisitesCheck.StartPosition = 1
$prerequisitesCheck.FormBorderStyle = 'FixedSingle'

# Add controls to form
$prerequisitesCheck.Controls.Add($prerequisitesCheckLogFile)
$prerequisitesCheck.Controls.Add($prerequisitesCheckServer)
$prerequisitesCheck.Controls.Add($prerequisitesCheckADDS)
$prerequisitesCheck.Controls.Add($prerequisitesCheckADCS)
$prerequisitesCheck.Controls.Add($prerequisitesCheckCloseButton) 

}

. InitializeComponent

$prerequisitesCheck.ShowDialog()