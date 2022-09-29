<#
Name:
MSAE Auto-Enrollment ToolKit Script

Description:
This script is designed to validate an already configured MS Auto-Autoenrollment (MSAE) EJBCA Integration. 

Notes:

Change log:
Author              Date            Notes
Jamie Garner        9.16.22         Created initial functions
#>

Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $ERROR.Clear();

#region Imports Functions and Variables
# import functions
. "\\surface\Users\jamie\OneDrive\Documents\Programming\MSAE-Tool\bin\functions\functions.ps1"

# import conf
. "\\surface\Users\jamie\OneDrive\Documents\Programming\MSAE-Tool\conf\conf.ps1"

# import variables
. "\\surface\Users\jamie\OneDrive\Documents\Programming\MSAE-Tool\bin\variables\variables.ps1"
#endregion

#region Create Log Files
CreateLogFiles -Logs $LogFiles -LogFileDirectory $LogFileDir -LogRetention $LogRetention -Testing  | Out-Null
#endregion

#region Build any envrionmental variables ##
# Get forest name
$ForestName = Get-ADDomain
# Make forest name uppercase
$ForestName = ($forestName.Forest).ToUpper()
#endregion

#region Main ToolKit and navigation
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $ScriptRoot '\bin\designs\extras\toolkit_design.ps1') | Out-Null

# add navigation panel
. (Join-Path $ScriptRoot '\bin\designs\extras\navigation_panel.ps1') | Out-Null
#endregion

#region Wizard and tool forms
. (Join-Path $ScriptRoot '\bin\forms\wizard\cep_server_form.ps1') | Out-Null

. (Join-Path $ScriptRoot '\bin\forms\wizard\service_account_form.ps1') | Out-Null

. (Join-Path $ScriptRoot '\bin\forms\wizard\create_service_account_form.ps1') | Out-Null

#$CepServerForm.Show()
#$ServiceAccountForm.Show()
$CreateServiceAccountForm.Show()
 
$ToolKitApp.ShowDialog()