$prerequisites = New-Object -TypeName System.Windows.Forms.Form

# Clear out each value when the form loads
[System.Windows.Forms.Label]$prerequisitesDescription = $null
[System.Windows.Forms.Label]$prerequisitesCheckTitle = $null
[System.Windows.Forms.Label]$prerequisitesCheckLogFile = $null
[System.Windows.Forms.Label]$prerequisitesCheckServer = $null
[System.Windows.Forms.Label]$prerequisitesCheckADDS = $null
[System.Windows.Forms.Label]$prerequisitesCheckADCS = $null
[System.Windows.Forms.Label]$prerequisitesCheckStatusTitle = $null
[System.Windows.Forms.Label]$prerequisitesCheckStatus = $null
[System.Windows.Forms.Button]$prerequisitesCheckButton = $null
[System.Windows.Forms.Button]$prerequisitesNextButton = $null
[System.Windows.Forms.Button]$prerequisitesCancelButton = $null

function InitializeComponent
{

# Initialize each class
$prerequisitesDescription = New-Object System.Windows.Forms.Label
$prerequisitesCheckLogFile = New-Object System.Windows.Forms.Label
$prerequisitesCheckTitle = New-Object System.Windows.Forms.Label
$prerequisitesCheckServer = New-Object System.Windows.Forms.Label
$prerequisitesCheckADDS = New-Object System.Windows.Forms.Label
$prerequisitesCheckADCS = New-Object System.Windows.Forms.Label
$prerequisitesCheckStatusTitle = New-Object System.Windows.Forms.Label
$prerequisitesCheckStatus = New-Object System.Windows.Forms.Label
$prerequisitesCheckButton = New-Object System.Windows.Forms.Button
$prerequisitesNextButton = New-Object System.Windows.Forms.Button
$prerequisitesCancelButton = New-Object System.Windows.Forms.Button

# Description
$prerequisitesDescription.Text = ("The following roles and software prerequistes below are required before proceeding. The tool will check if the required software is installed and will attempt to install it if not already installed. Click 'Check' to run the prerequisites check. You will not be able to continue until the checks are successful.

1. The following administrative access:
    a. Create/modify Service Accounts
    b. Create/modify Certificate Templates

2. The location of the tool is on one of the following:
    a. Domain Controller
    b. Member Server

3. Active Directory Domain Services RSAT Tool (will be installed if not currently installed)

4. Active Directory Certificate Services RSAT Tool (will be installed if not currently installed)")

$prerequisitesDescription.Location = '20,100'
$prerequisitesDescription.Size = '950,275'
$prerequisitesDescription.AutoSize = $false

# popup title
$prerequisitesCheckTitle.Text = ('Prerequisite Checks')
$prerequisitesCheckTitle.Location = '20,100'
$prerequisitesCheckTitle.AutoSize = $true
$prerequisitesCheckTitle.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Underline)

# create log file
$prerequisitesCheckLogFile.Location = '20,135'
$prerequisitesCheckLogFile.AutoSize = $true

# member server check
$prerequisitesCheckServer.Location = '20,170'
$prerequisitesCheckServer.AutoSize = $true

# adds check
$prerequisitesCheckADDS.Location = '20,205'
$prerequisitesCheckADDS.AutoSize = $true

# adcs check
$prerequisitesCheckADCS.Location = '20,240'
$prerequisitesCheckADCS.AutoSize = $true

# check status title
$prerequisitesCheckStatusTitle.Text = ('Results')
$prerequisitesCheckStatusTitle.Location = '20,295'
$prerequisitesCheckStatusTitle.AutoSize = $true
$prerequisitesCheckStatusTitle.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Underline)

# check status
$prerequisitesCheckStatus.Location = '20,325'
$prerequisitesCheckStatus.Size = '800,50'
$prerequisitesCheckStatus.AutoSize = $false

# check button
$prerequisitesCheckButton.Text = 'Check'
$prerequisitesCheckButton.Location = '740,500'
$prerequisitesCheckButton.BackColor = 'WhiteSmoke'
$prerequisitesCheckButton.Size = '100,40'
$prerequisitesCheckButton.Add_Click($check_Click)

# next button
$prerequisitesNextButton.Text = 'Next'
$prerequisitesNextButton.Location = '740,500'
$prerequisitesNextButton.BackColor = 'WhiteSmoke'
$prerequisitesNextButton.Size = '100,40'
$prerequisitesNextButton.Add_Click($next_Click)

# cancel button
$prerequisitesCancelButton.Text = 'Cancel'
$prerequisitesCancelButton.Location = '860,500'
$prerequisitesCancelButton.BackColor = 'WhiteSmoke'
$prerequisitesCancelButton.Size = '100,40'
$prerequisitesCancelButton.Add_Click($cancel_Click)

# MDI Child Form
$prerequisites.WindowState = 'Maximized'
$prerequisites.MdiParent = $toolKitApp
$prerequisites.IsMdiChild
$prerequisites.MinimizeBox = $false
$prerequisites.Size = '1000,600'
$prerequisites.BackColor = 'White'
$prerequisites.FormBorderStyle = 'FixedDialog'
$prerequisites.Font = [System.Drawing.Font]::new("Times New Roman", 12)

# Add controls to child form
$prerequisites.Controls.Add($prerequisitesDescription)
$prerequisites.Controls.Add($prerequisitesCheckButton)
$prerequisites.Controls.Add($prerequisitesCancelButton)

}
. InitializeComponent