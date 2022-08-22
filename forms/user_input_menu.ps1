$keytabBrowse_Click = {

#Keytab file selection
$userInputMenuKeytabInput = New-Object System.Windows.Forms.OpenFileDialog
$userInputMenuKeytabInput.InitialDirectory = [Environment]::GetFolderPath('Desktop')
$userInputMenuKeytabInput.Filter = “All files (*.*)| *.*”
$userInputMenuKeytabInput.ShowDialog() | Out-Null

$userInputMenuKeytabSelectedFile.Text = $userInputMenuKeytabInput.FileName
$keytabfile = $userInputMenuKeytabSelectedFile.Text

}

$krb5_Click = {

    #Keytab file selection
    $userInputMenuKrb5Input = New-Object System.Windows.Forms.OpenFileDialog
    $userInputMenuKrb5Input.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $userInputMenuKrb5Input.Filter = “All files (*.*)| *.*”
    $userInputMenuKrb5Input.ShowDialog() | Out-Null

    $userInputMenuKrb5SelectedFile.Text = $userInputMenuKrb5Input.FileName
    $krb5file = $userInputMenuKrb5SelectedFile.Text

}

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

$selectedCertTemplates = @()

$selectTemplate_Click = {

    $userInputMenuCertTemplatesSelectForm = New-Object System.Windows.Forms.Form
    $userInputMenuCertTemplatesSelectForm.Text = 'MSAE Mapped Certificate Templates'
    $userInputMenuCertTemplatesSelectForm.Size = '400,415'
    $userInputMenuCertTemplatesSelectForm.StartPosition = 'CenterScreen'

    $userInputMenuCertTemplatesSelectOk = New-Object System.Windows.Forms.Button
    $userInputMenuCertTemplatesSelectOk.Location = '150,340'
    $userInputMenuCertTemplatesSelectOk.Size = '60,23'
    $userInputMenuCertTemplatesSelectOk.Text = 'Select'
    $userInputMenuCertTemplatesSelectOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $userInputMenuCertTemplatesSelectForm.AcceptButton = $userInputMenuCertTemplatesSelectOk
    $userInputMenuCertTemplatesSelectForm.Controls.Add($userInputMenuCertTemplatesSelectOk)

    $userInputMenuCertTemplatesSelectCancel = New-Object System.Windows.Forms.Button
    $userInputMenuCertTemplatesSelectCancel.Location = '250,340'
    $userInputMenuCertTemplatesSelectCancel.Size = '75,23'
    $userInputMenuCertTemplatesSelectCancel.Text = 'Cancel'
    $userInputMenuCertTemplatesSelectCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $userInputMenuCertTemplatesSelectForm.CancelButton = $userInputMenuCertTemplatesSelectCancel
    $userInputMenuCertTemplatesSelectForm.Controls.Add($userInputMenuCertTemplatesSelectCancel)

    $userInputMenuCertTemplatesSelectTitle = New-Object System.Windows.Forms.Label
    $userInputMenuCertTemplatesSelectTitle.Location = '10,20'
    $userInputMenuCertTemplatesSelectTitle.Size = '350,20'
    $userInputMenuCertTemplatesSelectTitle.Text = 'Select the certificate templates mapped in the EJBCA MS alias:'
    $userInputMenuCertTemplatesSelectForm.Controls.Add($userInputMenuCertTemplatesSelectTitle)

    $userInputMenuCertTemplatesSelectList.SelectionMode = 'MultiExtended'

    foreach($template in $certificateTemplates){

    [void] $userInputMenuCertTemplatesSelectList.Items.Add($template)

    }

    $userInputMenuCertTemplatesSelectList.Height = 275
    $userInputMenuCertTemplatesSelectForm.Controls.Add($userInputMenuCertTemplatesSelectList)
    $userInputMenuCertTemplatesSelectForm.Topmost = $true

    $result = $userInputMenuCertTemplatesSelectForm.ShowDialog()

        #Log selected certificate templates in $selected_cert_templates
        if ($result -eq [System.Windows.Forms.DialogResult]::OK){

            $userInputMenuCertTemplatesSelected.Text = $userInputMenuCertTemplatesSelectList.SelectedItems

            $userInputMenuForm.Controls.Add($userInputMenuNext)
            }

        #Exit script if cancelled or dialog box was closed was selected in the MSAE Mapped Certificate Templates

        if ($result -eq [System.Windows.Forms.DialogResult]::Cancel){
            $userInputMenuCertTemplatesSelectForm.Close()
        }


}
    
$validate_Click = {

    $userInputMenu.Focus()
            
    }


$cancel_Click = {

$toolKitApp.Close() | Out-Null

}



Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot '..\form-designs\user_input_menu_design.ps1')

$userInputMenu.Show()