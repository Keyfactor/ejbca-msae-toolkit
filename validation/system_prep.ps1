

#Sys prep process form
$toolKitSysPrepForm = New-Object System.Windows.Forms.Form
$toolKitSysPrepForm.Text = ('System Preparation')
$toolKitSysPrepForm.Size = '800,800'
$toolKitSysPrepForm.MaximizeBox = $False
$toolKitSysPrepForm.MinimizeBox = $False
$toolKitSysPrepForm.ControlBox = $true
$toolKitSysPrepForm.BackColor = 'Ivory'
$toolKitSysPrepForm.StartPosition = 1

#Sys prep title
$toolKitSysPrepTitle = New-Object System.Windows.Forms.Label
$toolKitSysPrepTitle.Font = [System.Drawing.Font]::new("Times New Roman", 14, [System.Drawing.FontStyle]::Underline)
$toolKitSysPrepTitle.Location = '20,20'
$toolKitSysPrepTitle.AutoSize = $true
$toolKitSysPrepTitle.Text = ('System Preperation')

#Sys prep description
$toolKitSysPrepDescription = New-Object System.Windows.Forms.label
$toolKitSysPrepDescription.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepDescription.Location = '20,60'
$toolKitSysPrepDescription.Size = '725,60' 
$toolKitSysPrepDescription.AutoSize = $false
$toolKitSysPrepDescription.Text = ("Click 'validate' to confirm the machine this tool is running on is a domain-joined member server and can install the necessary tools.")

#Sys prep validation button
$toolKitSysPrepRequirementsButton = New-Object System.Windows.Forms.Button
$toolKitSysPrepRequirementsButton.Location = '20,100'
$toolKitSysPrepRequirementsButton.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepRequirementsButton.Size = '160,25'
$toolKitSysPrepRequirementsButton.Text = "Validate"
$toolKitSysPrepForm.Controls.Add($toolKitSysPrepRequirementsButton)

#Domain validation
$toolKitSysPrepDomainValidation = New-Object System.Windows.Forms.Label
$toolKitSysPrepDomainValidation.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepDomainValidation.Location = '20,130'
$toolKitSysPrepDomainValidation.AutoSize = $true
$toolKitSysPrepDomainValidation.Text = "Domain:"

#Domain validation status
$toolKitSysPrepDomainStatus = New-Object System.Windows.Forms.Label
$toolKitSysPrepDomainStatus.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepDomainStatus.ForeColor = ""
$toolKitSysPrepDomainStatus.Location = '80,130'
$toolKitSysPrepDomainStatus.AutoSize = $true
$toolKitSysPrepDomainStatus.Text = ""

#Member server validation
$toolKitSysPrepServerValidation = New-Object System.Windows.Forms.Label
$toolKitSysPrepServerValidation.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepServerValidation.Location = '20,160'
$toolKitSysPrepServerValidation.AutoSize = $true
$toolKitSysPrepServerValidation.Text = "Member Server:"

#Member server validation status
$toolKitSysPrepServerStatus = New-Object System.Windows.Forms.Label
$toolKitSysPrepServerStatus.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepServerStatus.ForeColor = ""
$toolKitSysPrepServerStatus.Location = '130,160'
$toolKitSysPrepServerStatus.AutoSize = $true
$toolKitSysPrepServerStatus.Text = ""

#AD DS tool validation description
$toolKitSysPrepAdldsValidation = New-Object System.Windows.Forms.Label
$toolKitSysPrepAdldsValidation.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepAdldsValidation.Location = '20,190'
$toolKitSysPrepAdldsValidation.AutoSize = $true
$toolKitSysPrepAdldsValidation.Text = "Active Directory Powershell Module (ADDS RSAT):"

#AD DS tool validation status
$toolKitSysPrepAdldsInstalled = New-Object System.Windows.Forms.Label
$toolKitSysPrepAdldsInstalled.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepAdldsInstalled.ForeColor = ""
$toolKitSysPrepAdldsInstalled.Location = '385,190'
$toolKitSysPrepAdldsInstalled.AutoSize = $true
$toolKitSysPrepAdldsInstalled.Text = ""

