
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main)

function Read-HostPrompt{
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [Parameter(Mandatory=$false)][string]$Color = "Gray",
        [Parameter(Mandatory=$false)][string]$Default,
        [Parameter(Mandatory=$false)][switch]$NoInput
    )

    if($NoInputRequired){
        Write-Host $Message -ForegroundColor $Color -NoNewline; $Host.UI.ReadLine()
    }
    else{
        while ($true) {
            if($NoInput) {
                Write-Host "$($Message)" -ForegroundColor $Color -NoNewline; $Host.UI.ReadLine()
                return
            }	
            elseif($Default){
                $Response = Write-Host "$Message `n[Default: $($Default)]: " -ForegroundColor $Color -NoNewline
                $Response = $Host.UI.ReadLine()
                $Response = ($Default,$Response)[[bool]$Response] 
            }
            else {
                $Response = Write-Host "$($Message): " -ForegroundColor $Color -NoNewline
                $Response = $Host.UI.ReadLine()
            }				
            if([string]::IsNullOrEmpty($Response)){
                Write-Host "No input was provided." -ForegroundColor Yellow
            }
            else {
                return $Response
            }
        }
    }
}

function Read-PromptSelection{
    param(
        [Parameter(Mandatory=$false)][string]$Message="",
        [Parameter(Mandatory=$false)][string]$Color = "Gray",
        [Parameter()][string[]]$Selections
    )

    $SelectionArray = @(
    $Selections | ForEach-Object {$Index = 1}{
        [pscustomobject]@{N = $Index; S = "-"; Description = "$_"}; $Index++
    })
    Write-Host $Message -ForegroundColor $Color -NoNewline 
    Write-Host ($SelectionArray | Format-Table -HideTableHeaders -AutoSize | Out-String) -ForegroundColor $Color -NoNewline

    while ($true) {
        Write-Host "Selection: " -NoNewline
        $Selection = $Host.UI.ReadLine()
        if($Selection -in 1..$SelectionArray.Count){
            return $SelectionArray.where({$_.N -match $Selection}).Description
        }
        elseif($Selection -eq "quit"){
            exit
        }
        else {
            Write-Host "`nInvalid selection. Enter a number between 1-$($SelectionArray.Count)." -ForegroundColor Yellow
        }
    }
}

function Get-ConfigDefault {
    param (
        [Parameter(Mandatory)][String]$Config,
        [Parameter(Mandatory)][String]$Prompt,
        [Parameter(Mandatory=$false)][Switch]$Mask
    )
    $LoggerFunctions.ChangeLogger("KF.Toolkit.Function.GetConfigDefault")

    # Load configuration variable value and test if empty
    $ConfigValue = Get-Variable $Config -ValueOnly -ErrorAction SilentlyContinue
    if(-not $ConfigValue){
        $ConfigValue = Read-HostPrompt -Message $Prompt
    }
    else {
        if($Mask){
            $LoggerFunctions.Info("Using $($Config)=<hidden> from configuration file.") 
        }
        else {
            $LoggerFunctions.Info("Using $($Config)=$($ConfigValue) from configuration file.") 
        }
    }
    return $ConfigValue
}