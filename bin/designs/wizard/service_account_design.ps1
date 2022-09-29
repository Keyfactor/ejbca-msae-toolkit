$ServiceAccountForm = New-Object -TypeName System.Windows.Forms.Form

#region Clear out each value when the form loads
[System.Windows.Forms.Label]$ServiceAccountFormTitle = $null
[System.Windows.Forms.Label]$ServiceAccountFormDescription = $null
[System.Windows.Forms.Label]$ServiceAccountFormSelectionLabel = $null
[System.Windows.Forms.RadioButton]$ServiceAccountFormExistsRadio = $null
[System.Windows.Forms.RadioButton]$ServiceAccountFormCreateRadio = $null
[System.Windows.Forms.Label]$ServiceAccountFormDetailsTitle = $null
[System.Windows.Forms.Label]$ServiceAccountFormExistsDetailsLabel = $null
[System.Windows.Forms.Label]$ServiceAccountFormName = $null
[System.Windows.Forms.TextBox]$ServiceAccountFormNameTextBox = $null
[System.Windows.Forms.Label]$ServiceAccountFormNameStatus = $null
[System.Windows.Forms.Label]$ServiceAccountFormCreateSelection = $null
[System.Windows.Forms.Button]$ServiceAccountFormFixButton = $null
[System.Windows.Forms.Button]$ServiceAccountFormValidateNextButton = $null
[System.Windows.Forms.Button]$ServiceAccountFormCancelButton = $null
#endregion

