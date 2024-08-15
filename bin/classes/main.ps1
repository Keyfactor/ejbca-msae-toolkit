class WriteLog {
    [String]$LogDirectory
    [String]$LogFile
    [String]$LogLevel = "INFO"
    [String]$LogLogger
    [String]$Message
    [String]$FontColor
    [String]$LogPath
    [String]$DefaultColor = "Gray"
    [Object]$ConsoleColors = @{
        Warning = "Yellow"
    }
    [Boolean]$OutputConsole = $false
    
    # Empty constructor
    WriteLog(){}
    WriteLog([String]$LogDir, [String]$LogFile, [String]$LogLogger, [String]$LogLevel){
        $this.LogFile = $LogFile
        $this.LogDirectory = $LogDir
        $this.LogLogger = $LogLogger
        $this.LogLevel = $LogLevel
        $this.LogPath = "${LogDir}\${LogFile}"
    }
    WriteLog([String]$LogDir, [String]$LogFile, [String]$LogLogger, [String]$LogLevel, [String]$Console){
        $this.LogFile = $LogFile
        $this.LogDirectory = $LogDir
        $this.LogLogger = $LogLogger
        $this.LogLevel = $LogLevel
        $this.OutputConsole = $Console
        $this.LogPath = "${LogDir}\${LogFile}"
    }

    # write last message to console
    Console(){
        Write-Host $($this.Message) -ForegroundColor $this.DefaultColor
        $this.Message = $null
    }
    Console([String]$Color){
        Write-Host $($this.Message) -ForegroundColor $Color
        $this.Message = $null
    }
    Info([String[]]$Messages){
        $this.WriteToLog($Messages,"INFO",$this.DefaultColor,$false)
    }
    Info([String[]]$Messages, [Boolean]$Console){
        #$Console = $Console
        $this.WriteToLog($Messages,"INFO",$this.DefaultColor,$Console)
    }
    Warn(){
        Write-Host $($this.Message) -ForegroundColor "Yellow"
        $this.Message = $null
    }
    Warn([String[]]$Messages){
        $this.WriteToLog($Messages,"WARN","Yellow",$false)
    }
    Warn([String[]]$Messages, [Boolean]$Console){
        #$Console = $Console
        $this.WriteToLog($Messages,"WARN","Yellow",$Console)
    }
    Debug([String[]]$Messages){
        if($this.LogLevel -eq "DEBUG"){
            $this.WriteToLog($Messages,"DEBUG",$this.DefaultColor,$false)
        }
    }
    Error([String[]]$Messages){
        $this.WriteToLog($Messages,"ERROR",$this.DefaultColor,$false)
    }
    Error([String[]]$Messages, [Boolean]$Console){
        #$Console = $Console
        $this.WriteToLog($Messages,"ERROR","Red",$Console)
    }
    Exception([object]$Exception){
        $Messages = (
            "Exception caught $($Exception.ScriptStackTrace)",
            $($Exception[0].Exception)
        )
        $this.WriteToLog($Messages,"ERROR","Red",$True)
    }
    Failed([String[]]$Messages){
        $this.WriteToLog($Messages,"INFO","Red",$True)
    }
    Success(){
        Write-Host $($this.Message) -ForegroundColor "Green"
        $this.Message = $null
    }
    Success([String[]]$Messages){
        $this.WriteToLog($Messages,"INFO","Green",$True)
    }
    Validate([String]$Result, [String]$Status){
        $Color = $this.Color
        switch($Status){
            'Passed'    { $Color = "Green" }
            'Failed'    { $Color = 'Red' }
            'Skipped'   { $Color = 'DarkGray' }
            'Warning'   { $Color = 'Yellow' }
            'Not Tested'{ $Color = 'Yellow' }
            default { throw [System.Exception] "Invalid status. It must be passed, failed, or skipped."}
        }
        $this.WriteToLog("[$Status] $Result","VALIDATION",$Color,$this.OutputConsole)
    }
    hidden WriteToLog (
        [String[]]$Messages,
        [String]$LogLevel,
        [String]$Color,
        [Boolean]$OutputConsole
    ) {
        $Path = $this.LogPath
        $Logger = $this.Logger

        # Filter invoking function object for entries with command name and select first entry
        # Assumption is the third entry with a command value is the invoking function name
        # Update logger name to use new command name or use original if command 
        $Command = ((Get-PSCallStack)[2].Command).Replace("-","")
        if($Command){ # update logger to use the command name
            $Logger = "$($this.LogLogger).$($Command)"
        } else { # update logger to use the original logger
            $Logger = $this.LogLogger
        }
        foreach($Message in $Messages){
            $TimeStamp = (Get-Date).toString("yyyyMMdd HH:mm:ss")
            $LogMessage = "$TimeStamp $LogLevel [$Logger] $Message"
            $LogMessage | Out-File -FilePath $Path -Append -Encoding utf8

            if($OutputConsole){ Write-Host $Message -ForegroundColor $Color }
        }
        $this.Message = $Message
    }
}