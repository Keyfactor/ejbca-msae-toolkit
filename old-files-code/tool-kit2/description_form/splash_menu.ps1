Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'splash_menu.designer.ps1')



$MSAEToolKit.ShowDialog()
