# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

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


Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$toolKitApp = New-Object System.Windows.Forms.Form
$toolKitApp.Text = ('MS AutoEnrollment Tool Kit')
$toolKitApp.Name = 'ToolKitApp'
$toolKitApp.AutoSize = $true
$toolkitApp.Size = '800,800'
$toolKitApp.MaximizeBox = $False
$toolKitApp.MinimizeBox = $False
$toolKitApp.BackColor = 'SlateGray'
$toolKitApp.FormBorderStyle = 'Fixed3D'
$toolKitApp.IsMdiContainer = $true
$toolKitApp.ControlBox = $false
$toolKitApp.MdiParent

$toolKitApp.Add_Shown({
    $toolKitApp.Activate()
    Hide-Console
})

. (Join-Path $PSScriptRoot 'description_form.ps1')
$toolKitDescriptionForm.show()

. (Join-Path $PSScriptRoot 'sysprep_form.ps1')
$toolKitSysPrepForm.show()

$toolKitDescriptionForm.Add_Shown({
    $toolKitDescriptionForm.Activate()
})

#Main control
$toolKitApp.ShowDialog()