#AD DS tool validation description
$toolKitSysPrepAdcsValidation = New-Object System.Windows.Forms.Label
$toolKitSysPrepAdcsValidation.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepAdcsValidation.Location = '20,220'
$toolKitSysPrepAdcsValidation.AutoSize = $true
$toolKitSysPrepAdcsValidation.Text = "Certificate Template Management (ADCS RSAT):"

#AD CS tool validation status
$toolKitSysPrepAdcsInstalled = New-Object System.Windows.Forms.Label
$toolKitSysPrepAdcsInstalled.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepAdcsInstalled.ForeColor = ""
$toolKitSysPrepAdcsInstalled.Location = '365,220'
$toolKitSysPrepAdcsInstalled.AutoSize = $true
$toolKitSysPrepAdcsInstalled.Text = ""

#Controls
$toolKitSysPrepForm.Controls.AddRange(@($toolKitSysPrepTitle,
$toolKitSysPrepDescription,
$toolKitSysPrepDomainValidation,
$toolKitSysPrepDomainStatus,
$toolKitSysPrepServerValidation,
$toolKitSysPrepServerStatus,
$toolKitSysPrepAdldsValidation,
$toolKitSysPrepAdldsInstalled,
$toolKitSysPrepAdcsValidation,
$toolKitSysPrepAdcsInstalled))

#Initiate button click
$toolKitSysPrepRequirementsButton.add_Click({

#Grab all data
#Get doamin
$toolKitSysPrepDomainStatus.ForeColor = 'orange'
$toolKitSysPrepDomainStatus.Text = 'Getting domain name...'
$domain = systeminfo | findstr /i "domain"
foreach($name in $domain){
    if($name -like '*Domain:*'){
    
    $toolKitSysPrepDomainStatus.ForeColor = 'green'
    $toolKitSysPrepDomainStatus.Text = $name.Substring($name.IndexOf(":")+1).Trim()

}}

$toolKitSysPrepServerStatus.ForeColor = 'orange'
$toolKitSysPrepServerStatus.Text = "Getting computer operating system..." 
$computerOS = (Get-CimInstance -ClassName Win32_OperatingSystem).caption
    
    if($computerOS -like '*Windows Server*'){

        $toolKitSysPrepServerStatus.ForeColor = 'green'
        $toolKitSysPrepServerStatus.Text = "$env:COMPUTERNAME" 

        $toolKitSysPrepAdldsInstalled.ForeColor = 'orange'
        $toolKitSysPrepAdldsInstalled.Text = "Getting ADDS RSAT tool status..." 
        $rsatAdldsInstalled = Get-WindowsFeature -Name RSAT-ADDS-Tools | select InstallState

        if($rsatAdldsInstalled.InstallState -eq 'Installed'){

            $toolKitSysPrepAdldsInstalled.ForeColor = 'green'
            $toolKitSysPrepAdldsInstalled.Text = "Already installed" 

            } else {
              try{
                
                $toolKitSysPrepAdldsInstalled.ForeColor = 'orange'
                $toolKitSysPrepAdldsInstalled.Text = "Intalling ADDS RSAT tool..." 

                Install-WindowsFeature -Name RSAT-ADDS-Tools
                $toolKitSysPrepAdldsInstalled.ForeColor = 'green'
                $toolKitSysPrepAdldsInstalled.Text = "Successfully installed" 
    
                } catch {

                $toolKitSysPrepAdldsInstalled.ForeColor = 'red'
                $toolKitSysPrepAdldsInstalled.Text = "The ADDS and LDS tool DID NOT successfully install"


                }
            } 


        $toolKitSysPrepAdcsInstalled.ForeColor = 'orange'
        $toolKitSysPrepAdcsInstalled.Text = "Getting ADCS RSAT tool status..." 
        $rsatAdcsInstalled = Get-WindowsFeature -Name RSAT-ADCS | Select-Object InstallState

        if($rsatAdcsInstalled.InstallState -eq 'Installed'){

            $toolKitSysPrepAdcsInstalled.ForeColor = 'green'
            $toolKitSysPrepAdcsInstalled.Text = "Already installed" 

            } else {
              try{

                $toolKitSysPrepAdcsInstalled.ForeColor = 'orange'
                $toolKitSysPrepAdcsInstalled.Text = "Intalling Certificate Template management..." 

     
                Install-WindowsFeature -Name RSAT-ADDS-Tools
                $toolKitSysPrepAdcsInstalled.ForeColor = 'green'
                $toolKitSysPrepAdcsInstalled.Text = "Successfully installed" 
    
                } catch {

                $toolKitSysPrepAdcsInstalled.ForeColor = 'red'
                $toolKitSysPrepAdcsInstalled.Text = "The AD DS and LDS tool DID NOT successfully install"

                }
            }
            } else {
            
            $toolKitSysPrepServerStatus.ForeColor = 'red'
            $toolKitSysPrepServerStatus.Text = "This is not a member server. Run this tool kit from a domain-joined member server."  
                }



$toolKitSysPrepForm.Controls.AddRange(@($toolKitSysPrepInputTitle,
$toolKitSysPrepInputDescription,
$toolKitSysPrepUserInputValidate,
$toolKitSysPrepSvcAcct
$toolKitSysPrepSvcAcctInput,
$toolKitSysPrepPolicyServer,
$toolKitSysPrepPolicyServerInput,
$toolKitSysPrepKeytab,
$toolKitSysPrepKeytabBrowse,
$toolKitSysPrepKeytabSelectedFile,
$toolKitSysPrepKrb5,
$toolKitSysPrepKrb5Browse,
$toolKitSysPrepKrb5SelectedFile,
$toolKitSysPrepCertTemplates,
$toolKitSysPrepCertTemplatesSelect



))

})
  
