$CreateServiceAccountForm = New-Object -TypeName System.Windows.Forms.Form

#region Clear out each value when the form loads
[System.Windows.Forms.Label]$CreateServiceAccountFormTitle = $null
[System.Windows.Forms.Label]$CreateServiceAccountFormDescription = $null
[System.Windows.Forms.Label]$CreateServiceAccountFormCreateDetails = $null
[System.Windows.Forms.Label]$CreateServiceAccountFormName = $null
[System.Windows.Forms.TextBox]$CreateServiceAccountFormNameTextBox = $null
[System.Windows.Forms.Label]$CreateServiceAccountFormNameStatus = $null
[System.Windows.Forms.Label]$CreateServiceAccountFormPassword = $null
[System.Windows.Forms.MaskedTextBox]$CreateServiceAccountFormPasswordTextBox = $null
[System.Windows.Forms.Label]$CreateServiceAccountFormLdapDn = $null
[System.Windows.Forms.TextBox]$CreateServiceAccountFormLdapDnTextBox = $null
[System.Windows.Forms.Button]$CreateServiceAccountFormLdapDnTextBoxSearch = $null
[System.Windows.Forms.Checkbox]$CreateServiceAccountFormExpirePasswordBox = $null
[System.Windows.Forms.Checkbox]$CreateServiceAccountFormCertPublishersBox =  $null
[System.Windows.Forms.Button]$CreateServiceAccountFormCreateButton = $null
[System.Windows.Forms.Button]$CreateServiceAccountFormNextButton = $null
[System.Windows.Forms.Button]$CreateServiceAccountFormCancelButton = $null
#endregion

function InitializeComponent
{

#region Header
# initialize each class
$CreateServiceAccountFormTitle = New-Object System.Windows.Forms.Label
$CreateServiceAccountFormDescription = New-Object System.Windows.Forms.Label

# title
$CreateServiceAccountFormTitle.Location = '20,40'
$CreateServiceAccountFormTitle.Text = ('Service Account Creation')
$CreateServiceAccountFormTitle.Font = [System.Drawing.Font]::new("Times New Roman", 14, [System.Drawing.FontStyle]::Underline)
$CreateServiceAccountFormTitle.AutoSize = $true

# description
$CreateServiceAccountFormDescription.Location = '20,80'
$CreateServiceAccountFormDescription.Text = 'This tool will create a service account with user provided information and additiional attributes required for a successful Microsoft Autoenrollment configuration.'
$CreateServiceAccountFormDescription.AutoSize = $false
$CreateServiceAccountFormDescription.Size = '950,40'
#endregion Header

#region Service account
#region details
$CreateServiceAccountFormCreateDetails = New-Object System.Windows.Forms.Label
$CreateServiceAccountExistsSpnWarning = New-Object System.Windows.Forms.Label

# label
$CreateServiceAccountFormCreateDetails.Location = '20,140'
$CreateServiceAccountFormCreateDetails.Text = "Enter the following information and click 'Create' to generate the service account. The ToolKit will attempt to fix any issues with the creation process. Any issues it cant fix automatically will be displayed."
$CreateServiceAccountFormCreateDetails.Size = '950,60'

# spn warning
$CreateServiceAccountExistsSpnWarning.Location = '20,200'
$CreateServiceAccountExistsSpnWarning.ForeColor = 'YellowGreen'
$CreateServiceAccountExistsSpnWarning.Text = "Warning: If '$Global:CepServerSPN' is already assigned in the forst, it will be removed from the current account and added to the account being created."
$CreateServiceAccountExistsSpnWarning.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Bold)
$CreateServiceAccountExistsSpnWarning.Size = '950,40'
#endregion Details

#region Name
$CreateServiceAccountFormName = New-Object System.Windows.Forms.Label
$CreateServiceAccountFormNameTextBox = New-Object System.Windows.Forms.TextBox
$CreateServiceAccountFormNameStatus = New-Object System.Windows.Forms.Label

# label
$CreateServiceAccountFormName.Location = '20,280'
$CreateServiceAccountFormName.Text = "Account name:"
$CreateServiceAccountFormName.AutoSize = $true

