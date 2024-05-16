# create_kerberos_files

# Service Account
while($true){
    $ServiceAccountAttributes = Register-ServiceAccount `
        -ServiceAccount $ServiceAccount
    if(-not $ServiceAccount){
        $ServiceAccount = $null
    } else {
        $ServiceAccount = $ServiceAccountAttributes.name
        break
    }
}

# Service Account Password
while($true){
    $ServiceAccountPassword = Register-ServiceAccountPassword `
        -Message "Enter the password for the MSAE service account. This will be used to create the keytab file to ensure the passwords match." `
        -Password $ServiceAccountPassword 
    if(-not $ServiceAccountPassword){
        $ServiceAccountPassword = $null
    } else {
        break
    }
}

# Policy Server
while($true){
    $PolicyServerAttributes = Register-PolicyServer 
    if(-not $PolicyServerAttributes){
        $PolicyServerAttributes = $null
    } else {
        break
    }
}

# Create files
try {

    Write-Host "`nAttempting to create kerberos files..." -ForegroundColor Yellow

    $KeytabOutfile = "$($ToolBoxConfig.Files)\$($ServiceAccount).keytab"
    $ResultCreateKeytab = New-Keytab `
        -Account $ServiceAccount `
        -Principal $PolicyServerAttributes.UPN `
        -Password $ServiceAccountPassword `
        -Outfile $KeytabOutfile `

    # Create Krb5 Configuration file
    $Krb5ConfOutfile = "$($ToolBoxConfig.Files)\$($ServiceAccount)-krb5.conf"
    $ResultCreateKrb5Conf = New-Krb5Conf `
        -Domain $ToolBoxConfig.DomainFqdn `
        -Outfile $Krb5ConfOutfile

    if($ResultCreateKeytab -and $ResultCreateKrb5Conf){
        Write-Host -ForegroundColor Green `
            "Successfully created Keytab and Krb5 Conf files in directory $($ToolBoxConfig.Files)." 
    }
    else {
        Write-Host $_ -ForegroundColor Red
    }
}
catch {
   Write-Host $Error[0] -ForegroundColor Red
}