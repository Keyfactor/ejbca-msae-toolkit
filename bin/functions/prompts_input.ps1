
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main)

function Read-HostPrompt{
    param(
        [Parameter(Mandatory=$true)][String]$Message,
        [Parameter(Mandatory=$false)][String]$Color = "Gray",
        [Parameter(Mandatory=$false)][String]$Default,
        [Parameter(Mandatory=$false)][Switch]$NoInput,
        [Parameter(Mandatory=$false)][Switch]$NewLine

    )

    if($NoInputRequired){
        Write-Host $Message -ForegroundColor $Color -NoNewline; $Host.UI.ReadLine()
    }
    else{
        while ($true) {
            if($NoInput) {
                if($NewLine){
                    Write-Host "$($Message):" -ForegroundColor $Color
                }
                else {
                    Write-Host "$($Message):" -ForegroundColor $Color -NoNewline;
                }
                $Response = $Host.UI.ReadLine()
                return $Response
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
    Write-Host "`n$Message" -ForegroundColor $Color -NoNewline 
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
