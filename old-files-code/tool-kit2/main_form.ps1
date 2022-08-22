    
$logLevel= 'INFO'
$logFile = "$PSScriptRoot\toolkit.log"

# Global variables
# Reset to $null before each run
$Global:clientUser = $null
$Global:clientComputer = $null

function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyyMMdd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}

. "$PSScriptRoot\description_form\description_form.ps1"

if($ToolOverview.DialogResult -eq 'OK'){

    . "$PSScriptRoot\sysprep_form\sysprep_form.ps1"

} else {
Exit-PSSession

    }

if($SystemPrep.DialogResult -eq 'Continue'){

} else {
    Exit-PSSession

    }



