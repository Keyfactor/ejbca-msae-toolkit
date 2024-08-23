<# Helper functions designed to be included in other functions

- These functions should be very simple
- Logging should not be performed directly in this function
#>

function Assert-DesktopMode {
    param (
        [Parameter(Mandatory=$false)][Switch]$LoadAssembly
    )

    $NonInteractive = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonI*' }
    $Windows = ([Environment]::OSVersion.Platform -like "Win*")

    if ([Environment]::UserInteractive -and $Windows -and -not $NonInteractive) {
        $LoggerFunctions.Info("Powershell is running in Interactive mode. Message boxes are enabled.")

        if($LoadAssembly){
            [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 
            $LoggerFunctions.Info("Loaded System.Reflection.Assembly: System.Windows.Forms")
        }
        return $true
    }
    $LoggerFunctions.Info("Powershell is running in non-Interactive mode. Message boxes are disabled.")
    return $false
} 

function Assert-ToolPrompt {
    Param(
        [Parameter(Mandatory=$true)][String]$Title,
        [Parameter(Mandatory=$true)][String]$Description,
        [Parameter(Mandatory=$false)][Bool]$NonInteractive = $false
    )

    if($ConfigFile -and $NonInteractive -eq $false){
        $ConfirmationMessage = "$($Description)`n`nWould you like to continue using required values from the provided configuration file and interactive prompts? "
        $HelpText = "Prompts will appear for required variables only when the variable isn't already defined in the provided configuraiton file or parameter when the toolkit was launch. Interactive input prompts will appear before certain actions are performed in the tool."
    } else {
        $ConfirmationMessage = "$($Description)`n`nWould you like to continue using prompts for required values not included as parameters?"
        $HelpText = "Interactive input prompts will appear for all required variables that were not included as parameters when invoking the toolkit."
    }

    if($NonInteractive){
        return $True
    } else {
        $Confirmation = Read-HostChoice `
            -Title $Title `
            -Message "$ConfirmationMessage. Type 'exit' at any input prompt to terminate the tool." `
            -Choices "Yes","No" `
            -HelpText "$($HelpText)", "Exit toolkit" `
            -Default 0 `
            -ReturnBool
        if(-not $Confirmation){
            $LoggerFunctions.Error("Tool exited.")
            exit
        }
        return $Confirmation
    }
}

function Confirm-RequiredParameters {
    param(
        [Parameter(Mandatory)][String[]]$RequiredParameters,
        [Parameter(Mandatory)][Hashtable]$BoundParameters
    )

    if("NonInteractive" -in $BoundParameters.Keys){
        foreach($Param in $RequiredParameters){
            if($Param -notin $BoundParameters.Keys){
                Write-Error "The $Param parameter is required for the 'cep-config' tool when using Non-Interactive mode."
            }
        }
    }
}

function Convert-HostPromptBool {
    <#
    .Synopsis
        Convert message box response to boolean
    .Description
        Message boxes return integer values. This function converts certain respones, like Yes/No, to True/False. 
        This is helpful when evaluting responses in condition statements.

        Refer to the following for the available DialogResult Enums:
        https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.dialogresult?view=windowsdesktop-8.0
    .Parameter Value
        Integer to convert with Switch condition
    .Example
        $Answer | Convert-PromptResponseBool  
    #>
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline)][int]$Value
    )
    process {
        switch ([int]$Value) {
            1 {$true}
            2 {$false}
            6 {$true}
            7 {$false}
        }
    }
} 

function Convert-Slugify{
    <#
    .Synopsis
        Convert string to slug
    .Description
        Change all characters to lowercase and replace whitespaces with underscores
    .Parameter String
        String to convert
    .Example
        "Slugify Conversion" | Convert-KFSlugify
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline)][String]$String
    )
    process {
        $String = $String.ToLower()
        $String.Replace(' ','_')
    }
}

