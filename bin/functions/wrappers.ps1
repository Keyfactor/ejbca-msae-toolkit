<#
Wrapper Functions

- The functions listed here are part of already existing modules
- Purpose is to portable logging and custom return attributes for the MSAE Toolkit
#> 

function Get-ADUserWrapper {
    param(
        [Parameter(Mandatory)][String]$Identity
    )
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

    $LoggerFunctions.ChangeLogger("MSAE.Toolkit.Function.GetADGroupWrapper")
    $LoggerFunctions.DEBUG("Searching active directry for CN=$($Group)")

    try {
        $SecurityGroup = (Get-ADGroup -Identity $Group -Properties * | Select *)
        $LoggerFunctions.INFO("Found security group: $($Group.DistinguishedName)")
        return $true
    }
    catch {
        Write-Host $Error[0] -ForegroundColor Red
        $LoggerMain.Exception($_)
        return $false
    }
}