<#
.Synopsis
Microsoft Authoenrollment Configuration Toolbox

.Description
This tool is designed to validate an already configured MSAE integration with options to interactively resolve identified issues.
A support bundle can be generated if the user does not wish to use the interactive session.

.Parameter UseDefaults
Bypass all prompts that already contain default files defined in provided configuration file.

.Parameter ConfigFile
Specify a configuration file other than the default.

.Parameter Tool
Manually selection a tool to bypass the main menu. This should only be used during testing.

.Parameter Tool
Enable testing features.
#>

param(
    [Parameter(Mandatory=$false)][Switch]$UseDefaults,
    [Parameter(Mandatory=$false)][String]$ConfigFile="$PSScriptRoot\main.conf",
    [Parameter(Mandatory=$false)][Switch]$TestMode
)

# Toolbox Configuration
$Global:ToolBoxConfig = [PSCustomObject]@{
    ScriptHome = $PSScriptRoot
    ScriptExit = $false
    UseDefaults = $UseDefaults
    Testing = $TestMode
    DomainFqdn = [String]
    DomainDn = [String]
    InteractiveMode = $false
    OS = $env:OS 
    ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
    Files = "$PSScriptRoot\files"
    Classes = "bin\classes\main.ps1"
    Variables = "bin\variables.ps1"
    ConfigurationFile = $ConfigFile
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
    # Create new log every time script runs
    if($ToolBoxConfig.Testing){
        Remove-Item "$($ToolBoxConfig.LogDirectory)\$($ToolBoxConfig.LogFiles.Main)" -ErrorAction SilentlyContinue | Out-Null 
        New-Item "$($ToolBoxConfig.LogDirectory)\$($ToolBoxConfig.LogFiles.Main)" -ErrorAction SilentlyContinue | Out-Null 
    }
    else {
        $LoggerMain.Info("`n`n------------------NEW SCRIPT RUN------------------")
        Clear-Host
    }

    # Execute pretasks
    . (Join-Path $ToolBoxConfig.Scripts "main_pretasks.ps1" -ErrorAction Stop)
    $Tools|ForEach-Object{$Index = 1}{
        $_ | Add-Member -MemberType NoteProperty -Name Choice -Value $Index; $Index++
    }

    # Main Menu
    do {

        if($ToolBoxConfig.Testing -and ($MyInvocation.BoundParameters.Keys -contains "Tool")){
            $ToolSelection = $Tool
        } else {
            Write-Host $Main.Description -ForegroundColor Blue
            Write-Host ($Tools|Format-Table @{e="Choice";w=8;a="l"}, @{e="Title";w=30}, @{e="Description"} -Wrap|Out-String) `
                -ForegroundColor Blue `
                -NoNewline

            # Selection prompt
            $SelectionMessage = "Make a selection from the available list above"
            $SelectionColor = "Gray"
            while($true) {
                $ToolSelection = Read-HostPrompt $SelectionMessage -Color $SelectionColor
                if($ToolSelection -in 1..$Tools.Count){
                    Clear-Host; break
                } else {
                    $SelectionMessage = "Invalid selection. Enter a number from the list above"
                    $SelectionColor = "Yellow"
                }
            } 
        }

        if($ToolSelection -ne "quit" -and $ToolSelection){
            # Load tool config and script based on selection

            $Global:ToolCurrent = $Tools.where({$_.Choice -eq $ToolSelection})
            Write-Host "$($ToolCurrent.Title)`n" -ForegroundColor Blue 
            foreach($V in $ToolCurrent.DescriptionVerbose){
                Write-Host "- $V" -ForegroundColor Blue 
            }
            Read-HostPrompt "`nHit any key to start..." -NoInput
            
            . (Join-Path $ToolBoxConfig.Tools $ToolCurrent.Script -ErrorAction Stop)

            Read-HostPrompt "`nHit any key to continue to return to the main menu..." -NoInput
        }

        if(-not $ToolBoxConfig.Testing){Clear-Host}

    }
    until($ToolSelection -eq "quit" -or $ToolBoxConfig.ScriptExit)

}
catch {
    Write-Host "Error: $($Error[0])" -ForegroundColor Red
}

