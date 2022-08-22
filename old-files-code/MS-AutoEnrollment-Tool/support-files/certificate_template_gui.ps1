Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$domainDN = (Get-ADDomain).DistinguishedName 
#Load DN into ADSI
$ADSI = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services, CN=Services, CN=Configuration, $domainDN"

#Arrays for mapping




#Main form
$guiCertificateTemplate = New-Object System.Windows.Forms.Form
$guiCertificateTemplate.Text = ('Certificate Template Generator')
$guiCertificateTemplate.Width = 800
$guiCertificateTemplate.Height = 600
$guiCertificateTemplate.AutoSize = $false
$guiCertificateTemplate.ShowDialog()

$guiCertificateTemplateExistingLabel = New-Object System.Windows.Forms.Label
$guiCertificateTemplateExistingLabel.Text = "Select a certificate template to duplicate from the drop-down:"
$guiCertificateTemplateExistingLabel.Font = [System.Drawing.Font]::new("Times New Roman", 12)
$guiCertificateTemplateExistingLabel.Location = New-Object System.Drawing.Point(20,10)
$guiCertificateTemplateExistingLabel.AutoSize = $true

#Existing certificate templates drop-down
$guiCertificateTemplateDropDown = New-Object System.Windows.Forms.ComboBox
$guiCertificateTemplateDropDown.Width = 250

#Query container for existing certificate templates
$existingCertificateTemplates = foreach($template in $ADSI.Children){
    
    $existingCertificateTemplates = $template

$guiCertificateTemplateDropDown.Items.AddRange($existingCertificateTemplates.Name); 
}

$guiCertificateTemplateDropDown.SelectedValue
$guiCertificateTemplateDropDown.Location = New-Object System.Drawing.Point(20,50)

### Attribute fields to the form for selected template ###
#Attribute section header
$guiCertificateTemplateAtrributes = New-Object System.Windows.Forms.Label
$guiCertificateTemplateAtrributes.Text = "Template to Duplicate"
$guiCertificateTemplateAtrributes.Font = [System.Drawing.Font]::new("Times New Roman", 10, [System.Drawing.FontStyle]::Underline)
$guiCertificateTemplateAtrributes.Location = New-Object System.Drawing.Point(150,90)
$guiCertificateTemplateAtrributes.AutoSize = $true

#Name
$guiCertificateTemplateName = New-Object System.Windows.Forms.Label
$guiCertificateTemplateName.Text = "Certificate Template Name:"
$guiCertificateTemplateName.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiCertificateTemplateName.Location  = New-Object System.Drawing.Point(20,120)
$guiCertificateTemplateName.AutoSize = $true

#Subject
$guiCertificateTemplateSubject = New-Object System.Windows.Forms.Label
$guiCertificateTemplateSubject.Text = "Certificate Template Subject Format:"
$guiCertificateTemplateSubject.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiCertificateTemplateSubject.Location  = New-Object System.Drawing.Point(20,150)
$guiCertificateTemplateSubject.AutoSize = $true

#Auto-Enroll
$guiCertificateTemplateAutoEnroll = New-Object System.Windows.Forms.Label
$guiCertificateTemplateAutoEnroll.Text = "Groups with Auto-Enroll Permission:"
$guiCertificateTemplateAutoEnroll.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiCertificateTemplateAutoEnroll.Location  = New-Object System.Drawing.Point(20,190)
$guiCertificateTemplateAutoEnroll.AutoSize = $true

#EKU
$guiCertificateTemplateEKU = New-Object System.Windows.Forms.Label
$guiCertificateTemplateEKU.Text = "Certificate Template EKUs:"
$guiCertificateTemplateEKU.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiCertificateTemplateEKU.Location  = New-Object System.Drawing.Point(20,240)
$guiCertificateTemplateEKU.AutoSize = $true

$guiCertificateTemplate.Controls.Add($guiCertificateTemplateAtrributes)
$guiCertificateTemplate.Controls.Add($guiCertificateTemplateName)
$guiCertificateTemplate.Controls.Add($guiCertificateTemplateSubject)
$guiCertificateTemplate.Controls.Add($guiCertificateTemplateAutoEnroll)
$guiCertificateTemplate.Controls.Add($guiCertificateTemplateEKU)

### Template attributes fields to populate after template query ###
#name
$guiSelectedCertificateTemplateName = New-Object System.Windows.Forms.Label
$guiSelectedCertificateTemplateName.Text = ""
$guiSelectedCertificateTemplateName.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiSelectedCertificateTemplateName.Location  = New-Object System.Drawing.Point(200,120)
$guiSelectedCertificateTemplateName.AutoSize = $true

