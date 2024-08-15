
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
        -FileType "Kerberos Keytab" `
        -Validate

    $KerberosKrb5 = Register-File `
        -Message "Enter the full path to the krb5 file" `
        -FilePath $KerberosKrb5 `
        -FileType "Kerberos Krb5" `
        -Validate

    $ContentsKeytab = Out-Keytab $KerberosKeytab
    $ContentsKrb5 = Out-Krb5Conf $KerberosKrb5

    Write-Host "`nKeytab Contents:`n"
    Write-Host "Keys: $($ContentsKeytab.Keys -join ', ')"
    Write-Host "Principal: $($ContentsKeytab.Principal)"

    Write-Host "`nKrb$ Conf Contents:`n"
    $ContentsKrb5 | foreach {
        Write-Host "Default domain: $($_.DefaultDomain)"
        Write-Host "Permitted key types: $($_.PermittedKeyTypes -join ', ')"
        Write-Host "Realms: "
        foreach($R in $_.Realms){
            Write-Host "  Name: $($R.Name)"
            Write-Host "  Kdcs: $($R.Kdcs -join ', ')"
            Write-Host "  Default: $($R.Default)"
        }
        Write-Host "Domain realms: $($_.DomainRealms -join ', ')`n"
    }
}