#User input title
$toolKitSysPrepInputTitle = New-Object System.Windows.Forms.Label
$toolKitSysPrepInputTitle.Font = [System.Drawing.Font]::new("Times New Roman", 14, [System.Drawing.FontStyle]::Underline)
$toolKitSysPrepInputTitle.Location = '20,260'
$toolKitSysPrepInputTitle.AutoSize = $true
$toolKitSysPrepInputTitle.Text = ('User Input')

#Uer input description
$toolKitSysPrepInputDescription = New-Object System.Windows.Forms.Label
$toolKitSysPrepInputDescription.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepInputDescription.Location = '20,300'
$toolKitSysPrepInputDescription.AutoSize = $true
$toolKitSysPrepInputDescription.Text = ('Enter or import the following and click validate. All field must validate because you can proceed.')

#User provided input validation button
$toolKitSysPrepUserInputValidate = New-Object System.Windows.Forms.Button
$toolKitSysPrepUserInputValidate.Location = '20,330'
$toolKitSysPrepUserInputValidate.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepUserInputValidate.Size = '160,23'
$toolKitSysPrepUserInputValidate.Text = ('Validate')
$toolKitSysPrepForm.Controls.Add($toolKitSysPrepTitle)

#Svc Account
$toolKitSysPrepSvcAcct = New-Object System.Windows.Forms.Label
$toolKitSysPrepSvcAcct.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepSvcAcct.Location = '20,360'
$toolKitSysPrepSvcAcct.AutoSize = $true
$toolKitSysPrepSvcAcct.Text = ('Name of Service Account:')

#Svc account input
$toolKitSysPrepSvcAcctInput = New-Object System.Windows.Forms.TextBox
$toolKitSysPrepSvcAcctInput.Font = [System.Drawing.Font]::new("Times New Roman", 10)
#$toolKitSysPrepSvcAcctInput.BackColor = 'control'
$toolKitSysPrepSvcAcctInput.Location = '230,360'
$toolKitSysPrepSvcAcctInput.Size = '200,23'
$toolKitSysPrepSvcAcctInput.AutoSize = $false
$toolKitSysPrepSvcAcctInput.Text = ""

