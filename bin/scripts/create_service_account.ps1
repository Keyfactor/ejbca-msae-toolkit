
# Service Account
while($true){
    $ServiceAccount = Register-ServiceAccount `
        -Message "Enter the name to use for creating the service account." `
        -ServiceAccount $ServiceAccount `
        -GetExisting:$false
    if(-not $ServiceAccount){
        $ServiceAccount = $null
    } else {
        break
    }
}

# Policy Server
while($true){
    $PolicyServerAttributes = Register-PolicyServer `
        -Validate:$true
    if(-not $PolicyServerAttributes){
        $PolicyServerAttributes = $null
    } else {
        break
    }
}

# Get password
$SecureServiceAccountPassword = Register-ServiceAccountPassword `
    -Password $ServiceAccountPassword `
    -SecureString

# Get service account directory path
# Continue loop until valid path is confirmed by user
do {
    $ServiceAccountOrgUnit = Read-HostPrompt `
        -Message "Enter the Organization Unit to create the Service Account in"
    $ResultsOrgUnitSearch = (Get-ADOrganizationalUnit -Filter "Name -like '*$($ServiceAccountOrgUnit)*'").DistinguishedName

    # Present selections if more than one organization unti matches search
    if($ResultsOrgUnitSearch.Count -gt 1){
        $ServiceAccountPath = Read-PromptSelection `
            -Message "Multiple organizational units matching the '$ServiceAccountOrgUnit' query were returned. Select one of the following choices:" `
            -Selections $ResultsOrgUnitSearch
    } elseif($ResultsOrgUnitSearch.Count -eq 1){
        $ServiceAccountPath = $ResultsOrgUnitSearch
    } else {
        Write-Host "No organization unit was found with the provided search string. Try again." -ForegroundColor Red
    }

} until (
    (-not [String]::IsNullOrEmpty($ServiceAccountPath))
)

# Apply default expiration days
$ServiceAccountExpiration = %{if([String]::IsNullOrEmpty($ServiceAccountExpiration)){365}else{$ServiceAccountExpiration}}

# Construct attributes table for verification before creation
$ServiceAccountCreateObject = [PSCustomObject]@{
    Name = $ServiceAccount
    Expiration = (Get-Date).AddDays($ServiceAccountExpiration)
    ServicePrincipalName = $PolicyServerAttributes.Spn 
    Path = $ServiceAccountPath
}

#Write-Host "Create the service account using the following attributes:`n $($ServiceAccountCreateObject|Out-TableString)" -ForegroundColor Yellow
$ServiceAccountCreateConfirmation = Read-PromptSelection `
    -Message "Would you like to create the service account using the following attributes:`n $($ServiceAccountCreateObject|Out-TableString)`n" `
    -Selections "Yes","No" `
    -ReturnInteger

# Create service account
if($ServiceAccountCreateConfirmation|Convert-PromptReponseBool){

    $ResultCreateServiceAccount = New-AdUser `
        -Name $ServiceAccount `
        -AccountExpirationDate $ServiceAccountCreateObject.Expiration `
        -AccountPassword $SecureServiceAccountPassword `
        -ServicePrincipalNames $ServiceAccountCreateObject.ServicePrincipalName `
        -KerberosEncryptionType $ToolBoxConfig.KeytabEncryptionTypes `
        -Path $ServiceAccountCreateObject.Path `
        -PasswordNeverExpires:$true `
        -Enabled:$true `
        -PassThru

    if($ResultCreateServiceAccount){
        $LoggerMain.Info(($Strings.SuccessfullyCreated -f ("service account", $ResultCreateServiceAccount)))
        $LoggerMain.Console("Green")

    } else {
        Write-Host $_ -ForegroundColor Red
    }

} else {
    Write-Host "Return to the main menu and select the $($ToolCurrent.Title) tool to try again." -ForegroundColor Yellow
}
