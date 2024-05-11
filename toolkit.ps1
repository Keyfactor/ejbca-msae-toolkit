<#
Name:
PS Toolbox Main Script

Description:
This tool is designed to validate an already configured MSAE integration with options to interactively resolve identified issues.
A support bundle can be generated if the user does not wish to use the interactive session.

Notes:

Change log:
Author              Date            Notes
Jamie Garner        3/27/2024        Created initial tool
#>

#Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $ERROR.Clear();
Clear-Host

# Toolbox Configuration
$Global:ToolBoxConfig = [PSCustomObject]@{
    ScriptHome = $PSScriptRoot
    ScriptExit = $false
    TestingMode = $true
    DomainFqdn = [String]
    DomainDn = [String]
    InteractiveMode = $false
    OS = $env:OS 
    ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
    Files = $env:Home
    Classes = "bin\classes\main.ps1"
    Variables = "bin\variables.ps1"
    ConfigurationFile = "$PSScriptRoot\main.conf"
    Functions = "$PSScriptRoot\bin\functions"
    Scripts = "$PSScriptRoot\bin\scripts"
    Tools = "$PSScriptRoot\bin\scripts"
    LogLevel = "INFO"
    LogDirectory = "$PSScriptRoot\logs"
    LogFiles = @{
        Main = "main.log"
        Config = "config.log"
    }
    Modules = @(
        "DnsClient",
        "ActiveDirectory"
    )
    DefaultServiceAccountExpiration = 365
    KeytabEncryptionTypes = "AES256"
}

try {

    # Create new log every time script runs
    if($ToolBoxConfig.TestingMode){
        Remove-Item "$($ToolBoxConfig.LogDirectory)\$($ToolBoxConfig.LogFiles.Main)" -ErrorAction SilentlyContinue | Out-Null 
        New-Item "$($ToolBoxConfig.LogDirectory)\$($ToolBoxConfig.LogFiles.Main)" -ErrorAction SilentlyContinue | Out-Null 
    }

    # Import source scripts
    . (Join-Path $PSScriptRoot $ToolBoxConfig.Classes -ErrorAction Stop)
    . (Join-Path $PSScriptRoot $ToolBoxConfig.Variables -ErrorAction Stop)

    # Create logger
    $LoggerMain = [WriteLog]::New(
        $ToolBoxConfig.LogDirectory, 
        $ToolBoxConfig.LogFiles.Main, 
        $ToolBoxConfig.LogLevel, 
        "KF.Toolkit.Main"
    )
    $LoggerMain.Info("------------------NEW SCRIPT RUN------------------")

    # Execute pretasks
    . (Join-Path $ToolBoxConfig.Scripts "main_pretasks.ps1" -ErrorAction Stop)
    $Tools|ForEach-Object{$Index = 1}{
        $_ | Add-Member -MemberType NoteProperty -Name Choice -Value $Index; $Index++
    }

    # Main Menu
    do {

        Write-Host $Main.Description -ForegroundColor Blue
        Write-Host ($Tools|Format-Table @{e="Choice";w=8;a="l"}, @{e="Title";w=30}, @{e="Description"} -Wrap|Out-String) `
            -ForegroundColor Blue `
            -NoNewline

        #$ToolSelection = Read-Host "Selection"
        $ToolSelection = 1
        if($ToolSelection -ne "quit" -and $ToolSelection){
            # Load tool config and script based on selection
            #Clear-Host
            $Global:ToolCurrent = $Tools.where({$_.Choice -eq $ToolSelection})
            . (Join-Path $ToolBoxConfig.Tools $ToolCurrent.Script -ErrorAction Stop)
        }
        #Write-Host "`n"
        #Clear-Host

    }
    until($ToolSelection -eq "quit" -or $ToolBoxConfig.ScriptExit)

}
catch {
    Write-Host "Error: $($Error[0])" -ForegroundColor Red
    Write-Host "Line: $(($Error[0].InvocationInfo.Line).Trim())" -ForegroundColor Red
    Write-Host "StackTrace: $($Error[0].ScriptStackTrace)" -ForegroundColor Red
}