function Get-WinErrorHex {
    param(
        [Parameter(Mandatory, ValueFromPipeline)][String]$Message
    )
    process{

        $ErrorHexSearch = $Message.Substring($Message.IndexOf("0x"))
        $ErrorMessageSearch = $Message.Substring(0,$Message.IndexOf("0x"))
        $ErrorRecord = [PSCustomObject]@{
            ErrorCode = $ErrorHexSearch.Split()[0]
            ErrorMessage = $ErrorMessageSearch.Substring($Message.LastIndexOf(":")+1).Trim()
        }

        return $ErrorRecord
    }
}

function Convert-WindowsError {
    param(
        [Parameter(Mandatory, ValueFromPipeline)][String]$Code
    )
    process{

        $ErrorHexSearch = $Message.Substring($Message.IndexOf("0x"))
        $ErrorMessageSearch = $Message.Substring(0,$Message.IndexOf("0x"))
        $ErrorRecord = [PSCustomObject]@{
            ErrorCode = $ErrorHexSearch.Split()[0]
            ErrorMessage = $ErrorMessageSearch.Substring($Message.LastIndexOf(":")+1).Trim()
        }

        return $ErrorRecord
    }
}

function Out-TableString {
    <#
    .Synopsis
        Creates string output of formatted table
    .Description
        Formats values as table and converts to string value. Intended for log and console output.
    .Parameter HideTableHeaders
        Dont diplay column headers
    .Example
        $Table | Out-TableString
    #>
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline)][Object]$Table,
        [Parameter(Mandatory=$false)][Boolean]$HideTableHeaders=$false
    )

    process {
        if($Table){
                if($HideTableHeaders){
                "`n$(($Table|Format-Table -HideTableHeaders -AutoSize|Out-String).Trim())"
            } else {
                "`n$(($Table|Format-Table -AutoSize|Out-String).Trim())"
            }
        } else {
            $LoggerFunctions.Info("Table is empty.")
        }
    }
}

function Out-BoundParameters {
    <#
    .Synopsis
        Creates string output of formatted table
    .Description
        Formats values as table and converts to string value. Intended for log and console output.
    .Parameter HideTableHeaders
        Dont diplay column headers
    .Example
        $Table | Out-TableString
    #>
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline)][Object]$Function
    )
    process {
        "$($_.InvocationName) bound parameters: `n$(($_.BoundParameters|Format-Table Key,@{e={":$($_.Value)"}} -HideTableHeaders|Out-String).Trim())"
    }
}

function Out-ListString {
    <#
    .Synopsis
        Creates string output of formatted list
    .Description
        Formats values as list and converts to string value. Intended for log and console output.
    .Example
        $List | Out-ListString
    #>
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline)][Object]$List
    )
    process {
        if($List) {
                "`n$(($List | Format-List| Out-String).Trim())"
        } else {
            $LoggerFunctions.Info("List is empty.")
        }
    }
}

