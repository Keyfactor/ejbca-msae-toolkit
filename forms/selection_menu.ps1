
$config_Click = {

    $selectionMenuToolDescription.Text = "The 'Configuration' Tool is not currently available. It will be available in a future release. Please select the Validation and Testing option to continue."

    }

$validation_Click = {

    $selectionMenuToolDescription.Text = 'This tool will validate previously configured MSAE settings and remediate misconfigurations. You will be asked to input data specific to your MSAE implementation and the validation process will confirm all configurations before proceeding presenting the conifguration test.

    If the tool is unable to make the configuration change, due to an error or permission restriction, a text output of the change will be provided for manual implementation.At the end of the validation steps, the option will be given to generate a support bundle for Keyfactor support.'
    
    $selectionMenu.Controls.Add($selectionMenuNextButton)

    }

$next_Click = {

    $prerequisites.Focus()

}
$cancel_Click = {

    $toolKitApp.Close() | Out-Null
}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot '..\form-designs\selection_menu_design.ps1')

$selectionMenu.Show()