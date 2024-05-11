Write-Host "$($ToolCurrent.Title)`n" -ForegroundColor Blue 
foreach($V in $ToolCurrent.DescriptionVerbose){
    Write-Host "- $V" -ForegroundColor Blue 
}

#$ToolContinue = Read-HostPrompt "`nHit enter to continue or enter 'main' to return to the main menu" -NoInput
if($ToolContinue -ne "main"){

    try {
        do {
            $PolicyServerAttributes = Register-PolicyServer `
                -Validate:$true `
                -Alias 
        } until (
            ($PolicyServerAttributes -ne $false)
        )

        do {
            $ServiceAccount = Register-ServiceAccount `
                -ServiceAccount $ServiceAccount `
                -CheckExisting:$false 
        } until (
            (-not [String]::IsNullOrEmpty($ServiceAccount))
        )

        # Get password
        $SecureServiceAccountPassword = Register-ServiceAccountPassword `
            -Password $ServiceAccountPassword `
            -SecureString

        # Get service account directory path
        $ServiceAccountOrgUnit = Read-HostPrompt -Message "Enter the Organization Unit to create the Service Account in"
        $ResultsOrgUnitSearch = (Get-ADOrganizationalUnit -Filter "Name -like '*$($ServiceAccountOrgUnit)*'").DistinguishedName

        # Present selections if more than one organization unti matches search
        if($ResultsOrgUnitSearch.Count -gt 1){
            $ServiceAccountPath = Read-PromptSelection `
                -Message "Multiple organizational units matching the '$ServiceAccountOrgUnit' query were returned. Select one of the following choices:" `
                -Selections $ResultsOrgUnitSearch
        } else {
            $ServiceAccountPath = $ResultsOrgUnitSearch
        }

        # Apply default expiration days
        #if([String]::IsNullOrEmpty($ServiceAccountExpiration)){$ServiceAccountExpiration = 365} 
        $ServiceAccountExpiration = %{if([String]::IsNullOrEmpty($ServiceAccountExpiration)){365}else{$ServiceAccountExpiration}}
        Write-Host $ServiceAccountExpiration -ForegroundColor Yellow

        # Construct attributes table for verification before creation
        $ServiceAccountCreateObject = [PSCustomObject]@{
            Name = $ServiceAccount
            Expiration = (Get-Date).AddDays($ServiceAccountExpiration)
            ServicePrincipalName = $PolicyServerAttributes.Spn 
            Path = $ServiceAccountPath
        }

        #Write-Host "Create the service account using the following attributes:`n $($ServiceAccountCreateObject|Out-TableString)" -ForegroundColor Yellow
        $ServiceAccountCreateConfirmation = Read-PromptSelection `
            -Message "Create the service account using the following attributes:`n $($ServiceAccountCreateObject|Out-TableString)`n" `
            -Selections "Yes","No"
       
        if($ServiceAccountCreateConfirmation|Convert-PromptReponseBool){

            # Create service account
            $ResultCreateServiceAccount = New-AdUser `
                -Name $ServiceAccountCreateObject.Name `
                -AccountExpirationDate $ServiceAccountCreateObject.Expiration `
                -AccountPassword $SecureServiceAccountPassword `
                -ServicePrincipalNames $ServiceAccountCreateObject.ServicePrincipalName `
                -KerberosEncryptionType $ToolBoxConfig.KeytabEncryptionTypes `
                -Path $ServiceAccountCreateObject.Path `
                -PasswordNeverExpires:$true `
                -Enabled:$true `
                -PassThru

        } else {
            $ToolBoxConfig.ScriptExit = $true
        }

        Write-Host $ResultCreateServiceAccount -ForegroundColor Green
    }
    catch {
        Write-Host $_ -ForegroundColor Yellow
    }
    
    # Set service principal name 

}