#Policy server
$toolKitSysPrepPolicyServer = New-Object System.Windows.Forms.Label
$toolKitSysPrepPolicyServer.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepPolicyServer.Location = '20,390'
$toolKitSysPrepPolicyServer.AutoSize = $true
$toolKitSysPrepPolicyServer.Text = ('FQDN of Policy Server:')

#Policy server input
$toolKitSysPrepPolicyServerInput = New-Object System.Windows.Forms.TextBox
$toolKitSysPrepPolicyServerInput.Font = [System.Drawing.Font]::new("Times New Roman", 10)
#$toolKitSysPrepPolicyServerInput.BackColor = 'control'
$toolKitSysPrepPolicyServerInput.Location = '230,390'
$toolKitSysPrepPolicyServerInput.Size = '200,23'
$toolKitSysPrepPolicyServerInput.AutoSize = $false
$toolKitSysPrepPolicyServerInput.Text = ""

#Keytab file
$toolKitSysPrepKeytab = New-Object System.Windows.Forms.Label
$toolKitSysPrepKeytab.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepKeytab.Location = '20,420'
$toolKitSysPrepKeytab.AutoSize = $true
$toolKitSysPrepKeytab.Text = ('Keytab file:')

#Keytab file input
$toolKitSysPrepKeytabBrowse = New-Object System.Windows.Forms.Button
$toolKitSysPrepKeytabBrowse.Location = '230,420'
$toolKitSysPrepKeytabBrowse.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepKeytabBrowse.Size = '160,23'
$toolKitSysPrepKeytabBrowse.Text = ('Browse')

#Selected keytab file
#Keytab file
$toolKitSysPrepKeytabSelectedFile = New-Object System.Windows.Forms.Label
$toolKitSysPrepKeytabSelectedFile.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepKeytabSelectedFile.Location = '450,420'
$toolKitSysPrepKeytabSelectedFile.AutoSize = $true
$toolKitSysPrepKeytabSelectedFile.Text = ""


$toolKitSysPrepKeytabBrowse.Add_Click({
    
    #Keytab file selection
    $toolKitSysPrepKeytabInput = New-Object System.Windows.Forms.OpenFileDialog
    $toolKitSysPrepKeytabInput.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $toolKitSysPrepKeytabInput.Filter = “All files (*.*)| *.*”
    $toolKitSysPrepKeytabInput.ShowDialog() | Out-Null

    $toolKitSysPrepKeytabSelectedFile.Text = $toolKitSysPrepKeytabInput.FileName
    $keytabfile = $toolKitSysPrepKeytabSelectedFile.Text

})

#Krb5 file
$toolKitSysPrepKrb5 = New-Object System.Windows.Forms.Label
$toolKitSysPrepKrb5.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepKrb5.Location = '20,450'
$toolKitSysPrepKrb5.AutoSize = $true
$toolKitSysPrepKrb5.Text = ('Krb5 conf file:')

#Krb5 file input
$toolKitSysPrepKrb5Browse = New-Object System.Windows.Forms.Button
$toolKitSysPrepKrb5Browse.Location = '230,450'
$toolKitSysPrepKrb5Browse.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepKrb5Browse.Size = '160,23'
$toolKitSysPrepKrb5Browse.Text = ('Browse')

#Selected krb5 file
$toolKitSysPrepKrb5SelectedFile= New-Object System.Windows.Forms.Label
$toolKitSysPrepKrb5SelectedFile.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepKrb5SelectedFile.Location = '450,450'
$toolKitSysPrepKrb5SelectedFile.AutoSize = $true
$toolKitSysPrepKrb5SelectedFile.Text = ""