function InitializeComponent
{

#region Header
# initialize each class
$ServiceAccountFormTitle = New-Object System.Windows.Forms.Label
$ServiceAccountFormDescription = New-Object System.Windows.Forms.Label

# title
$ServiceAccountFormTitle.Location = '20,40'
$ServiceAccountFormTitle.Text = ('Service Account')
$ServiceAccountFormTitle.Font = [System.Drawing.Font]::new("Times New Roman", 14, [System.Drawing.FontStyle]::Underline)
$ServiceAccountFormTitle.AutoSize = $true

# description
$ServiceAccountFormDescription.Location = '20,80'
$ServiceAccountFormDescription.Text = ('In this section, you will provide the Service Account EJBCA will use to query Certificate Template attibutes and permissions in Active Directory for incoming client autoenrollment requests.

A valid service account (Enabled and Unlocked) is requred before you can continue with the ToolKit. You can provide an already existing service account or have one created by the ToolKit.')
$ServiceAccountFormDescription.AutoSize = $false
$ServiceAccountFormDescription.Size = '950,110'
#endregion Header

#region Service account selection
$ServiceAccountFormSelectionLabel = New-Object System.Windows.Forms.Label
$ServiceAccountFormExistsRadio = New-Object System.Windows.Forms.RadioButton
$ServiceAccountFormCreateRadio = New-Object System.Windows.Forms.RadioButton
$ServiceAccountFormCreateSelection = New-Object System.Windows.Forms.Label

# selection
$ServiceAccountFormSelectionLabel.Location = '20,200'
$ServiceAccountFormSelectionLabel.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
$ServiceAccountFormSelectionLabel.Text = ('Does a service account for MSAE already exist?')
$ServiceAccountFormSelectionLabel.AutoSize = $true

# exists button
$ServiceAccountFormExistsRadio.Location = '50,230'
$ServiceAccountFormExistsRadio.Text = "Yes"
$ServiceAccountFormExistsRadio.Add_Click($ExistsRadio_Click)

# create button
$ServiceAccountFormCreateRadio.Location = '50,260'
$ServiceAccountFormCreateRadio.Text = "No"
$ServiceAccountFormCreateRadio.Add_Click($CreateRadio_Click)

# create selection
$ServiceAccountFormCreateSelection.Location = '20,310'
#$ServiceAccountFormCreateSelection.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
$ServiceAccountFormCreateSelection.Text = ("Click 'Next' to continue creating a Service Account")
$ServiceAccountFormCreateSelection.AutoSize = $true
#endregion Service account selection

#region Details
$ServiceAccountFormDetailsTitle = New-Object System.Windows.Forms.Label
$ServiceAccountFormExistsDetailsLabel = New-Object System.Windows.Forms.Label

# title
$ServiceAccountFormDetailsTitle.Location = '20,310'
$ServiceAccountFormDetailsTitle.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Underline)
$ServiceAccountFormDetailsTitle.Text = ('Existing Service Account')
$ServiceAccountFormDetailsTitle.AutoSize = $true

# exists label
$ServiceAccountFormExistsDetailsLabel.Location = '20,340'
$ServiceAccountFormExistsDetailsLabel.Text = ("Enter the following information and click 'Validate' to continue. If any issues are found, click the 'Fix' button to have the ToolKit fix any issues or enter a new name in the text field, and click 'Validate' again.")
$ServiceAccountFormExistsDetailsLabel.Size = '950,40'
#endregion Details

#region Name
$ServiceAccountFormName = New-Object System.Windows.Forms.Label
$ServiceAccountFormNameTextBox = New-Object System.Windows.Forms.TextBox
$ServiceAccountFormNameStatus = New-Object System.Windows.Forms.Label

# label
$ServiceAccountFormName.Location = '20,410'
$ServiceAccountFormName.Text = "Account name:"
$ServiceAccountFormName.AutoSize = $true

# textbox
$ServiceAccountFormNameTextBox.Location = '170,410'
$ServiceAccountFormNameTextBox.Size = '250,20'
$ServiceAccountFormNameTextBox.Add_KeyDown($ServiceAccountFormNameTextBox_KeyDown)

# status
$ServiceAccountFormNameStatus.Text = ''
$ServiceAccountFormNameStatus.Location = '170,440'
$ServiceAccountFormNameStatus.Size = '700,300'
#endregion Name

#region Form and buttons
$ServiceAccountFormFixButton = New-Object System.Windows.Forms.Button
$ServiceAccountFormValidateNextButton = New-Object System.Windows.Forms.Button
$ServiceAccountFormCancelButton = New-Object System.Windows.Forms.Button

# fix button
$ServiceAccountFormFixButton.Location = '600,625'
$ServiceAccountFormFixButton.Size = '100,40'
$ServiceAccountFormFixButton.Text = 'Fix'
$ServiceAccountFormFixButton.Enabled = $false
$ServiceAccountFormFixButton.BackColor = 'WhiteSmoke'
$ServiceAccountFormFixButton.Add_Click($Fix_Click)

# next button
$ServiceAccountFormValidateNextButton.Location = '725,625'
$ServiceAccountFormValidateNextButton.Size = '100,40'
$ServiceAccountFormValidateNextButton.Text = 'Next'
$ServiceAccountFormValidateNextButton.BackColor = 'WhiteSmoke'
$ServiceAccountFormValidateNextButton.Add_Click($ValidateNext_Click)

# cancel button
$ServiceAccountFormCancelButton.Location = '850,625'
$ServiceAccountFormCancelButton.Size = '100,40'
$ServiceAccountFormCancelButton.Text = 'Cancel'
$ServiceAccountFormCancelButton.BackColor = 'WhiteSmoke'
$ServiceAccountFormCancelButton.Add_Click($Cancel_Click)

# form
$ServiceAccountForm.WindowState = 'Maximized'
$ServiceAccountForm.MinimizeBox = $false
$ServiceAccountForm.MdiParent = $ToolKitApp
$ServiceAccountForm.IsMdiChild
$ServiceAccountForm.BackColor = 'White'
$ServiceAccountForm.FormBorderStyle = 'FixedDialog'
$ServiceAccountForm.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$ServiceAccountForm.Add_Shown($ServiceAccountForm_Shown)

# Add controls to form
$ServiceAccountForm.Controls.Add($ServiceAccountFormTitle)
$ServiceAccountForm.Controls.Add($ServiceAccountFormDescription)
$ServiceAccountForm.Controls.Add($ServiceAccountFormSelectionLabel)
$ServiceAccountForm.Controls.Add($ServiceAccountFormExistsRadio)
$ServiceAccountForm.Controls.Add($ServiceAccountFormCreateRadio)
$ServiceAccountForm.Controls.Add($ServiceAccountFormValidateNextButton)
$ServiceAccountForm.Controls.Add($ServiceAccountFormCancelButton)
#endregion Form and buttons

}

. InitializeComponent