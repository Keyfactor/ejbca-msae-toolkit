$next_Click = {

    $selectionMenu.Focus()
        
}

$cancel_Click = {

    $toolKitApp.Close() | Out-Null

}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot '..\form-designs\welcome_menu_design.ps1')

$welcomeMenu.Show()