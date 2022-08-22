$Configuration_Click = {
    $SelectionDescription.Text = 'Configuration Sample Text'

	$ToolOverview.Controls.Add($OverviewNextButton)
}
$Validation_Click = {
    $SelectionDescription.Text ='This tool will validate previously configured MSAE settings and remediate misconfigurations. You will be asked to input data specific to your MSAE implementation and the validation process will confirm all configurations before proceeding presenting the conifguration test.

If the tool is unable to make the configuration change, due to an error or permission restriction, a text output of the change will be provided for manual implementation.At the end of the validation steps, the option will be given to generate a support bundle for Keyfactor support.'
    $ToolOverview.Controls.Add($OverviewNextButton)
}

$OverviewNextButton_Click = {
    $ToolOverview.DialogResult = 'OK'
    $ToolOverview.Close()
}
$OverviewCancelButton_Click = {
    $ToolOverview.DialogResult = 'Cancel'
    $ToolOverview.Close()
}
#}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'description_form.designer.ps1')

$ToolOverview.ShowDialog()

