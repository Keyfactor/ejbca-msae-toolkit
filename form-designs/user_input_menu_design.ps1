$userInputMenu = New-Object -TypeName System.Windows.Forms.Form

# Clear out each value when the form loads
[System.Windows.Forms.Label]$userInputMenuDescription = $null
[System.Windows.Forms.Label]$userInputMenuSvcAcct = $null
[System.Windows.Forms.TextBox]$userInputMenuSvcAcctInput = $null
[System.Windows.Forms.Label]$userInputMenuSvcAcctInputValidate = $null
[System.Windows.Forms.Label]$userInputMenuPolicyServer = $null
[System.Windows.Forms.TextBox]$userInputMenuPolicyServerInput = $null
[System.Windows.Forms.Label]$userInputMenuPolicyServerInputValidate = $null
[System.Windows.Forms.Label]$userInputMenuKeytab = $null
[System.Windows.Forms.Button]$userInputMenuKeytabBrowse = $null
[System.Windows.Forms.OpenFileDialog]$userInputMenuKeytabInput = $null
[System.Windows.Forms.Label]$userInputMenuKeytabSelectedFile = $null
[System.Windows.Forms.Label]$userInputMenuKrb5 = $null
[System.Windows.Forms.Button]$userInputMenuKrb5Browse = $null
[System.Windows.Forms.Label]$userInputMenuKrb5SelectedFile = $null
[System.Windows.Forms.OpenFileDialog]$userInputMenuKrb5Input = $null
[System.Windows.Forms.Label]$userInputMenuCertTemplates = $null
[System.Windows.Forms.Button]$userInputMenuCertTemplatesSelect = $null
[System.Windows.Forms.Listbox]$userInputMenuCertTemplatesSelectList = $null
[System.Windows.Forms.Label]$userInputMenuCertTemplatesSelected = $null
[System.Windows.Forms.Label]$userInputMenuCheckStatusTitle = $null
[System.Windows.Forms.Label]$userInputMenuCheckStatus = $null
[System.Windows.Forms.Button]$userInputMenuCheckButton = $null
[System.Windows.Forms.Button]$userInputMenuNextButton = $null
[System.Windows.Forms.Button]$userInputMenuCancelButton = $null

