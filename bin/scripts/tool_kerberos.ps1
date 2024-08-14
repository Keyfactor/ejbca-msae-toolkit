
# Create Kerberos files
if(($Tool -eq 'kerbcreate')){

    # Write operating to console when running interactive so user knows what is happening
    if($NonInteractive){Write-Host "Creating kerberos files..." -ForegroundColor Yellow}

    $PolicyServerObject= Register-PolicyServer -IncludeAlias `
        -Server $PolicyServer `
        -Alias $PolicyServerAlias

    $AccountName = Register-ServiceAccount -ValidateExists `
        -Account $AccountName

    $AccountPassword = Register-ServiceAccountPassword `
        -Account $AccountName `
        -Password $AccountPassword

    # Create Keytab
    $ResultCreateKeytab = New-Keytab `
        -Account $AccountName `
        -Principal $PolicyServerObject.UPN `
        -Password $AccountPassword `
        -Outfile "$($ToolBoxConfig.Files)\$($AccountName).keytab"

    # Create Krb5 Configuration file
    $ResultCreateKrb5Conf = New-Krb5Conf `
        -Forest $ToolBoxConfig.ParentDomain `
        -KDC $ToolBoxConfig.Domain `
        -Outfile "$($ToolBoxConfig.Files)\$($AccountName)-krb5.conf"

# Dump Kerberos Files
} elseif($Tool -eq "kerbdump") {

# Write operating to console when running interactive so user knows what is happening
if($NonInteractive){Write-Host "Dumping kerberos files..." -ForegroundColor Yellow}

    # Get existing keytab file
    $KerberosKeytab = Register-File `
        -Message "Enter the full path to the keytab file" `
        -FilePath $KerberosKeytab `
        -FileType "Keytab" `
        -Validate

    # Dump contents
    $KeytabContents = Out-Keytab $KerberosKeytab
}
