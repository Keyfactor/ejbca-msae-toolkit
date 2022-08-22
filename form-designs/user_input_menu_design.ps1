$userInputMenu = New-Object -TypeName System.Windows.Forms.Form

# Clear out each value when the form loads
[System.Windows.Forms.Label]$userInputMenuDescription = $null
[System.Windows.Forms.Label]$userInputMenuSvcAcct = $null
[System.Windows.Forms.TextBox]$userInputMenuSvcAcctInput = $null
[System.Windows.Forms.Label]$userInputMenuPolicyServer = $null
[System.Windows.Forms.TextBox]$userInputMenuPolicyServerInput = $null
[System.Windows.Forms.Label]$userInputMenuKeytab = $null
[System.Windows.Forms.Button]$userInputMenuKeytabBrowse = $null
[System.Windows.Forms.Label]$userInputMenuKeytabSelectedFile = $null
[System.Windows.Forms.Label]$userInputMenuKrb5 = $null
[System.Windows.Forms.Button]$userInputMenuKrb5Browse = $null
[System.Windows.Forms.Label]$userInputMenuKrb5SelectedFile = $null
[System.Windows.Forms.Label]$userInputMenuCertTemplates = $null
[System.Windows.Forms.Button]$userInputMenuCertTemplatesSelect = $null
[System.Windows.Forms.Listbox]$userInputMenuCertTemplatesSelectList = $null
[System.Windows.Forms.Label]$userInputMenuCertTemplatesSelected = $null
[System.Windows.Forms.Button]$userInputMenuValidateButton = $null
[System.Windows.Forms.Button]$userInputMenuNextButton = $null
[System.Windows.Forms.Button]$userInputMenuCancelButton = $null

