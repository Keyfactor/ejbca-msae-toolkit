
<#
.Synopsis
Microsoft Authoenrollment Configuration Toolbox

.Description
This tool is designed to validate an already configured MSAE integration with options to interactively resolve identified issues.
A support bundle can be generated if the user does not wish to use the interactive session.
#>

#[CmdletBinding(DefaultParameterSetName = 'tool')]
Param(
    [Parameter(Mandatory=$False, Position=0)][String]$Tool,
    
    # Confirgurable parameters
    [Parameter(Mandatory=$false, HelpMessage="Configurable. EJBCA Policy Server hostname containing the MSAE alias. Ex: policy-server.keyfactor.com ")]
    [String]$PolicyServer,
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Name of configured msae alias in EJBCA.")]
    [String]$PolicyServerAlias,
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Active Directory service account.")]
    [String]$ServiceAccount,
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Active Directory service account password.")]
    [String]$ServiceAccountPassword,
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Common Name, or Distinguished Name, of service account organization unit in Active Directory.")]
    [String]$ServiceAccountOrgUnit,
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Days the service account will be valid for.")]
    [Int]$ServiceAccountExpiration = 365,

    # Kerberos
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Keytab file path.")]
    [String]$Keytab,
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Krb5.conf file path.")]
    [String]$Krb5,

    # Certificate templates
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Computer context autoenrollment template name.")]
    [String]$TemplateComputer,
    [Parameter(Mandatory=$false, HelpMessage="Configurable. Computer context autoenrollment security group.")]
    [String]$TemplateComputerGroup,
    [Parameter(Mandatory=$false, HelpMessage="Autoenrollment context")]
    [ValidateSet("Machine","User")]
    [String]$EnrollmentContext="Machine",

    # Options
    [Parameter(Mandatory=$false, HelpMessage="Suppress prompts. Does not include prompts for undefined variables.")]
    [Switch]$NonInteractive,
    [Parameter(Mandatory=$false, HelpMessage="Configuration file containing predefined parameters vand values. Default: main.conf")]
    [ValidateScript({Test-Path $_})]
    [String]$Configfile = "$PSScriptRoot\main.conf",
    [Parameter(Mandatory=$false, HelpMessage="Print tool help")]
    [Switch]$Help
)



# Create custom object containing the parameter name and help messages for printing the help menu
# Omit parameter that have 'aliases' and the 'tool' parameter. Intended to keep function from inheriting default powershell parameters
$ParameterList = (Get-Command -Name $PSCmdlet.MyInvocation.InvocationName).Parameters
$OptionsParameters = @(foreach ($Parameter in $ParameterList.Values) {
    if(-not $Parameter.Aliases.Count -and $Parameter.Name -ne "Tool"){
        [PSCustomObject]@{Name = $Parameter.Name; Option = "-$($Parameter.Name)"; Description = $Parameter.Attributes.HelpMessage}
    }
})

# Toolbox Configuration
$Global:ToolBoxConfig = [PSCustomObject]@{
    ScriptHome = $PSScriptRoot
    ScriptExit = $false
    Debug = %{if($MyInvocation.BoundParameters.Keys -contains "Debug"){$true}else{$false}}
    NonInteractive = $false
    DesktopMode = $false
    OS = $env:OS 
    Classes = "bin\classes\main.ps1"
    Domain = (Get-ADDomain -Current LocalComputer).DNSRoot
    ParentDomain = (Get-ADDomain -Current LocalComputer).Forest
    Variables = "bin\variables.ps1"
    ConfigurationFile = $Configfile
    Files = $Home
    Functions = "$PSScriptRoot\bin\functions"
    Scripts = "$PSScriptRoot\bin\scripts"
    Tools = "$PSScriptRoot\bin\scripts"
    LogLevel = %{if($MyInvocation.BoundParameters.Keys -contains "Debug"){"DEBUG"}else{"INFO"}}
    LogDirectory = $Home
    LogFiles = @{
        Main = "main.log"
        Config = "config.log"
    }
    Modules = @(
        "DnsClient",
        "ActiveDirectory"
    )
    KeytabEncryptionTypes = "AES256"
}

try {

    # Import source scripts
    . (Join-Path $PSScriptRoot $ToolBoxConfig.Classes -ErrorAction Stop)
    . (Join-Path $PSScriptRoot $ToolBoxConfig.Variables -ErrorAction Stop)

    # Exit script if tool name provided but a valid option was not provided
    if($Tool.Length -and $Tool -notin $AvailableTools.Name){
        Write-Host "Invalid tool parameter provided. The available options are: $($AvailableTools.Name -join ', ')" -ForegroundColor Red
        exit 

    } elseif($Tool -and $Help){ # Print help for tool
        $AvailableTools | where{$_.Name -eq $Tool} | ForEach-Object{
            Write-Host "[$($_.Title)]`n" -ForegroundColor Yellow -NoNewLine

            Write-Host "`n" -NoNewLine; Write-Host " - $($_.Description)" -ForegroundColor Yellow
            $_.DescriptionAdditional | foreach {Write-Host " - $_" -ForegroundColor Yellow}

            Write-Host "`n" -NoNewLine; Write-Host "Prerequisites" -ForegroundColor Yellow
            $_.Prerequisites | foreach {Write-Host " - $_" -ForegroundColor Yellow}
           
            Write-Host "`n" -NoNewLine; Write-Host "Variables" -ForegroundColor Yellow
            $_.RequiredVars | foreach {Write-Host " - $_" -ForegroundColor Yellow}; Write-Host "`n"
            exit
        }

    # Print Tool Menu and exit script if no tool was provided
    } elseif(-not $Tool) {
        Write-Host "Welcome to the Keyfactor Delivery MSAE PowerShell Toolbox! Select one of the tools below to get started. To get more information about each tool, select the README.`n"
        Write-Host "Tools"; Write-Host $($AvailableTools | Format-Table @{e=' ';w=2}, @{e='Name';w=30},Description -HideTableHeaders | Out-String) -NoNewLine
        Write-Host "Options"; Write-Host $($OptionsParameters | Format-Table @{e=' ';w=2}, @{e='Option';w=30},Description -HideTableHeaders | Out-String) -NoNewLine
        exit
    }

    # Execute pretasks
    . (Join-Path $ToolBoxConfig.Scripts "main_pretasks.ps1" -ErrorAction Stop)

    # Load tool config and script based on selection
    $Global:ToolCurrent = $AvailableTools | where{$_.Name -eq $Tool}
    $ChoiceContinue = Assert-ToolPrompt `
        -Title $ToolCurrent.Title `
        -Description $ToolCurrent.Description `
        -NonInteractive $NonInteractive
    if($ChoiceContinue){. (Join-Path $ToolBoxConfig.Tools "$($ToolCurrent.Script)" -ErrorAction Stop)}
    
}
catch {
    Write-Host $_ -ForegroundColor Red; $LoggerMain.Exception($_)
    
    if($ToolBoxConfig.DesktopMode -and (Get-Command 'Read-PromptYesNo' -ErrorAction SilentlyContinue)){
        $ChoiceContext = Read-HostChoice `
            -Message "Open toolkit log?" `
            -HelpText "Open log","Exit script" `
            -Default 1
        if($PromptOpenLog){
            . (Join-Path $ToolBoxConfig.LogDirectory $ToolBoxConfig.LogFiles.Main)
        }
    }
}