#Subject
$guiSelectedCertificateTemplateSubject = New-Object System.Windows.Forms.Label
$guiSelectedCertificateTemplateSubject.Text = ""
$guiSelectedCertificateTemplateSubject.Width = 100
$guiSelectedCertificateTemplateSubject.Height = 60
$guiSelectedCertificateTemplateSubject.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiSelectedCertificateTemplateSubject.Location  = New-Object System.Drawing.Point(250,150)
$guiSelectedCertificateTemplateSubject.AutoSize = $true

#Auto-Enroll
$guiSelectedCertificateTemplateAutoEnroll = New-Object System.Windows.Forms.Label
$guiSelectedCertificateTemplateAutoEnroll.Text = ""
$guiSelectedCertificateTemplateAutoEnroll.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiSelectedCertificateTemplateAutoEnroll.Location  = New-Object System.Drawing.Point(200,190)
$guiSelectedCertificateTemplateAutoEnroll.AutoSize = $true

#EKU
$guiSelectedCertificateTemplateEKU = New-Object System.Windows.Forms.Label
$guiSelectedCertificateTemplateEKU.Text = ""
$guiSelectedCertificateTemplateEKU.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiSelectedCertificateTemplateEKU.Location  = New-Object System.Drawing.Point(200,240)
$guiSelectedCertificateTemplateEKU.AutoSize = $false


### Attribute fields to the form for New template ###
#Attribute section header
$guiNewCertificateTemplateAtrributes = New-Object System.Windows.Forms.Label
$guiNewCertificateTemplateAtrributes.Text = "Template to Duplicate"
$guiNewCertificateTemplateAtrributes.Font = [System.Drawing.Font]::new("Times New Roman", 10, [System.Drawing.FontStyle]::Underline)
$guiNewCertificateTemplateAtrributes.Location = New-Object System.Drawing.Point(150,240)
$guiNewCertificateTemplateAtrributes.AutoSize = $true

$guiCertificateTemplate.Controls.Add($guiNewCertificateTemplateAtrributes)

#Name
$guiNewCertificateTemplateName = New-Object System.Windows.Forms.Label
$guiNewCertificateTemplateName.Text = "Certificate Template Name:"
$guiNewCertificateTemplateName.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiNewCertificateTemplateName.Location  = New-Object System.Drawing.Point(20,270)
$guiNewCertificateTemplateName.AutoSize = $true

#Subject
$guiNewCertificateTemplateSubject = New-Object System.Windows.Forms.Label
$guiNewCertificateTemplateSubject.Text = "Certificate Template Subject Format:"
$guiNewCertificateTemplateSubject.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiNewCertificateTemplateSubject.Location  = New-Object System.Drawing.Point(20,300)
$guiNewCertificateTemplateSubject.AutoSize = $true

#Auto-Enroll
$guiNewCertificateTemplateAutoEnroll = New-Object System.Windows.Forms.Label
$guiNewCertificateTemplateAutoEnroll.Text = "Groups with Auto-Enroll Permission:"
$guiNewCertificateTemplateAutoEnroll.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiNewCertificateTemplateAutoEnroll.Location  = New-Object System.Drawing.Point(20,330)
$guiNewCertificateTemplateAutoEnroll.AutoSize = $true

#EKU
$guiNewCertificateTemplateEKU = New-Object System.Windows.Forms.Label
$guiNewCertificateTemplateEKU.Text = "Certificate Template EKUs:"
$guiNewCertificateTemplateEKU.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiNewCertificateTemplateEKU.Location  = New-Object System.Drawing.Point(20,360)
$guiNewCertificateTemplateEKU.AutoSize = $true

$guiCertificateTemplate.Controls.Add($guiNewCertificateTemplateName)
$guiCertificateTemplate.Controls.Add($guiNewCertificateTemplateSubject)
$guiCertificateTemplate.Controls.Add($guiNewCertificateTemplateAutoEnroll)
$guiCertificateTemplate.Controls.Add($guiNewCertificateTemplateEKU)

### Attribute fields to the form for New template ###
#Name
$guiNewCertificateTemplateNameValue = New-Object System.Windows.Forms.Label
$guiNewCertificateTemplateNameValue.Text = "New Template"
$guiNewCertificateTemplateNameValue.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiNewCertificateTemplateNameValue.Location = New-Object System.Drawing.Point(20,90)
$guiNewCertificateTemplateNameValue.AutoSize = $true

#EKU
$guiNewCertificateTemplateEKUValue = New-Object System.Windows.Forms.Listbox
$guiNewCertificateTemplateNameValue.Text = ""
$guiNewCertificateTemplateNameValue.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiNewCertificateTemplateEKUValue.Location = New-Object System.Drawing.Point(20,250)
$guiNewCertificateTemplateEKUValue.Size = New-Object System.Drawing.Size(360,20)
$guiNewCertificateTemplateEKUValue.Height = '60'

