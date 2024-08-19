# Create Kerberos files
Write-Host "`n" -NoNewLine; Write-Host "[Registering Required Variables]"
if(($Tool -eq 'kerbcreate')){

    $PolicyServerObject= Register-PolicyServer `
        -Server $PolicyServer `
        -Alias $PolicyServerAlias

    $AccountName = Register-ServiceAccount `
        -Account $AccountName `
        -ValidateExists

    $AccountPassword = Register-ServiceAccountPassword `
        -Account $AccountName `
        -Password $AccountPassword

    Write-Host "`n" -NoNewLine; Write-Host "[Creating Kerberos Files]"
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

    Write-Host "`n" -NoNewLine; Write-Host "[Keytab Contents]"
    $ContentsKeytab = Out-Keytab $KerberosKeytab
    Write-Host "Keys: $($ContentsKeytab.Keys -join ', ')" -ForegroundColor Green
    Write-Host "Principal: $($ContentsKeytab.Principal)" -ForegroundColor Green

    Write-Host "`n[Krb5.conf Contents]"
    $ContentsKrb5 = Out-Krb5Conf $KerberosKrb5
    $ContentsKrb5 | foreach {
        Write-Host "Default domain: $($_.DefaultDomain)" -ForegroundColor Green
        Write-Host "Permitted key types: $($_.PermittedKeyTypes -join ', ')" -ForegroundColor Green
        Write-Host "Realms: " -ForegroundColor Green
        foreach($R in $_.Realms){
            Write-Host "  Name: $($R.Name)" -ForegroundColor Green
            Write-Host "  Kdcs: $($R.Kdcs -join ', ')" -ForegroundColor Green
            Write-Host "  Default: $($R.Default)" -ForegroundColor Green
        }
        Write-Host "Domain realms: $($_.DomainRealms -join ', ')`n" -ForegroundColor Green
    }
}