$toolKitSysPrepKrb5Browse.Add_Click({
    
    #Keytab file selection
    $toolKitSysPrepKrb5Input = New-Object System.Windows.Forms.OpenFileDialog
    $toolKitSysPrepKrb5Input.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $toolKitSysPrepKrb5Input.Filter = “All files (*.*)| *.*”
    $toolKitSysPrepKrb5Input.ShowDialog() | Out-Null

    $toolKitSysPrepKrb5SelectedFile.Text = $toolKitSysPrepKrb5Input.FileName
    $krb5file = $toolKitSysPrepKrb5SelectedFile.Text

})

#Certificate templates
$toolKitSysPrepCertTemplates = New-Object System.Windows.Forms.Label
$toolKitSysPrepCertTemplates.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepCertTemplates.Location = '20,480'
$toolKitSysPrepCertTemplates.AutoSize = $true
$toolKitSysPrepCertTemplates.Text = ('Certificate Templates:')



$certificateTemplates = certutil -template

#Store certificate templates in new string and split into individual lines for parsing
$str = $certificateTemplates -split [environment]::NewLine

#Loop through each line and store the TemplatePropCommanName in the $certificate_templates variable
#Each line is trimmed to include only the name
$certificateTemplates = foreach ($line in $str) {

    if ($line -like '*TemplatePropCommonName*') {

    ($line -split "=")[1].Trim()

    }
}

#Certificate template selection form
$toolKitSysPrepCertTemplatesSelect = New-Object System.Windows.Forms.Button
$toolKitSysPrepCertTemplatesSelect.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepCertTemplatesSelect.Location = '230,480'
$toolKitSysPrepCertTemplatesSelect.Size = '160,23'
$toolKitSysPrepCertTemplatesSelect.Text = 'Select Templates'
$toolKitSysPrepCertTemplatesSelect.AutoSize = $true

#Certificate template selection form
$toolKitSysPrepCertTemplatesSelectList = New-Object System.Windows.Forms.Listbox
$toolKitSysPrepCertTemplatesSelectList.Location = New-Object System.Drawing.Point(10,40)
$toolKitSysPrepCertTemplatesSelectList.Size = New-Object System.Drawing.Size(360,20)
$toolKitSysPrepCertTemplatesSelectList.SelectedItems
#$toolKitSysPrepCertTemplatesSelectList.Text = ""

#Certificate template selected templates
$toolKitSysPrepCertTemplatesSelected = New-Object System.Windows.Forms.Label
$toolKitSysPrepCertTemplatesSelected.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$toolKitSysPrepCertTemplatesSelected.Location = '425,480'
$toolKitSysPrepCertTemplatesSelected.Size = '160,300'
$toolKitSysPrepCertTemplatesSelected.AutoSize = $false
$toolKitSysPrepCertTemplatesSelected.Text =  ""


$selectedCertTemplates = @()

