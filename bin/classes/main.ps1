class WriteLog {
    [String]$LogDirectory
    [String]$LogLevel = "INFO"
    [String]$LogLogger
    [String]$LogFile
    [String]$LogDir
    [String]$LogPath
    [String]$Message
    [String]$FontColor
    [String]$DefaultColor = "Gray"
    [Object]$ConsoleColors = @{
        Warning = "Yellow"
    }
    [Boolean]$OutputConsole = $false
    
    # Two different constructors
    # One without a console being passed. Another with the console being passed
    WriteLog([String]$LogDir, [String]$LogFile, [String]$LogLogger, [String]$LogLevel){
        $this.LogFile = $LogFile
        $this.LogDirectory = $LogDir
        $this.LogLogger = $LogLogger
        $this.LogLevel = $LogLevel

        # Create log directory
        $this.CreateLogDir()

        # Update log file name to main-debug.log and delete existing
        if($this.LogLevel -eq "DEBUG"){
            $this.LogFile = "main-debug.log"
            Remove-Item "$($this.LogDirectory)\$($this.LogFile)" -ErrorAction SilentlyContinue | Out-Null
        }       
        $this.LogPath = "$($this.LogDirectory)\$($this.LogFile)"
    }

    WriteLog([String]$LogDir, [String]$LogFile, [String]$LogLogger, [String]$LogLevel, [Boolean]$Console){
        $this.LogFile = $LogFile
        $this.LogDirectory = $LogDir
        $this.LogLogger = $LogLogger
        $this.LogLevel = $LogLevel
        $this.OutputConsole = $Console
        
        # Create log directory
        $this.CreateLogDir()

        # Update log file name to main-debug.log and delete existing
        if($this.LogLevel -eq "DEBUG"){
            $this.LogFile = "main-debug.log"
            Remove-Item "$($this.LogDirectory)\$($this.LogFile)" -ErrorAction SilentlyContinue | Out-Null

        }
        $this.LogPath = "$($this.LogDirectory)\$($this.LogFile)"
    }

    # CONSOLE
    # Print last log message to console with default color
    Console(){
        Write-Host $($this.Message) -ForegroundColor $this.DefaultColor
        $this.Message = $null
    }
    # Print last log message to console using the color passed during invocation
    Console([String]$Color){
        Write-Host $($this.Message) -ForegroundColor $Color
        $this.Message = $null
    }

    # INFO
    # Print last log message to console
    Info(){
        Write-Host $($this.Message) -ForegroundColor "Gray"
        $this.Message = $null
    }
    # Log messagee
    Info([String[]]$Messages){
        $this.WriteToLog($Messages,"INFO",$this.DefaultColor,$false)
    }
    # Log message and print to console if passed boolean true
    Info([String[]]$Messages, [Boolean]$Console){
        $this.WriteToLog($Messages,"INFO",$this.DefaultColor,$Console)
    }

    # WARN
    # Print last log message to console
    Warn(){
        Write-Host $($this.Message) -ForegroundColor "Yellow"
        $this.Message = $null
    }
    # Log messagee
    Warn([String[]]$Messages){
        $this.WriteToLog($Messages,"WARN","Yellow",$false)
    }
    # Log message and print to console if passed boolean true
    Warn([String[]]$Messages, [Boolean]$Console){
        $this.WriteToLog($Messages,"WARN","Yellow",$Console)
    }

    # ERROR
    # Print last log message to console
    Error(){
        Write-Host $($this.Message) -ForegroundColor "Red"
        $this.Message = $null
    }
    # Log messagee
    Error([String[]]$Messages){
        $this.WriteToLog($Messages,"ERROR",$this.DefaultColor,$false)
    }
    # Log message, print to console, and exit toolkit because 'noninteractive' mode is active
    Error([String]$Message, [Boolean]$NonInteractive){
        # add period to end of string
        # required because the same message used with interactive does not have a period.
        $AppendedMessage = "$($Message.ToString())." 
        if($NonInteractive){ 
            $this.WriteToLog($AppendedMessage,"ERROR","Red",$true)
            exit 
        } else {
            $this.WriteToLog($AppendedMessage,"ERROR","Red",$false)
        }
    }

    # DEBUG
    # Only write to log if log level when class instantiated was DEBUG
    Debug([String[]]$Messages){
        if($this.LogLevel -eq "DEBUG"){
            $this.WriteToLog($Messages,"DEBUG",$this.DefaultColor,$false)
        }
    }

    # EXCEPTION
    # Used to manipulate expeptions thrown by PowerShell
    Exception([object]$Exception){
        if($this.LogLevel -eq 'DEBUG'){ $Console = $true }
        else { $Console = $false }
        $Messages = (
            "Exception caught $($Exception.ScriptStackTrace)",
            $($Exception[0].Exception)
        )
        $this.WriteToLog($Messages,"ERROR","Red",$Console)
    }

    # Validation Loggers
    # FAILED
    Failed(){
        Write-Host $($this.Message) -ForegroundColor "Red"
        $this.Message = $null
    }
    Failed([String[]]$Messages){
        $this.WriteToLog($Messages,"INFO","Red",$True)
    }

    # SUCCESS
    # Print last log message to console
    Success(){
        Write-Host $($this.Message) -ForegroundColor "Green"
        $this.Message = $null
    }
    # Log message and print to console
    Success([String[]]$Messages){
        $this.WriteToLog($Messages,"INFO","Green",$True)
    }
    # Log message and print to console
    Register([String[]]$Messages){
        $this.WriteToLog($Messages,"INFO",$this.DefaultColor,$True)
    }

    # VALIDATE
    # Log message and print to console.
    # validation performed on the provided status
    Validate([String]$Result, [String]$Status){
        $Color = $this.Color
        switch($Status){
            'Failed'    { $Color = 'Red' }
            'Passed'    { $Color = "Green" }
            'Skipped'   { $Color = 'DarkGray' }
            'Warning'   { $Color = 'Yellow' }
            'Not Tested'{ $Color = 'Yellow' }
            default { throw [System.Exception] "Invalid status. It must be passed, failed, or skipped."}
        }
        $this.WriteToLog("[$Status] $Result","VALIDATION",$Color,$this.OutputConsole)
    }

    # Create log directory
    hidden CreateLogDir() {
       if(-not (Test-Path $this.LogDirectory)){ New-Item $this.LogDirectory -ItemType Directory -ErrorAction SilentlyContinue | Out-Null }
    }

    # Write to log
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