$next_Click = {

    $userInputMenu.Focus()

}

$cancel_Click = {

    $toolKitApp.Close() | Out-Null

}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot '..\form-designs\prerequisites_design.ps1')

$prerequisites.Show()