$toolKitSysPrepCertTemplatesSelect.Add_Click({

    $toolKitSysPrepCertTemplatesSelectForm = New-Object System.Windows.Forms.Form
    $toolKitSysPrepCertTemplatesSelectForm.Text = 'MSAE Mapped Certificate Templates'
    $toolKitSysPrepCertTemplatesSelectForm.Size = New-Object System.Drawing.Size(400,415)
    $toolKitSysPrepCertTemplatesSelectForm.StartPosition = 'CenterScreen'

    $toolKitSysPrepCertTemplatesSelectOk = New-Object System.Windows.Forms.Button
    $toolKitSysPrepCertTemplatesSelectOk.Location = New-Object System.Drawing.Point(150,340)
    $toolKitSysPrepCertTemplatesSelectOk.Size = New-Object System.Drawing.Size(60,23)
    $toolKitSysPrepCertTemplatesSelectOk.Text = 'Select'
    $toolKitSysPrepCertTemplatesSelectOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $toolKitSysPrepCertTemplatesSelectForm.AcceptButton = $toolKitSysPrepCertTemplatesSelectOk
    $toolKitSysPrepCertTemplatesSelectForm.Controls.Add($toolKitSysPrepCertTemplatesSelectOk)

    $toolKitSysPrepCertTemplatesSelectCancel = New-Object System.Windows.Forms.Button
    $toolKitSysPrepCertTemplatesSelectCancel.Location = New-Object System.Drawing.Point(250,340)
    $toolKitSysPrepCertTemplatesSelectCancel.Size = New-Object System.Drawing.Size(75,23)
    $toolKitSysPrepCertTemplatesSelectCancel.Text = 'Cancel'
    $toolKitSysPrepCertTemplatesSelectCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $toolKitSysPrepCertTemplatesSelectForm.CancelButton = $toolKitSysPrepCertTemplatesSelectCancel
    $toolKitSysPrepCertTemplatesSelectForm.Controls.Add($toolKitSysPrepCertTemplatesSelectCancel)

    $toolKitSysPrepCertTemplatesSelectTitle = New-Object System.Windows.Forms.Label
    $toolKitSysPrepCertTemplatesSelectTitle.Location = New-Object System.Drawing.Point(10,20)
    $toolKitSysPrepCertTemplatesSelectTitle.Size = New-Object System.Drawing.Size(280,20)
    $toolKitSysPrepCertTemplatesSelectTitle.Text = 'Select all the certificate templates in Active Directory that are mapped in EJBCA":'
    $toolKitSysPrepCertTemplatesSelectForm.Controls.Add($toolKitSysPrepCertTemplatesSelectTitle)

    $toolKitSysPrepCertTemplatesSelectList.SelectionMode = 'MultiExtended'

    foreach($template in $certificateTemplates){

    [void] $toolKitSysPrepCertTemplatesSelectList.Items.Add($template)

    }

    $toolKitSysPrepCertTemplatesSelectList.Height = 300
    $toolKitSysPrepCertTemplatesSelectForm.Controls.Add($toolKitSysPrepCertTemplatesSelectList)
    $toolKitSysPrepCertTemplatesSelectForm.Topmost = $true

    $result = $toolKitSysPrepCertTemplatesSelectForm.ShowDialog()

        #Log selected certificate templates in $selected_cert_templates
        if ($result -eq [System.Windows.Forms.DialogResult]::OK){

            $toolKitSysPrepCertTemplatesSelected.Text = $toolKitSysPrepCertTemplatesSelectList.SelectedItems

            $toolKitSysPrepForm.Controls.Add($toolKitSysPrepNext)
            }

        #Exit script if cancelled or dialog box was closed was selected in the MSAE Mapped Certificate Templates

        if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
            $toolKitSysPrepCertTemplatesSelectForm.Close()
        }


})


$toolKitSysPrepForm.Controls.Add($toolKitSysPrepTitle)

#Next button
$toolKitSysPrepNext = New-Object System.Windows.Forms.Button
$toolKitSysPrepNext.Text = 'Next'
$toolKitSysPrepNext.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepNext.Location = '525,475'
$toolKitSysPrepNext.Size = '100,40' 
 
#Cancel button
$toolKitSysPrepCancel = New-Object System.Windows.Forms.Button
$toolKitSysPrepCancel.Text = "Cancel"
$toolKitSysPrepCancel.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$toolKitSysPrepCancel.Location = '650,475'
$toolKitSysPrepCancel.Size = '100,40'

#Controls
$toolKitSysPrepForm.Controls.Add($toolKitSysPrepCertTemplatesSelected)
$toolKitSysPrepForm.Controls.Add($toolKitSysPrepCancel)


    $toolKitSysPrepNext.Add_Click({
        
        $toolKitSysPrepForm.Close()        

    })
    $toolKitSysPrepCancel.Add_Click({

    . "$PSScriptRoot\toolkit_description_form.ps1" 

        $toolKitSysPrepForm.Close() 

    })


$toolKitSysPrepForm.ShowDialog()