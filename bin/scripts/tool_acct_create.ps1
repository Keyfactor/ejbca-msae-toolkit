
# Write operating to console when running interactive so user knows what is happening
if($NonInteractive){Write-Host "Creating service account..." -ForegroundColor Yellow}

$PolicyServerObject= Register-PolicyServer -ValidateAvailableSpn -IncludeAlias `
    -Server $PolicyServer `
    -Alias $PolicyServerAlias

$ServiceAccount = Register-ServiceAccount `
    -Account $ServiceAccount

$CreateServiceAccount = New-ServiceAccount `
    -Name $ServiceAccount `
    -Password $ServiceAccountPassword `
    -Spn $PolicyServerObject.Spn `
    -OrgUnit $ServiceAccountOrgUnit `
    -NoConfirm $NonInteractive