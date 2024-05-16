
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main)

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
    }
    else{
        while ($true) {
            if($MyInvocation.BoundParameters.Keys -contains "Default"){
                Write-Host "$Message [Default: $(if([String]::IsNullOrEmpty($Default)){"None"}else{$Default})]: " `
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