Function Read-HostChoice {
	<#
        .Synopsis
            Prompt the user for a Yes No choice.
        .Description
            Prompt the user for a Yes No choice and returns 0 for no and 1 for yes.
        .Parameter Title
            Title for the prompt
        .Parameter Message
            Message for the prompt
        .Parameter DefaultOption
            Specifies the default option if nothing is selected
        .Parameter Choices
            Specifies the choices to add to the selection
        .Parameter HelpText
            Specifies the help text for each choice. Array length must match the length of Choices
        .Example
            PS> $choice = Read-YesNoChoice
            
            Please Choose
            Yes or No?
            [N] No  [Y] Yes  [?] Help (default is "N"): y
            PS> $choice
            1
        .Example
            PS> $choice = Read-YesNoChoice -Title Please Choose" -Message "Would you like to continue or exit?" `
                -Choices "Continue","Quit" -HelpText "Continue with function","Exit function" -DefaultOption 1
            
            Please Choose
            Would you like to continue or exit?
            [C] Continue  [E] Exit  [?] Help (default is "C"): ?
            C - Return to main menu
            E - Exit script
            [C] Continue  [E] Exit  [?] Help (default is "C"):
            PS> $choice
            0
    #>
	Param (
        [Parameter(Mandatory=$false)][String]$Message="",
        [Parameter(Mandatory=$false)][String]$Title="",
		[Parameter(Mandatory=$false)][Int]$DefaultOption = 0,
        [Parameter(Mandatory=$false)][String[]]$Choices = ("Yes","No","Quit"),
        [Parameter(Mandatory=$false)][String[]]$HelpText,
        [Parameter(Mandatory=$false)][Switch]$ReturnBool,
        [Parameter(Mandatory=$false)][Switch]$ReturnInt
    )

    #Write-Host $($MyInvocation.BoundParameters)

    # Throw error if help text is provided but is empty
    if($HelpText -and ($Choices.Length -ne $HelpText.Length)){
        Write-Error "The Choices and HelpText arrays are not the same length." -Category InvalidArgument -ErrorAction Stop
        #throw
    }

    # Create array and add each choice and help text to a new choice desctiption object
    $ChoicesArray = @()
    for($I=0;$I -lt $Choices.count;$I++){

        # Condition used to set help text in single variable if it was provided
        if($HelpText){ 
            $ChoiceHelpText = $HelpText[$I] 
        } else { 
            $ChoiceHelpText = $Choices[$I]
        }

        # Add choice and help text 
        $ChoicesArray += New-Object System.Management.Automation.Host.ChoiceDescription "&$($Choices[$I])","$ChoiceHelpText"
    }

    # Create propt for choice option and return
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($ChoicesArray)
    $Selection = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultOption) #; Write-Host "`n"

    # Return bool if switch provided and choices length is exactly 2
    if(($ReturnBool -and $Choices.Length -eq 2) -or ("Choices" -notin $MyInvocation.BoundParameters.Keys)){
        Switch ($Selection){
            0 { return $True }
            1 { return $False }
            2 { exit }
        }
    } elseif($ReturnInt){
        return $Selection
    }
    # return text instead of integer
    return $Choices[$Selection]
}

function Read-HostPrompt {
    param(
        [Parameter(Mandatory=$true)][String]$Message,
        [Parameter(Mandatory=$false)][String]$Color = "Gray",
        [Parameter(Mandatory=$false)][Switch]$NoInput,
        [Parameter(Mandatory=$false)][Switch]$Secure
    )
    $OriginalMessage = $Message
    while($true) {
        switch ($NoInput){
            $True {
                Write-Host $Message -ForegroundColor $Color 
                return $Host.UI.ReadLine()
            }
            $False { 
                switch ($Secure){
                    $True {
                        # get masked input and store plain text in secure string if 'exit' was provided
                        $Response = $(Write-Host "$($Message): " -ForegroundColor $Color -NoNewLine; Read-Host -AsSecureString);
                        $Response = $(if(([System.Net.NetworkCredential]::new("", $Response).Password).ToLower() -eq "exit"){"exit"} else {$Response}) 
                    }
                    $False {
                        $Response = $(Write-Host "$($Message): " -ForegroundColor $Color -NoNewLine; Read-Host)
                    } 
                }
                if($Response -eq "exit"){ # exit script
                    exit 
                } elseif($Response.Length -gt 1){ # need to check length instead of $null because empty secure string do not return $null
                    return $Response 
                } else { # update message and color if no input provided
                    $Message = "No input was provided. $OriginalMessage"; $Color = "Yellow"
                }
            }
        }
    }
}

