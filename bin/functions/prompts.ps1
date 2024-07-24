# Initialize logger
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main, $ToolBoxConfig.LogLevel)

function Assert-ToolPrompt {
    Param(
        [Parameter(Mandatory=$true)][String]$Title,
        [Parameter(Mandatory=$true)][String]$Description,
        [Parameter(Mandatory=$false)][Bool]$NonInteractive = $false
    )
    $LoggerFunctions.Logger = "KF.Toolkit.Function.AssertToolPromptMessage"

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

function Read-HostPrompt{
    param(
        [Parameter(Mandatory=$true)][String]$Message,
        [Parameter(Mandatory=$false)][String]$Color = "Gray",
        [Parameter(Mandatory=$false)][String]$Default,
        [Parameter(Mandatory=$false)][Switch]$NoInput,
        [Parameter(Mandatory=$false)][Switch]$NewLine
    )
    if($NoInput){
        if($NewLine){
            Write-Host $Message -ForegroundColor $Color
        }
        else {
            Write-Host $Message -ForegroundColor $Color -NoNewline
        }
        $Response = $Host.UI.ReadLine()
        return $Response
    } else {
        while ($true) {
            if($MyInvocation.BoundParameters.Keys -contains "Default"){
                # Write-Host "$Message [Default: $(if([String]::IsNullOrEmpty($Default)){"None"}else{$Default})]: " `
                #     -ForegroundColor $Color `
                #     -NoNewline
                Write-Host "$($Message): " `
                    -ForegroundColor $Color `
                    -NoNewline
                $Response = $Host.UI.ReadLine()
                $Response = ($Default,$Response)[[Bool]$Response] 

            } else {
                Write-Host "$($Message): " -ForegroundColor $Color -NoNewline
                $Response = $Host.UI.ReadLine()
            }

            # validate user input
            if([string]::IsNullOrEmpty($Response) -or ($Response -eq "None")){
                Write-Host "No input was provided." -ForegroundColor Yellow
            } elseif($Response -eq "exit"){
                throw "User chose to exit script"
            } else {
                return $Response
            }
        }
    }
}

function Read-PromptSelection{
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
        [Parameter(Mandatory=$true)][String]$Message,
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
    $Selection = $Host.UI.PromptForChoice($Title, $Message, $Options, $DefaultOption); Write-Host "`n"

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