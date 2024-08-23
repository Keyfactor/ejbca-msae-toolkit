################################################################################################
#region Create Loggers
################################################################################################
# Main
$LoggerMain = [WriteLog]::New(
    $ToolBoxConfig.LogDirectory, 
    $ToolBoxConfig.LogFiles.Main, 
    $ToolBoxConfig.LogLoggers.Main, 
    $ToolBoxConfig.LogLevel
)
# Functions
$LoggerFunctions = [WriteLog]::New(
    $ToolBoxConfig.LogDirectory,
    $ToolBoxConfig.LogFiles.Main,
    $ToolBoxConfig.LogLoggers.Functions,
    $ToolBoxConfig.LogLevel
)

# Validation logger with print to console enabled and log to different file
$LoggerValidation = [WriteLog]::New(
    $ToolBoxConfig.LogDirectory,
    $ToolBoxConfig.LogFiles.Validation,
    $ToolBoxConfig.LogLoggers.Validation,
    $ToolBoxConfig.LogLevel,
    $True
)
#endregion
################################################################################################

################################################################################################
#region Update start of log based on LogLevel
################################################################################################
# DEBUG
if($ToolBoxConfig.Debug){
    $DebugPreference = "SilentlyContinue"
    $LoggerMain.Debug((
        "The toolkit was launched with parameters: $($($MyInvocation.BoundParameters | Format-List | Out-String).Trim())",
        "Toolkit configuration variables: `n$($($ToolBoxConfig | Format-List| Out-String).Trim())",
        "Executing pre-tasks."
    ))
}

# INFO
else {
    $LoggerMain.Info(("","-----------------New Script Run $((Get-Date).ToString())------------------","")); Clear-Host
}
#endregion
################################################################################################

################################################################################################
#region Import configuration file
#        - Get values from each section
#        - Add variable to file if it has a length and the variable is defined as a parameter 
#          for the script.
#        - Set each as global variable
################################################################################################
$LoggerMain.Info("Importing configuration values from $($ToolBoxConfig.ConfigurationFile).")
foreach($Configuration in $(Get-Content $ToolBoxConfig.ConfigurationFile -ErrorAction Stop)){

    if($Configuration -match "(=)" -and $Configuration -notlike "#*"){
        $ConfigVariable = $Configuration.Split("=")[0].Trim() # Variable name is before '='
        $ConfigValue = $Configuration.split("=",2)[1].Replace('"',"").Replace("'","").Trim() # Variable value is after '='. Strip quotes to consider empty if nothing remains after quotes removed

        if($ConfigValue.Length -and ($ConfigVariable -in $AvailableConfigValues.Name)){
            Set-Variable -Name $ConfigVariable -Value $ConfigValue -Scope Script # Set all imported variables as Gloabl
            $LoggerMain.Info("Imported '$($ConfigVariable)' from configuration file as '$("$ConfigVariable = $ConfigValue")'")
        }
    }
}
#endregion
################################################################################################

################################################################################################
#region Update files directory
################################################################################################
if($FilesDirectory){
    $LoggerMain.Info("Changing files directory from '$($ToolBoxConfig.Files)' to '$FilesDirectory'")
    $ToolBoxConfig.Files = $FilesDirectory
}
#endregion
################################################################################################

################################################################################################
#region Import functions and modules
################################################################################################
# functions
$LoggerMain.Debug("Importing functions...")
Get-ChildItem $ToolBoxConfig.Functions -Filter *.ps1 | ForEach-Object {. (Join-Path $ToolBoxConfig.Functions $_.Name)} | Out-Null

# get os version
Set-OperatingSystem | Out-Null

# modules
if($IsWindows){
    $LoggerMain.Debug("Importing required Builtin Powershell modules.")
    foreach($Module in $ToolBoxConfig.Modules){
        $ImportResult = Import-Module -Name $Module -ErrorAction Stop -PassThru
        $LoggerMain.Debug("Successfully imported module $($ImportResult.Name)")
    }
} else {
    $LoggerMain.Debug("Skipping Builtin Powershell module import because the operating system is not Windows.")
}

#endregion
################################################################################################