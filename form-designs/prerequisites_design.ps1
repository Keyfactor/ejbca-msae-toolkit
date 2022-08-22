$prerequisites = New-Object -TypeName System.Windows.Forms.Form

# Clear out each value when the form loads
[System.Windows.Forms.Label]$prerequisitesDescription = $null
[System.Windows.Forms.Button]$prerequisitesNextButton = $null
[System.Windows.Forms.Button]$prerequisitesCancelButton = $null

function InitializeComponent
{

# Initialize each class
$prerequisitesDescription = New-Object System.Windows.Forms.Label
$prerequisitesNextButton = New-Object System.Windows.Forms.Button
$prerequisitesCancelButton = New-Object System.Windows.Forms.Button

# Description
$prerequisitesDescription.Text = ("The following roles and software prerequistes below are required before proceeding. The tool will check if the required software is installed and will attempt to install it if not already installed. Clicking 'Next' will run the prerequisites check.

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

# Next Button
$prerequisitesNextButton.Text = 'Next'
$prerequisitesNextButton.Location = '750,500'
$prerequisitesNextButton.BackColor = 'WhiteSmoke'
$prerequisitesNextButton.Size = '100,40'
$prerequisitesNextButton.Add_Click($next_Click)

# Cancel Button
$prerequisitesCancelButton.Text = 'Cancel'
$prerequisitesCancelButton.Location = '875,500'
$prerequisitesCancelButton.BackColor = 'WhiteSmoke'
$prerequisitesCancelButton.Size = '100,40'
$prerequisitesCancelButton.Add_Click($cancel_Click)

# MDI Child Form
$prerequisites.WindowState = 'Maximized'
$prerequisites.MinimizeBox = $false
$prerequisites.BackColor = 'White'
$prerequisites.MdiParent = $toolKitApp
$prerequisites.IsMdiChild
$prerequisites.FormBorderStyle = 'FixedDialog'
$prerequisites.Font = [System.Drawing.Font]::new("Times New Roman", 12)


# Add controls to form
$prerequisites.Controls.Add($prerequisitesDescription)
$prerequisites.Controls.Add($prerequisitesNextButton)
$prerequisites.Controls.Add($prerequisitesCancelButton)

}
. InitializeComponent