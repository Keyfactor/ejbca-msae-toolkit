# Tool pre-tasks on load of new session
try {
    $LoggerMain.Debug("Executing pre-tasks.")

    # Import configuration file
    $LoggerMain.Info("Importing configuration values from $($ToolBoxConfig.ConfigurationFile)...")
    foreach($Configuration in $(Get-Content $ToolBoxConfig.ConfigurationFile)){
        if($Configuration -match "(=)" -and $Configuration -notlike "#*"){
            $Variable = $Configuration.Split("=")[0].Trim() # Variable name is before '='
            # Variable value is after '='. Strip quotes to consider empty if nothing remains after quotes removed
            $Value = $Configuration.split("=",2)[1].Replace('"',"").Replace("'","").Trim() 

            if($Value.Length){
                Set-Variable -Name $Variable -Value $Value -Scope Global # Set all imported variables as Gloabl
                $LoggerMain.Info("Successfully imported $($Configuration)")
            }
            
        }
    }

    # Update logger level based on configuration file
    if($LogLevel -eq "DEBUG"){
        $LoggerMain.Info("Setting logging level to DEBUG...")
        $LoggerMain.LogLevel = "DEBUG"
        $ToolBoxConfig.LogLevel = "DEBUG"
    }

    $LoggerMain.Debug("Importing required Builtin Powershell modules...")
    foreach($Module in $ToolBoxConfig.Modules){
        $ImportResult = Import-Module -Name $Module -ErrorAction Stop -PassThru
        $LoggerMain.Debug("Successfully imported module $($ImportResult.Name)")
    }

    # Import Functions
    $LoggerMain.Debug("Importing functions...")
    Get-ChildItem $ToolBoxConfig.Functions -Filter *.ps1 | `
        ForEach-Object {. (Join-Path $ToolBoxConfig.Functions $_.Name)} | Out-Null        

    # Update configs and write new entries to the DEBUG log
    $DomainProperties = Get-ADDomain
    $ToolBoxConfig.DomainFqdn = $DomainProperties.Forest
    $ToolBoxConfig.DomainDn = $DomainProperties.DistinguishedName

    $LoggerMain.Debug(("Global variables: `n$($ToolBoxConfig|ConvertTo-JSON)"))
}
catch {
    $LoggerMain.Exception($_)
    $LoggerMain.Info("Exiting toolkit due to failed pre-task action.")
    exit
}