function InitializeComponent
{

# Initialize each class
$userInputMenuDescription = New-Object System.Windows.Forms.label
$userInputMenuSvcAcct = New-Object System.Windows.Forms.label
$userInputMenuSvcAcctInput = New-Object System.Windows.Forms.TextBox
$userInputMenuSvcAcctInputValidate = New-Object System.Windows.Forms.Label
$userInputMenuPolicyServer = New-Object System.Windows.Forms.label
$userInputMenuPolicyServerInput = New-Object System.Windows.Forms.TextBox
$userInputMenuPolicyServerInputValidate = New-Object System.Windows.Forms.Label
$userInputMenuKeytab = New-Object System.Windows.Forms.label
$userInputMenuKeytabBrowse = New-Object System.Windows.Forms.Button
$userInputMenuKeytabInput = New-Object System.Windows.Forms.OpenFileDialog
$userInputMenuKeytabSelectedFile = New-Object System.Windows.Forms.label
$userInputMenuKrb5 = New-Object System.Windows.Forms.label
$userInputMenuKrb5Browse = New-Object System.Windows.Forms.Button
$userInputMenuKrb5Input = New-Object System.Windows.Forms.OpenFileDialog
$userInputMenuKrb5SelectedFile = New-Object System.Windows.Forms.label
$userInputMenuCertTemplates = New-Object System.Windows.Forms.label
$userInputMenuCertTemplatesSelect = New-Object System.Windows.Forms.Button
$userInputMenuCertTemplatesSelectList = New-Object System.Windows.Forms.ListBox
$userInputMenuCertTemplatesSelected = New-Object System.Windows.Forms.Label
$userInputMenuCheckStatusTitle = New-Object System.Windows.Forms.Label
$userInputMenuCheckStatus = New-Object System.Windows.Forms.Label
$userInputMenuCheckButton = New-Object System.Windows.Forms.Button
$userInputMenuNextButton = New-Object System.Windows.Forms.Button
$userInputMenuCancelButton = New-Object System.Windows.Forms.Button

# user input description
$userInputMenuDescription.Location = '20,100'
$userInputMenuDescription.Size = '900,20'
$userInputMenuDescription.AutoSize = $false
$userInputMenuDescription.Text = ("Populate the text boxes and select the required files below. After completing the fields below, click the 'Check' button that appears to validate the provided information. You will not able to proceed to the next screen until all checks are successful.")

# svc account
$userInputMenuSvcAcct.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuSvcAcct.Location = '20,150'
$userInputMenuSvcAcct.AutoSize = $true
$userInputMenuSvcAcct.Text = ('Name of Service Account:')

# svc accout validate
$userInputMenuSvcAcctInput.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$userInputMenuSvcAcctInput.Location = '230,150'
$userInputMenuSvcAcctInput.Size = '200,23'
$userInputMenuSvcAcctInput.AutoSize = $false

# svc account validate
$userInputMenuSvcAcctInputValidate.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuSvcAcctInputValidate.Location = '450,150'
$userInputMenuSvcAcctInputValidate.AutoSize = $true

#policy server
$userInputMenuPolicyServer.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuPolicyServer.Location = '20,190'
$userInputMenuPolicyServer.AutoSize = $true
$userInputMenuPolicyServer.Text = ('FQDN of Policy Server:')

# policy server input
$userInputMenuPolicyServerInput.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$userInputMenuPolicyServerInput.Location = '230,190'
$userInputMenuPolicyServerInput.Size = '200,23'
$userInputMenuPolicyServerInput.AutoSize = $false

# policy server validate
$userInputMenuPolicyServerInputValidate.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuPolicyServerInputValidate.Location = '450,190'
$userInputMenuPolicyServerInputValidate.AutoSize = $true

# keytab file label
$userInputMenuKeytab.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKeytab.Location = '20,230'
$userInputMenuKeytab.AutoSize = $true
$userInputMenuKeytab.Text = ('Keytab file:')

# keytab file browse
$userInputMenuKeytabBrowse.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKeytabBrowse.Location = '230,230'
$userInputMenuKeytabBrowse.Size = '160,23'
$userInputMenuKeytabBrowse.Text = ('Browse')
$userInputMenuKeytabBrowse.Add_Click($keytabBrowse_Click)

# selected keytab file
$userInputMenuKeytabInput.InitialDirectory = [Environment]::GetFolderPath('Desktop')
$userInputMenuKeytabInput.Filter = “All files (*.*)| *.*”

# selected keytab file label
$userInputMenuKeytabSelectedFile.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKeytabSelectedFile.Location = '450,230'
$userInputMenuKeytabSelectedFile.AutoSize = $true
$userInputMenuKeytabSelectedFile.ForeColor = 'orange'

# krb5 file label
$userInputMenuKrb5.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKrb5.Location = '20,270'
$userInputMenuKrb5.AutoSize = $true
$userInputMenuKrb5.Text = ('Krb5 conf file:')

# krb5 file browse
$userInputMenuKrb5Browse.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKrb5Browse.Location = '230,270'
$userInputMenuKrb5Browse.Size = '160,23'
$userInputMenuKrb5Browse.Text = ('Browse')
$userInputMenuKrb5Browse.Add_Click($krb5_Click)

# selected krb5 file
$userInputMenuKrb5Input.InitialDirectory = [Environment]::GetFolderPath('Desktop')
$userInputMenuKrb5Input.Filter = “All files (*.*)| *.*”

# selected krb5 file label
$userInputMenuKrb5SelectedFile.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuKrb5SelectedFile.Location = '450,270'
$userInputMenuKrb5SelectedFile.AutoSize = $true
$userInputMenuKrb5SelectedFile.ForeColor = 'orange'

#Certificate templates label
$userInputMenuCertTemplates.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$userInputMenuCertTemplates.Location = '20,310'
$userInputMenuCertTemplates.AutoSize = $true
$userInputMenuCertTemplates.Text = ('Certificate Templates:')

#Certificate template selection button
$userInputMenuCertTemplatesSelect.Location = '230,305'
$userInputMenuCertTemplatesSelect.Size = '160,23'
$userInputMenuCertTemplatesSelect.Text = 'Select Templates'
$userInputMenuCertTemplatesSelect.Add_Click($selectTemplate_Click)

#Certificate template selection form
$userInputMenuCertTemplatesSelectList.Location = '10,40'
$userInputMenuCertTemplatesSelectList.Size = '360,20'
$userInputMenuCertTemplatesSelectList.SelectedItems

#Certificate template selected templates
$userInputMenuCertTemplatesSelected.Location = '450,305'
$userInputMenuCertTemplatesSelected.Size = '400,150'
$userInputMenuCertTemplatesSelected.AutoSize = $false
$userInputMenuCertTemplatesSelected.ForeColor = 'orange'

# check status title
$userInputMenuCheckStatusTitle.Text = ('Results')
$userInputMenuCheckStatusTitle.Location = '20,375'
$userInputMenuCheckStatusTitle.AutoSize = $true
$userInputMenuCheckStatusTitle.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Underline)

# check status
$userInputMenuCheckStatus.Location = '20,410'
$userInputMenuCheckStatus.Size = '500,150'
$userInputMenuCheckStatus.AutoSize = $false

# check button
$userInputMenuCheckButton.Text = 'Check'
$userInputMenuCheckButton.Location = '625,500'
$userInputMenuCheckButton.BackColor = 'WhiteSmoke'
$userInputMenuCheckButton.Size = '100,40'
$userInputMenuCheckButton.Add_Click($check_Click)

# next button
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
# $userInputMenu.WindowState = 'Maximized'
# $userInputMenu.MdiParent = $toolKitApp
# $userInputMenu.IsMdiChild
$userInputMenu.MinimizeBox = $false
$userInputMenu.BackColor = 'White'
$userInputMenu.Size = '1000,600'
$userInputMenu.FormBorderStyle = 'FixedDialog'
$userInputMenu.Font = [System.Drawing.Font]::new("Times New Roman", 12)

# Add controls to form
$userInputMenu.Controls.Add($userInputMenuDescription)
$userInputMenu.Controls.Add($userInputMenuUserInputValidate)
$userInputMenu.Controls.Add($userInputMenuSvcAcct)
$userInputMenu.Controls.Add($userInputMenuSvcAcctInput)
$userInputMenu.Controls.Add($userInputMenuSvcAcctInputValidate)
$userInputMenu.Controls.Add($userInputMenuPolicyServer)
$userInputMenu.Controls.Add($userInputMenuPolicyServerInput)
$userInputMenu.Controls.Add($userInputMenuPolicyServerInputValidate)
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
$userInputMenu.Controls.Add($userInputMenuCheckStatus)
$userInputMenu.Controls.Add($userInputMenuCancelButton)

}

. InitializeComponent