# textbox
$CreateServiceAccountFormNameTextBox.Location = '170,280'
$CreateServiceAccountFormNameTextBox.Size = '250,20'

# label
$CreateServiceAccountFormNameStatus.Location = '430,280'
$CreateServiceAccountFormNameStatus.AutoSize = $true
#endregion Name

#region Password
$CreateServiceAccountFormPassword = New-Object System.Windows.Forms.Label
$CreateServiceAccountFormPasswordTextBox = New-Object System.Windows.Forms.MaskedTextBox
$CreateServiceAccountFormPasswordStatus = New-Object System.Windows.Forms.Label

# label
$CreateServiceAccountFormPassword.Location = '20,330'
$CreateServiceAccountFormPassword.Text = ('Password:')

# textbox
$CreateServiceAccountFormPasswordTextBox.Location = '170,330'
$CreateServiceAccountFormPasswordTextBox.PasswordChar = '*'
$CreateServiceAccountFormPasswordTextBox.Size = '250,20'

# status
$CreateServiceAccountFormPasswordStatus.Location = '430,332'
$CreateServiceAccountFormPasswordStatus.AutoSize = $true
#endregion Password

#region LDAP dn
$CreateServiceAccountFormLdapDn = New-Object System.Windows.Forms.Label
$CreateServiceAccountFormLdapDnTextBox = New-Object System.Windows.Forms.TextBox
$CreateServiceAccountFormLdapDnTextBoxSearch = New-Object System.Windows.Forms.Button
$CreateServiceAccountFormLdapDnStatus = New-Object System.Windows.Forms.Label

# label
$CreateServiceAccountFormLdapDn.Location = '20,380'
$CreateServiceAccountFormLdapDn.Text = ('Organization Unit (LDAP DN):')
$CreateServiceAccountFormLdapDn.Size = '125,40'

# textbox
$CreateServiceAccountFormLdapDnTextBox.Location = '170,380'
$CreateServiceAccountFormLdapDnTextBox.Size = '350,20'
$CreateServiceAccountFormLdapDnTextBox.ForeColor = 'LightGray'
$CreateServiceAccountFormLdapDnTextBox.Text = $Global:LdapDnTextDefault
$CreateServiceAccountFormLdapDnTextBox.Add_Enter($CreateServiceAccountLdapDnTextBox_Entered)
$CreateServiceAccountFormLdapDnTextBox.Add_Leave($CreateServiceAccountLdapDnTextBox_Left)
$CreateServiceAccountFormLdapDnTextBox.Add_KeyDown($CreateServiceAccountLdapDnTextBox_KeyDown)

# search
$CreateServiceAccountFormLdapDnTextBoxSearch.Location = '540,380'
$CreateServiceAccountFormLdapDnTextBoxSearch.Size = '75,25'
$CreateServiceAccountFormLdapDnTextBoxSearch.Text = 'Search'
$CreateServiceAccountFormLdapDnTextBoxSearch.BackColor = 'WhiteSmoke'
$CreateServiceAccountFormLdapDnTextBoxSearch.Add_Click($Search_Click)

# status
$CreateServiceAccountFormLdapDnStatus.Location = '635,382'
$CreateServiceAccountFormLdapDnStatus.Size = '325,40'
#endregion LDAP dn

#region Publishers/password exipration
$CreateServiceAccountFormCertPublishersBox = New-Object System.Windows.Forms.Checkbox
$CreateServiceAccountFormExpirePasswordBox = New-Object System.Windows.Forms.Checkbox

# publisher
$CreateServiceAccountFormCertPublishersBox.Location = '20,430'
$CreateServiceAccountFormCertPublishersBox.CheckAlign = 'MiddleRight'
$CreateServiceAccountFormCertPublishersBox.AutoSize = $true
$CreateServiceAccountFormCertPublishersBox.Text = ('Publish to Active Directory')
$CreateServiceAccountFormCertPublishersBox.Checked = $false
$CreateServiceAccountFormCertPublishersBox.Add_CheckStateChanged($Publishers_Check)

