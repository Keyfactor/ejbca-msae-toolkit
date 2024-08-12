# Create Loggers
$LoggerMain = [WriteLog]::New($ToolBoxConfig.LogDirectory, 
                              $ToolBoxConfig.LogFiles.Main, 
                              $ToolBoxConfig.LogLoggers.Main, 
                              $ToolBoxConfig.LogLevel
                              )
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory,
                                   $ToolBoxConfig.LogFiles.Main,
                                   $ToolBoxConfig.LogLoggers.Functions,
                                   $ToolBoxConfig.LogLevel
                                  )
$LoggerValidation = [WriteLog]::New($ToolBoxConfig.LogDirectory,
                                    $ToolBoxConfig.LogFiles.Validation,
                                    $ToolBoxConfig.LogLoggers.Validation,
                                    $ToolBoxConfig.LogLevel,
                                    $True
                                  )

if($ToolBoxConfig.Debug){
    $DebugPreference = "SilentlyContinue"

    # Remove previous log file and create new
    try {
        Get-ChildItem $ToolBoxConfig.LogDirectory | ForEach-Object{ Remove-Item "$($ToolBoxConfig.LogDirectory)\$_" -ErrorAction Stop | Out-Null }
    } catch [ItemNotFoundException]{
        continue
    }

    $LoggerMain.Debug((
        "The toolkit was launched with parameters: $($($MyInvocation.BoundParameters | Format-List | Out-String).Trim())",
        "Toolkit configuration variables: `n$($($ToolBoxConfig | Format-List| Out-String).Trim())",
        "Executing pre-tasks."
    ))
}
else {
    $LoggerMain.Info(("","-----------------New Script Run $((Get-Date).ToString())------------------","")); Clear-Host
}  

# Import configuration file
$LoggerMain.Info("Importing configuration values from $($ToolBoxConfig.ConfigurationFile).")
foreach($Configuration in $(Get-Content $ToolBoxConfig.ConfigurationFile -ErrorAction Stop)){

    # build namespace using config section name if name is Main
    if($Configuration -match "(\[(.*?)\])" -and $Configuration -notmatch "(Main)" -and $Configuration -notlike "#*"){
        $Namespace = $Configuration.Split("[")[1].Split("]")[0].Replace(" ","")
    }

    # get values from each section
    if($Configuration -match "(=)" -and $Configuration -notlike "#*"){
        $ConfigVariable = $Configuration.Split("=")[0].Trim() # Variable name is before '='
        # Variable value is after '='. Strip quotes to consider empty if nothing remains after quotes removed
        $ConfigValue = $Configuration.split("=",2)[1].Replace('"',"").Replace("'","").Trim() 

        # Add variable to file if it has a length and the variable is defined as a parameter for the script
        if($ConfigValue.Length -and ($ConfigVariable -in $AvailableConfigValues.Name)){
            $Variable = $Namespace + $ConfigVariable # create variable from adding namespace to front of variable
            Set-Variable -Name $Variable -Value $ConfigValue -Scope Script # Set all imported variables as Gloabl
            $LoggerMain.Info("Imported '$($ConfigVariable)' from configuration file as '$("$Variable = $ConfigValue")'")
        }
    }
}


# Import Functions
$LoggerMain.Debug("Importing functions...")

Get-ChildItem $ToolBoxConfig.Functions -Filter *.ps1 | `
    ForEach-Object {. (Join-Path $ToolBoxConfig.Functions $_.Name)} | Out-Null

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