
# Write operating to console when running interactive so user knows what is happening
if($NonInteractive){Write-Host "Creating service account..." -ForegroundColor Yellow}

$PolicyServerObject= Register-PolicyServer -ValidateAvailableSpn `
    -Server $PolicyServerHostname 

$ServiceAccountName = Register-ServiceAccount `
    -Account $ServiceAccountName

$CreateServiceAccount = New-ServiceAccount `
    -Name $ServiceAccountName `
    -Password $ServiceAccountPassword `
    -Spn $PolicyServerObject.Spn `
    -OrgUnit $ServiceAccountOrgUnit `
    -NoConfirm $NonInteractive