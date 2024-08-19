Write-Host "`n[Registering Required Variables]"
$PolicyServerObject= Register-PolicyServer -ValidateAvailableSpn `
    -Server $PolicyServer 

$AccountName = Register-ServiceAccount `
    -Account $AccountName

$CreateServiceAccount = New-ServiceAccount `
    -Name $AccountName `
    -Password $AccountPassword `
    -Spn $PolicyServerObject.Spn `
    -OrgUnit $AccountOrgUnit `
    -NoConfirm $NonInteractive