function InitializeComponent
{

# Initialize each class
$userInputMenuDescription = New-Object System.Windows.Forms.label
$userInputMenuSvcAcct = New-Object System.Windows.Forms.label
$userInputMenuSvcAcctInput = New-Object System.Windows.Forms.TextBox
$userInputMenuPolicyServer = New-Object System.Windows.Forms.label
$userInputMenuPolicyServerInput = New-Object System.Windows.Forms.TextBox
$userInputMenuKeytab = New-Object System.Windows.Forms.label
$userInputMenuKeytabBrowse = New-Object System.Windows.Forms.Button
$userInputMenuKeytabSelectedFile = New-Object System.Windows.Forms.label
$userInputMenuKrb5 = New-Object System.Windows.Forms.label
$userInputMenuKrb5Browse = New-Object System.Windows.Forms.Button
$userInputMenuKrb5SelectedFile = New-Object System.Windows.Forms.label
$userInputMenuCertTemplates = New-Object System.Windows.Forms.label
$userInputMenuCertTemplatesSelect = New-Object System.Windows.Forms.Button
$userInputMenuCertTemplatesSelectList = New-Object System.Windows.Forms.ListBox
$userInputMenuCertTemplatesSelected = New-Object System.Windows.Forms.Label
$userInputMenuValidateButton = New-Object System.Windows.Forms.Button
$userInputMenuNextButton = New-Object System.Windows.Forms.Button
$userInputMenuCancelButton = New-Object System.Windows.Forms.Button

# User Input description
$userInputMenuDescription.Location = '20,100'
$userInputMenuDescription.Size = '900,20'
$userInputMenuDescription.AutoSize = $false
$userInputMenuDescription.Text = ("Complete the fields below. Click 'Validate' to run the prerequisite checks and verify the provided user input text.")

#Svc Account
$userInputMenuSvcAcct.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuSvcAcct.Location = '20,150'
$userInputMenuSvcAcct.AutoSize = $true
$userInputMenuSvcAcct.Text = ('Name of Service Account:')

#Svc account input
$userInputMenuSvcAcctInput.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$userInputMenuSvcAcctInput.Location = '230,150'
$userInputMenuSvcAcctInput.Size = '200,23'
$userInputMenuSvcAcctInput.AutoSize = $false

#Policy server
$userInputMenuPolicyServer.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuPolicyServer.Location = '20,190'
$userInputMenuPolicyServer.AutoSize = $true
$userInputMenuPolicyServer.Text = ('FQDN of Policy Server:')

#Policy server input
$userInputMenuPolicyServerInput.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$userInputMenuPolicyServerInput.Location = '230,190'
$userInputMenuPolicyServerInput.Size = '200,23'
$userInputMenuPolicyServerInput.AutoSize = $false

#Keytab file
$userInputMenuKeytab.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKeytab.Location = '20,230'
$userInputMenuKeytab.AutoSize = $true
$userInputMenuKeytab.Text = ('Keytab file:')

#Keytab file input
$userInputMenuKeytabBrowse.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKeytabBrowse.Location = '230,230'
$userInputMenuKeytabBrowse.Size = '160,23'
$userInputMenuKeytabBrowse.Text = ('Browse')
$userInputMenuKeytabBrowse.Add_Click($keytabBrowse_Click)

#Selected keytab file
#Keytab file
$userInputMenuKeytabSelectedFile.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKeytabSelectedFile.Location = '450,230'
$userInputMenuKeytabSelectedFile.AutoSize = $true

#Krb5 file
$userInputMenuKrb5.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKrb5.Location = '20,270'
$userInputMenuKrb5.AutoSize = $true
$userInputMenuKrb5.Text = ('Krb5 conf file:')

#Krb5 file input
$userInputMenuKrb5Browse.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKrb5Browse.Location = '230,270'
$userInputMenuKrb5Browse.Size = '160,23'
$userInputMenuKrb5Browse.Text = ('Browse')
$userInputMenuKrb5Browse.Add_Click($krb5_Click)

#Selected krb5 file
$userInputMenuKrb5SelectedFile.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKrb5SelectedFile.Location = '450,270'
$userInputMenuKrb5SelectedFile.AutoSize = $true

#Certificate templates
$userInputMenuCertTemplates.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuCertTemplates.Location = '20,310'
$userInputMenuCertTemplates.AutoSize = $true
$userInputMenuCertTemplates.Text = ('Certificate Templates:')

#Certificate template selection form
$userInputMenuCertTemplatesSelect.Location = '230,305'
$userInputMenuCertTemplatesSelect.Size = '160,23'
$userInputMenuCertTemplatesSelect.Text = 'Select Templates'
$userInputMenuCertTemplatesSelect.AutoSize = $true
$userInputMenuCertTemplatesSelect.Add_Click($selectTemplate_Click)

#Certificate template selection form
$userInputMenuCertTemplatesSelectList.Location = '10,40'
$userInputMenuCertTemplatesSelectList.Size = '360,20'
$userInputMenuCertTemplatesSelectList.SelectedItems

#Certificate template selected templates
$userInputMenuCertTemplatesSelected.Location = '230,350'
$userInputMenuCertTemplatesSelected.Size = '300,300'
$userInputMenuCertTemplatesSelected.AutoSize = $false

# Validate Button
$userInputMenuValidateButton.Text = 'Validate'
$userInputMenuValidateButton.Location = '625,500'
$userInputMenuValidateButton.BackColor = 'WhiteSmoke'
$userInputMenuValidateButton.Size = '100,40'
$userInputMenuValidateButton.Add_Click($validate_Click)

# Next Button
$userInputMenuNextButton.Text = 'Next'
$userInputMenuNextButton.Location = '750,500'
$userInputMenuNextButton.BackColor = 'WhiteSmoke'
$userInputMenuNextButton.Size = '100,40'
$userInputMenuNextButton.Add_Click($next_Click)

# Cancel Button
$userInputMenuCancelButton.Text = 'Cancel'
$userInputMenuCancelButton.Location = '875,500'
$userInputMenuCancelButton.BackColor = 'WhiteSmoke'
$userInputMenuCancelButton.Size = '100,40'
$userInputMenuCancelButton.Add_Click($cancel_Click)

# MDI Child Form
$userInputMenu.WindowState = 'Maximized'
$userInputMenu.MinimizeBox = $false
$userInputMenu.Size = '1000,600'
$userInputMenu.BackColor = 'White'
$userInputMenu.MdiParent = $toolKitApp
$userInputMenu.IsMdiChild
$userInputMenu.FormBorderStyle = 'FixedDialog'
$userInputMenu.Font = [System.Drawing.Font]::new("Times New Roman", 12)

# Add controls to form
$userInputMenu.Controls.Add($userInputMenuDescription)
$userInputMenu.Controls.Add($userInputMenuUserInputValidate)
$userInputMenu.Controls.Add($userInputMenuSvcAcct)
$userInputMenu.Controls.Add($userInputMenuSvcAcctInput)
$userInputMenu.Controls.Add($userInputMenuPolicyServer)
$userInputMenu.Controls.Add($userInputMenuPolicyServerInput)
$userInputMenu.Controls.Add($userInputMenuKeytab)
$userInputMenu.Controls.Add($userInputMenuKeytabBrowse)
$userInputMenu.Controls.Add($userInputMenuKeytabSelectedFile)
$userInputMenu.Controls.Add($userInputMenuKrb5)
$userInputMenu.Controls.Add($userInputMenuKrb5Browse)
$userInputMenu.Controls.Add($userInputMenuKrb5SelectedFile)
$userInputMenu.Controls.Add($userInputMenuCertTemplates)
$userInputMenu.Controls.Add($userInputMenuCertTemplatesSelect)
$userInputMenu.Controls.Add($userInputMenuCertTemplatesSelectList)
$userInputMenu.Controls.Add($userInputMenuCertTemplatesSelected)
$userInputMenu.Controls.Add($userInputMenuValidateButton)
$userInputMenu.Controls.Add($userInputMenuCancelButton)

}
. InitializeComponent