
# Write operating to console when running interactive so user knows what is happening
if($NonInteractive){Write-Host "Creating service account..." -ForegroundColor Yellow}

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