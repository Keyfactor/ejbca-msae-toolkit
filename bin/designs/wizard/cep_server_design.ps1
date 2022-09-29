$CepServerForm = New-Object -TypeName System.Windows.Forms.Form

#region Clear out each value when the form loads
[System.Windows.Forms.Label]$CepServerFormTitle = $null
[System.Windows.Forms.Label]$CepServerFormDescription = $null
[System.Windows.Forms.Label]$CepServerFormCepName = $null
[System.Windows.Forms.TextBox]$CepServerFormCepNameTextBox = $null
[System.Windows.Forms.Label]$CepServerFormCepNameStatus = $null
[System.Windows.Forms.Label]$CepServerFormRequirementsQuestion = $null
[System.Windows.Forms.RadioButton]$CepServerFormRequirementsYesButton = $null
[System.Windows.Forms.RadioButton]$CepServerFormRequirementsNoButton = $null
[System.Windows.Forms.Label]$CepServerFormRequirementsWarning = $null
[System.Windows.Forms.Button]$CepServerFormNextButton = $null
[System.Windows.Forms.Button]$CepServerFormCancelButton = $null
#endregion

function InitializeComponent
{

#region Header
$CepServerFormTitle = New-Object System.Windows.Forms.Label
$CepServerFormDescription = New-Object System.Windows.Forms.Label

# Ttile
$CepServerFormTitle.Location = '20,40'
$CepServerFormTitle.Text = ('Certificate Enrollment Policy (CEP) Server')
$CepServerFormTitle.Font = [System.Drawing.Font]::new("Times New Roman", 14, [System.Drawing.FontStyle]::Underline)
$CepServerFormTitle.AutoSize = $true

# Description
$CepServerFormDescription.Location = '20,80'
$CepServerFormDescription.Text = ("In this section, you will provide the EJBCA CEP Server Fully Qualified Domain Name (FQDN) Active Directory clients will use for the EJBCA Microsoft Autoenrollment (MSAE). 

Please provide the required information below so the ToolKit can properly validate the configured, or complete the initial configuration, of your MSAE integration.")
$CepServerFormDescription.AutoSize = $false
$CepServerFormDescription.Size = '950,110'
#endregion Header

#region Cep Name
$CepServerFormCepName = New-Object System.Windows.Forms.Label
$CepServerFormCepNameTextBox = New-Object System.Windows.Forms.TextBox
$CepServerFormCepNameStatus = New-Object System.Windows.Forms.Label

# name label
$CepServerFormCepName.Location = '20,200'
$CepServerFormCepName.Text = ('Enter the FQDN the EJBCA CEP Server:')
$CepServerFormCepName.AutoSize = $true

# name textbox
$CepServerFormCepNameTextBox.Location = '325,200'
$CepServerFormCepNameTextBox.Size = '250,20'

# name not provided label
$CepServerFormCepNameStatus.Location = '325,240'
$CepServerFormCepNameStatus.Size = '400,20'
#endregion Cep Name

#region Requirements
$CepServerFormRequirementsQuestion = New-Object System.Windows.Forms.Label
$CepServerFormRequirementsYesButton = New-Object System.Windows.Forms.RadioButton
$CepServerFormRequirementsNoButton = New-Object System.Windows.Forms.RadioButton
$CepServerFormRequirementsWarning = New-Object System.Windows.Forms.Label

# Label
$CepServerFormRequirementsQuestion.Text = ("The following must be completed prior to testing the MSAE implemention configured either with this ToolKit or through the manual configuration process.

- Static DNS entry for the CEP FQDN
- Outbound TCP 443 from $(((Get-ADDomain).Forest).ToUpper()) to the CEP Endpoint (Enrollment Requests)
- Inbound TCP 636 from the CEP Endpoint to $(((Get-ADDomain).Forest).ToUpper()) (LDAPS Queries)

Have the requirements above been completed?")
$CepServerFormRequirementsQuestion.Location = '20,260'
$CepServerFormRequirementsQuestion.Size = '950,160'

# yes button
$CepServerFormRequirementsYesButton.Location = '50,420'
$CepServerFormRequirementsYesButton.Text = "Yes"
$CepServerFormRequirementsYesButton.AutoSize = $true
$CepServerFormRequirementsYesButton.Add_Click($Yes_Click)

# no button
$CepServerFormRequirementsNoButton.Location = '50,450'
$CepServerFormRequirementsNoButton.Text = "No"
$CepServerFormRequirementsNoButton.AutoSize = $true
$CepServerFormRequirementsNoButton.Add_Click($No_Click)

# warning
$CepServerFormRequirementsWarning.Text = ("Warning: You can still complete the configuration wizard but will not be able to perform any testing any the above requriements are met.")
$CepServerFormRequirementsWarning.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
$CepServerFormRequirementsWarning.Location = '20,500'
$CepServerFormRequirementsWarning.Size = '950,40'
#endregion

#region Form and buttons
$CepServerFormNextButton = New-Object System.Windows.Forms.Button
$CepServerFormCancelButton = New-Object System.Windows.Forms.Button

# next button
$CepServerFormNextButton.Location = '725,625'
$CepServerFormNextButton.Size = '100,40'
$CepServerFormNextButton.Enabled = $false
$CepServerFormNextButton.Text = 'Next'
$CepServerFormNextButton.BackColor = 'WhiteSmoke'
$CepServerFormNextButton.Add_Click($Next_Click)

# cancel button
$CepServerFormCancelButton.Location = '850,625'
$CepServerFormCancelButton.Size = '100,40'
$CepServerFormCancelButton.Text = 'Cancel'
$CepServerFormCancelButton.BackColor = 'WhiteSmoke'
$CepServerFormCancelButton.Add_Click($Cancel_Click)

# form
$CepServerForm.WindowState = 'Maximized'
$CepServerForm.MinimizeBox = $false
$CepServerForm.BackColor = 'White'
$CepServerForm.MdiParent = $ToolKitApp
$CepServerForm.IsMdiChild
$CepServerForm.FormBorderStyle = 'FixedDialog'
$CepServerForm.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$CepServerForm.Add_Shown($CepServerForm_Shown)

# Add controls to form
$CepServerForm.Controls.Add($CepServerFormTitle)
$CepServerForm.Controls.Add($CepServerFormDescription)
$CepServerForm.Controls.Add($CepServerFormCepName)
$CepServerForm.Controls.Add($CepServerFormCepNameTextBox)
$CepServerForm.Controls.Add($CepServerFormCepNameStatus)
$CepServerForm.Controls.Add($CepServerFormRequirementsQuestion)
$CepServerForm.Controls.Add($CepServerFormRequirementsYesButton)
$CepServerForm.Controls.Add($CepServerFormRequirementsNoButton)
$CepServerForm.Controls.Add($CepServerFormNextButton)
$CepServerForm.Controls.Add($CepServerFormCancelButton)
#endregion

}
. InitializeComponent