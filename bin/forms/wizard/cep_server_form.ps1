# change navigation panel colors
$CepServerForm_Shown = {

    $NavigationItem1.ForeColor = 'Black'
}

$Yes_Click = {

    $CepServerForm.Controls.Remove($CepServerFormRequirementsWarning)
    $CepServerFormNextButton.Enabled = $true

}

$No_Click = {

    $CepServerForm.Controls.Add($CepServerFormRequirementsWarning)
    $CepServerFormNextButton.Enabled = $true

}

$Next_Click = {

    if([string]::IsNullOrEmpty($CepServerFormCepNameTextBox.Text)){
        
        # change color to orange, INFO $logFilerm user validation is occuring, and write to log
        $CepServerFormCepNameStatus.ForeColor = 'red'
        $CepServerFormCepNameStatus.Text = "The CEP server name field cannot be empty`n"

    }

    else {
        
        # store text for validation
        $Global:CepServer = $CepServerFormCepNameTextBox.Text

        # focus on service account form to bring it to the front
        $ServiceAccountForm.Show()
        $CepServerForm.Close()

    }
}

$Cancel_Click = {

    $ToolKitApp.Close()

}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $ScriptRoot '\bin\designs\wizard\cep_server_design.ps1')