<#
Wrapper Functions

- The functions listed here are part of already existing modules
- Purpose is to portable logging and custom return attributes for the MSAE Toolkit
#> 

function Get-ADUserWrapper {
    param(
        [Parameter(Mandatory)][String]$Identity
    )
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "KF.Toolkit.Function.GetADUserWrapper"

    try {
        $AdUser = (Get-AdUser -Identity $Identity -Properties * | Select *)
        $LoggerFunctions.Info("Found AD User: $($AdUser.DistinguishedName)")
        return $AdUser
    }
    catch {
        Write-Host $Error[0] -ForegroundColor Red
        $LoggerFunctions.Exception($_)
        return $false
    }
}

function Get-ADGroupWrapper {
    param(
        [Parameter(Mandatory)][String]$Group
    )

    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.ChangeLogger("MSAE.Toolkit.Function.GetADGroupWrapper")

    try {
        $AdGroup = (Get-ADGroup -Identity $Group -Properties * | Select *)
        $LoggerFunctions.INFO("Found security group: $($AdGroup.DistinguishedName)")
        return $true
    }
    catch {
        Write-Host $Error[0] -ForegroundColor Red
        $LoggerMain.Exception($_)
        return $false
    }
}