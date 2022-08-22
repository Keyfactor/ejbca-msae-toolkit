# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

# Log file
$LogFile = "$PSScriptRoot\toolkit.log"

# Keyfactor logo
$keyfactor_image = [System.Drawing.Image]::FromFile("$PSScriptRoot\keyfactor_logo.png")

# Global variables
# Reset to $null before each run
$Global:clientUser = $null
$Global:clientComputer = $null

function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyyMMdd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}

function Show-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11

    [Console.Window]::ShowWindow($consolePtr, 4)
}

function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot '\form-designs\tool_kit_container_design.ps1') | Out-Null


$toolKitApp.Add_Shown({
    $toolKitApp.Activate()
    Hide-Console
})

. (Join-Path $PSScriptRoot '\forms\welcome_menu.ps1') | Out-Null

. (Join-Path $PSScriptRoot '\forms\selection_menu.ps1') | Out-Null

. (Join-Path $PSScriptRoot '\forms\prerequisites.ps1') | Out-Null

#. (Join-Path $PSScriptRoot '\forms\prerequisites_check.ps1') | Out-Null

. (Join-Path $PSScriptRoot '\forms\user_input_menu.ps1') | Out-Null

$welcomeMenu.Add_Shown({
    $welcomeMenu.Focus()
})

#Main control
$toolKitApp.ShowDialog()