function Read-HostPromptMultiSelection {
    param(
        [Parameter(Mandatory=$false)][string]$Message="",
        [Parameter(Mandatory=$false)][string]$Color = "Gray",
        [Parameter(Mandatory=$false)][switch]$ReturnInteger,
        [Parameter()][string[]]$Selections
    )

    $SelectionArray = @(
    $Selections | ForEach-Object {$Index = 1}{
        [pscustomobject]@{N = $Index; S = "-"; Description = "$_"}; $Index++
    })
    Write-Host "`n$Message" -ForegroundColor $Color -NoNewline 
    Write-Host "`n$($($SelectionArray | Format-Table -HideTableHeaders -AutoSize | Out-String).Trim())" -ForegroundColor $Color #-NoNewline

    while ($true) {
        Write-Host "`nSelection: " -NoNewline
        $Selection = $Host.UI.ReadLine()
        if($Selection -in 1..$SelectionArray.Count){
            if($ReturnInteger){
                return [int]$Selection
            } else {
                return $SelectionArray.where({$_.N -match $Selection}).Description
            }
        }
        elseif($Selection -eq "quit"){
            exit
        }
        else {
            Write-Host "`nInvalid selection. Enter a number between 1-$($SelectionArray.Count)." -ForegroundColor Yellow
        }
    }
}

function Set-OperatingSystem {
    <#
    .Synopsis
        Sets operating system boolean values for PS Desktop
    .Description
        Switches the [Environment]::OSVersion.Platform variable and sets variables based on the match string value.
        These variables match the variables that are native in PS Core.
    .Example
        Set-OperationSystem
    #>
    process {
        switch ([Environment]::OSVersion.Platform) {
            "Win32NT"  { 
                Set-Variable -Scope Global -Name IsWindows -Value $True -Force 
                $LoggerFunctions.Info("Operating system is Windows.")
            }
            "Linux"    { 
                Set-Variable -Scope Global -Name IsLinux -Value $True -Force
                $LoggerFunctions.Info("Operating system is Linux-based.")
            }
            "Unix"     {
                Set-Variable -Scope Global -Name IsMacOs -Value $True -Force
                $LoggerFunctions.Info("Operating system is Unix-based.")   
            }
        }
    }
}

function Test-DefinedRequiredVariables {
     <#
    .Synopsis
        Tests if a variable is empty
    .Description
        Takes an array of variables and checks if a value is assigned. Returns array of undefined variables.
    .Example
        Test-RequiredVariables $RequiredVars
    #>
    param (
        [Parameter(Mandatory=$true)][AllowEmptyString()][String[]]$Variables
    )

    if($Variables){
        $LoggerFunctions.Debug("Testing required variables.")
        $undefinedVariables = @()
        foreach($Var in $Variables){
            try {
                Get-Variable $Var -ValueOnly -ErrorAction Stop | Out-Null
            } catch [System.Management.Automation.ItemNotFoundException]{
                $undefinedVariables += $Var
            }
        }

        if($undefinedVariables){
            $Message = "The following required variables were not found in the configuration file or as a parameter: $(($undefinedVariables | Sort-Object)  -join ', ')"
            $LoggerFunctions.Error($Message, $true)
        } else {
            $LoggerFunctions.Debug("All required variables are defined")
        }
    } else {
        $LoggerFunctions.Debug("Provided list of variables is empty.")
    }
}

function Test-ElevatedPowerShell {
    $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-WhiteSpace {
    param(
        [Parameter(Mandatory)][String]$Message,
        [Parameter(Mandatory)][String]$Value
    )

    if($Value.Contains(' ')){
        $ValueTrimmed = $Value.Replace(' ','-')

        # Prompt for name change to remove white spaces
        $ResponseNameChange = Read-HostChoice `
                -Message "$($Message -f $ValueTrimmed)?" `
                -ReturnBool
        #$ResponseNameChange = Read-PromptYesNo -Message $($Message -f $ValueTrimmed) -Color Yellow
        if($ResponseNameChange){
            return $ValueTrimmed
        } else {
            $LoggerFunctions.Warn("The user chose not to provide a name without white spaces or let the tool automatically change it.")
            throw "User chose not to provide a valid name."
        }
    }
    return $Value
}