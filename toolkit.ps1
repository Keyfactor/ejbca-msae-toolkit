<#
.Synopsis
Microsoft Authoenrollment Configuration Toolbox

.Description
This tool is designed to validate an already configured MSAE integration with options to interactively resolve identified issues.
A support bundle can be generated if the user does not wish to use the interactive session.
#>
Param(
    [Parameter(Mandatory=$False, Position=0)][String]$Tool,

    # Options
    [Parameter(Mandatory=$false)]
    [Switch]$NonInteractive,
    [Parameter(Mandatory=$false)][ValidateScript({Test-Path $_})]
    [String]$Configfile = "$PSScriptRoot\main.conf",
    [Parameter(Mandatory=$false)]
    [Switch]$Help
)

################################################################################################
#region Toolkit execution
################################################################################################
try {

    Clear-Host
    ################################################################################################
    #region Toolbox Configuration
    ################################################################################################
    $Global:ToolBoxConfig = [PSCustomObject]@{
        ScriptHome = $PSScriptRoot
        ScriptExit = $false
        Debug = %{if($MyInvocation.BoundParameters.Keys -contains "Debug"){$true}else{$false}}
        NonInteractive = $NonInteractive
        DesktopMode = $false
        OS = $env:OS 
        Classes = "bin\classes\main.ps1"
        Domain = (Get-ADDomain -Current LocalComputer).DNSRoot
        ParentDomain = (Get-ADDomain -Current LocalComputer).Forest
        Variables = @{
            Main = "bin\variables\main.ps1"
            Validation = "bin\variables\validation.ps1"
        }
        ConfigurationFile = $Configfile
        Files = $PSScriptRoot
        Functions = "$PSScriptRoot\bin\functions"
        Scripts = "$PSScriptRoot\bin\scripts"
        Tools = "$PSScriptRoot\bin\scripts"
        LogLevel = %{if($MyInvocation.BoundParameters.Keys -contains "Debug"){"DEBUG"}else{"INFO"}}
        LogDirectory = "$PSScriptRoot\logs"
        LogFiles = @{
            Main = "main.log"
            Validation = "validation.log"
        }
        LogLoggers = @{
            Main = "KF.Toolkit.Main"
            Functions = "KF.Toolkit.Functions"
            Validation = "KF.Toolkit.Validation"
        }
        Modules = @(
            "ActiveDirectory"
        )
        KeytabEncryptionTypes = "AES256"
    }
    #endregion
    ################################################################################################
    
    ################################################################################################
    #region Toolkit script validation
    ################################################################################################
    $ParameterList = (Get-Command -Name $PSCmdlet.MyInvocation.InvocationName).Parameters.Values | where {$_.ParameterSets.Keys -notcontains '__AllParameterSets'}
    $ConfigurableParameters = @(foreach ($Parameter in $ParameterList) {
        if($Parameter.ParameterSets.Keys -contains 'configurable' -and $Parameter.Name -ne 'tool'){
            [PSCustomObject]@{Name = $Parameter.Name.ToLower(); Description = $Parameter.Attributes.HelpMessage}
        }
    })
        # Exit script if tool name provided but a valid option was not provided
    if($Tool.Length -and $Tool -notin $AvailableTools.Name){
        Write-Host "Invalid tool parameter provided. The available options are: $($AvailableTools.Name -join ', ')" -ForegroundColor Red
        Write-Host "Type '.\toolkit' or .\toolkit [command] -help' more information" -ForegroundColor Red
        exit 
    } 
    #endregion
    ################################################################################################

    ################################################################################################
    #region Toolkit help and tool help
    ################################################################################################
    # Print help for tool
    elseif($Tool -and $Help){ 
        $AvailableTools | where{$_.Name -eq $Tool} | ForEach-Object{
            Write-Host "[$($_.Title)]" -ForegroundColor Yellow -NoNewLine

            # Description
            Write-Host "`n - $($_.Description)" -ForegroundColor Yellow; $_.DescriptionAdditional | foreach {Write-Host " - $_" -ForegroundColor Yellow}
            # Prerequisites
            Write-Host "`n[Prerequisites]" -ForegroundColor Yellow; $_.Prerequisites | foreach {Write-Host " - $_" -ForegroundColor Yellow}
            # Variables
            Write-Host "`n[Required Variables]" -ForegroundColor Yellow; $_.RequiredVars | foreach {Write-Host " - $_" -ForegroundColor Yellow}
            if($_.OptionalVars){
                Write-Host "`n[Optional Variables]" -ForegroundColor Yellow; $_.OptionalVars | foreach {Write-Host " - $_" -ForegroundColor Yellow}
            }
            Write-Host "`n"; exit
        }
    } 
    # Print Tool Menu and exit script if no tool was provided
    elseif(-not $Tool) {
        Write-Host "$($ToolkitMenu.Description)`n`n$($ToolkitMenu.Usage)`n"

        # Tools
        Write-Host "Tools" -NoNewLine
        Write-Host $($AvailableTools.where({$_.Type -eq "tool"}) | Format-Table @{e=' ';w=2}, @{e='Name';w=30},Description -HideTableHeaders | Out-String) -NoNewLine

        # Utilities
        Write-Host "Utilities"  -NoNewLine
        Write-Host $($AvailableTools.where({$_.Type -eq "utility"}) | Format-Table @{e=' ';w=2}, @{e='Name';w=30},Description -HideTableHeaders | Out-String) -NoNewLine

        # Options
        Write-Host "Options"  -NoNewLine
        Write-Host $($ToolkitMenuOptions | Format-Table @{e=' ';w=2}, @{e={"-$($_.Name)"};w=30},Description -HideTableHeaders | Out-String) -NoNewLine

         # Configuration values
        Write-Host "Configuration File`n  The following values can be prepopulated in the config file in the section name from the description."; 
        Write-Host $($AvailableConfigValues | Format-Table @{e=' ';w=2}, @{e={"$($_.Name)"};w=30},Description -HideTableHeaders | Out-String) -NoNewLine

        # Examples
        Write-Host "Examples"; $ToolKitMenu.Examples | foreach {Write-Host "$_"}; Write-Host "`n"; exit
    }
    #endregion
    ################################################################################################

    ################################################################################################
    #region Import source scripts and execute pretasks
    ################################################################################################
    . (Join-Path $PSScriptRoot $ToolBoxConfig.Classes -ErrorAction Stop)
    . (Join-Path $PSScriptRoot $ToolBoxConfig.Variables.Main -ErrorAction Stop)
    . (Join-Path $ToolBoxConfig.Scripts "main_pretasks.ps1" -ErrorAction Stop)
    #endregion
    ################################################################################################

    ################################################################################################
    #region Load tool config and script based on selection
    ################################################################################################
    $Global:ToolCurrent = $AvailableTools | where{$_.Name -eq $Tool}
    $ChoiceContinue = Assert-ToolPrompt `
        -Title $ToolCurrent.Title `
        -Description $ToolCurrent.Description `
        -NonInteractive $NonInteractive
    if($NonInteractive){ 
        Write-Host "$($Strings.NonInteractiveTool -f $Tool)" -ForegroundColor Yellow 
        Test-DefinedRequiredVariables $ToolCurrent.RequiredVars # test if the required variables have values
    }
    if($ChoiceContinue){ . (Join-Path $ToolBoxConfig.Tools "$($ToolCurrent.Script)" -ErrorAction Stop) }
    #endregion
    ################################################################################################
    
}
catch {
    if(-not $ToolBoxConfig.Debug){ 
        Write-Host  "$($Exceptions.General -f $($ToolBoxConfig.LogFiles.Main))" -ForegroundColor Red
    } else {
        $LoggerMain.Exception($_)
    }

    if($ToolBoxConfig.DesktopMode -and (Get-Command 'Read-PromptYesNo' -ErrorAction SilentlyContinue)){
        $ChoiceContext = Read-HostChoice `
            -Message "Open toolkit log?" `
            -HelpText "Open log","Exit script" `
            -Default 1
        if($PromptOpenLog){ . (Join-Path $ToolBoxConfig.LogDirectory $ToolBoxConfig.LogFiles.Main) }
    }
}
#endregion
################################################################################################