# password expiration
$CreateServiceAccountFormExpirePasswordBox.Location = '250,430'
$CreateServiceAccountFormExpirePasswordBox.CheckAlign = 'MiddleRight'
$CreateServiceAccountFormExpirePasswordBox.AutoSize = $true
$CreateServiceAccountFormExpirePasswordBox.Text = ('Password Never Expires')
$CreateServiceAccountFormExpirePasswordBox.Checked = $false
$CreateServiceAccountFormExpirePasswordBox.Add_CheckStateChanged($PassExpiration_Check)
#endregion Publishers/password exipration

# create status
$CreateServiceAccountFormCreateStatus = New-Object System.Windows.Forms.Label
$CreateServiceAccountFormCreateStatus.Location = '20,470'
$CreateServiceAccountFormCreateStatus.Size = '575,200'
#endregion Service account 

#region Form and buttons
$CreateServiceAccountFormCreateButton = New-Object System.Windows.Forms.Button
$CreateServiceAccountFormNextButton = New-Object System.Windows.Forms.Button
$CreateServiceAccountFormCancelButton = New-Object System.Windows.Forms.Button

# create button
$CreateServiceAccountFormCreateButton.Location = '600,625'
$CreateServiceAccountFormCreateButton.Size = '100,40'
$CreateServiceAccountFormCreateButton.Text = 'Create'
$CreateServiceAccountFormCreateButton.BackColor = 'WhiteSmoke'
$CreateServiceAccountFormCreateButton.Add_Click($Create_Click)

# next button
$CreateServiceAccountFormNextButton.Location = '725,625'
$CreateServiceAccountFormNextButton.Size = '100,40'
$CreateServiceAccountFormNextButton.Text = 'Next'
$CreateServiceAccountFormNextButton.Enabled = $false
$CreateServiceAccountFormNextButton.BackColor = 'WhiteSmoke'
$CreateServiceAccountFormNextButton.Add_Click($Next_Click)

# cancel button
$CreateServiceAccountFormCancelButton.Location = '850,625'
$CreateServiceAccountFormCancelButton.Size = '100,40'
$CreateServiceAccountFormCancelButton.Text = 'Cancel'
$CreateServiceAccountFormCancelButton.BackColor = 'WhiteSmoke'
$CreateServiceAccountFormCancelButton.Add_Click($Cancel_Click)

# form
$CreateServiceAccountForm.WindowState = 'Maximized'
$CreateServiceAccountForm.MinimizeBox = $false
$CreateServiceAccountForm.MdiParent = $ToolKitApp
$CreateServiceAccountForm.IsMdiChild
$CreateServiceAccountForm.BackColor = 'White'
$CreateServiceAccountForm.FormBorderStyle = 'FixedDialog'
$CreateServiceAccountForm.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$CreateServiceAccountForm.Add_Shown($CreateServiceAccountForm_Shown)

# Add controls to form
$CreateServiceAccountForm.Controls.AddRange(@(
    $CreateServiceAccountFormTitle,
    $CreateServiceAccountFormDescription,
    $CreateServiceAccountFormCreateDetails,
    $CreateServiceAccountExistsSpnWarning,
    $CreateServiceAccountFormName,
    $CreateServiceAccountFormNameTextBox,
    $CreateServiceAccountFormNameStatus,
    $CreateServiceAccountFormPassword,
    $CreateServiceAccountFormPasswordTextBox,
    $CreateServiceAccountFormPasswordStatus,
    $CreateServiceAccountFormLdapDn,
    $CreateServiceAccountFormLdapDnTextBox,
    $CreateServiceAccountFormLdapDnTextBoxSearch,
    $CreateServiceAccountFormLdapDnStatus,
    $CreateServiceAccountFormExpirePasswordBox,
    $CreateServiceAccountFormCertPublishersBox,
    $CreateServiceAccountFormCreateStatus,
    $CreateServiceAccountFormCreateButton,
    $CreateServiceAccountFormNextButton,
    $CreateServiceAccountFormCancelButton
    ))
#endregion Form and buttons

}

. InitializeComponent