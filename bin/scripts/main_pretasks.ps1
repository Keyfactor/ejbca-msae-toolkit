
# Create Loggers
$LoggerMain = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main, $ToolBoxConfig.LogLevel, "KF.Toolkit.Main")

$LoggerMain.Debug("Executing pre-tasks.")

# Import configuration file
$LoggerMain.Info("Importing configuration values from $($ToolBoxConfig.ConfigurationFile).")
foreach($Configuration in $(Get-Content $ToolBoxConfig.ConfigurationFile -ErrorAction Stop)){
    if($Configuration -match "(=)" -and $Configuration -notlike "#*"){
        $Variable = $Configuration.Split("=")[0].Trim() # Variable name is before '='
        # Variable value is after '='. Strip quotes to consider empty if nothing remains after quotes removed
        $Value = $Configuration.split("=",2)[1].Replace('"',"").Replace("'","").Trim() 

        # Add variable to file if it has a length and the variable is defined as a parameter for the script
        if($Value.Length -and ($Variable -in $OptionsParameters.Name)){
            Set-Variable -Name $Variable -Value $Value -Scope Script # Set all imported variables as Gloabl
            $LoggerMain.Info("Imported '$($Configuration)' from configuration file.")
        }
    }
}

# Import Functions
$LoggerMain.Debug("Importing functions...")
Get-ChildItem $ToolBoxConfig.Functions -Filter *.ps1 | `
    ForEach-Object {. (Join-Path $ToolBoxConfig.Functions $_.Name)} | Out-Null

# Create new log every time script runs
if($ToolBoxConfig.Debug){

    # Remove previous log file and create new
    Remove-Item "$($ToolBoxConfig.LogDirectory)\$($ToolBoxConfig.LogFiles.Main)" -ErrorAction SilentlyContinue | Out-Null 
    New-Item "$($ToolBoxConfig.LogDirectory)\$($ToolBoxConfig.LogFiles.Main)" -ErrorAction SilentlyContinue | Out-Null 

    $LoggerMain.Debug(("Toolkit configuration variables: $($ToolBoxConfig|Out-TableString)"))
    $LoggerMain.Debug("The toolkit was launched with parameters: `n$($($MyInvocation.BoundParameters | Format-Table | Out-String).Trim())")
}
else {
    Clear-Host
    $LoggerMain.Info("`n`n------------------NEW SCRIPT RUN------------------")
}   

# Set Interactive Mode
if(Assert-DesktopMode){
    $ToolBoxConfig.DesktopMode = $true
    $LoggerMain.Debug("The toolkit is running in Desktop Mode. Certain features will be available.")
} else {
    $LoggerMain.Debug("The toolkit is not running in Desktop Mode. Certain features will not be available.")
}

# Import required Modules
$LoggerMain.Debug("Importing required Builtin Powershell modules.")
foreach($Module in $ToolBoxConfig.Modules){
    $ImportResult = Import-Module -Name $Module -ErrorAction Stop -PassThru
    $LoggerMain.Debug("Successfully imported module $($ImportResult.Name)")
}