#Subject
$guiNewCertificateTemplateSubjectValue = New-Object System.Windows.Forms.Listbox
$guiNewCertificateTemplateSubjectValue.Text = ""
$guiNewCertificateTemplateSubjectValue.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiNewCertificateTemplateSubjectValue.Location = New-Object System.Drawing.Point(20,320)
$guiNewCertificateTemplateSubjectValue.Size = New-Object System.Drawing.Size(360,20)
$guiNewCertificateTemplateSubjectValue.Height = '40'

#Auto-Enroll
$guiNewCertificateTemplateAutoEnrollValue = New-Object System.Windows.Forms.TextBox
$guiNewCertificateTemplateAutoEnrollValue.Text = ""
$guiNewCertificateTemplateAutoEnrollValue.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiNewCertificateTemplateAutoEnrollValue.Location  = New-Object System.Drawing.Point(20,340)
$guiNewCertificateTemplateAutoEnrollValue.AutoSize = $true

### Add attribute fields of selected certificate template to from ###
#Add template query button
$guiCertificateTemplateQuery = New-Object System.Windows.Forms.Button
$guiCertificateTemplateQuery.Location = New-Object System.Drawing.Size(380,50)
$guiCertificateTemplateQuery.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiCertificateTemplateQuery.Size = New-Object System.Drawing.Size(160,23)
$guiCertificateTemplateQuery.Text = "Import Attributes"
$guiCertificateTemplate.Controls.Add($guiCertificateTemplateQuery)

#Add duplicate  button
$guiCertificateTemplatDuplicate = New-Object System.Windows.Forms.Button
$guiCertificateTemplatDuplicate.Location = New-Object System.Drawing.Size(575,50)
$guiCertificateTemplatDuplicate.Font = [System.Drawing.Font]::new("Times New Roman", 10)
$guiCertificateTemplatDuplicate.Size = New-Object System.Drawing.Size(160,23)
$guiCertificateTemplatDuplicate.Text = "Duplicate Template"
$guiCertificateTemplate.Controls.Add($guiCertificateTemplatDuplicate)

#Return selected results
$guiCertificateTemplateQuery.add_Click({
    $guiSelectedCertificateTemplateName.Text = $guiCertificateTemplateDropDown.selectedItem
    

    $certificateTemplates = certutil -v -template $guiCertificateTemplateDropDown.selectedItem

    #Store certificate templates in new string and split into individual lines for parsing
    $str = $certificateTemplates -split [environment]::NewLine

    #Loop through each line and store the TemplatePropCommanName in the $certificate_templates variable
    #Each line is trimmed to include only the name
        $selectedTemplateSubject = foreach ($line in $str) {

        if ($line -like '*CT_FLAG_SUBJECT_REQUIRE*') {

        ($line.Substring(0,$line.IndexOf("-"))).Trim()

            foreach($sub in $selectedTemplateSubject){
                if($sub -like '*COMMON_NAME*'){
                    $sub -replace 'CT_FLAG_SUBJECT_REQUIRE_COMMON_NAME', 'Common Name'
                }
                if($sub -like '*EMAIL*'){
                    $sub -replace 'CT_FLAG_SUBJECT_REQUIRE_EMAIL', 'Require Email'
                } 
            }
        }
}
    $selectedTemplateEKUs = @()
    foreach($template in $ADSI.Children){
        if($template.name -eq $guiCertificateTemplateDropDown.selectedItem){

        $selectedTemplateName = $template.name;
        ($selectedTemplateSubject = $template.'msPKI-Certificate-Name-Flag' -split ";").Trim()
        ($selectedTemplateEKUs=$template.pKIExtendedKeyUsage -split ";").Trim()
            }
        
        }
            
        $selectedTemplateEKUsFriendlyName = @()
        foreach($oid in $ekus){
    
        $selectedTemplateEKUsFriendlyName += New-Object System.Security.Cryptography.Oid("$oid")
        
                } 

        
            
    $guiSelectedCertificateTemplateSubject.Text = $selectedTemplateSubject
    $guiSelectedCertificateTemplateEKU.Text = $selectedTemplateEKUsFriendlyName.FriendlyName



    
})

### Controls ###
#Selected template
$guiCertificateTemplate.Controls.Add($guiSelectedCertificateTemplateName)
$guiCertificateTemplate.Controls.Add($guiSelectedCertificateTemplateSubject)
$guiCertificateTemplate.Controls.Add($guiSelectedCertificateTemplateAutoEnroll)
$guiCertificateTemplate.Controls.Add($guiSelectedCertificateTemplateEKU)


#Add existing template label
$guiCertificateTemplate.Controls.Add($guiCertificateTemplateExistingLabel)
#Add existing template drop-down
$guiCertificateTemplate.Controls.Add($guiCertificateTemplateDropDown)




#Show GUI
$guiCertificateTemplate.ShowDialog() 
