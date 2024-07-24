
# Create Kerberos files
if(($Tool -eq 'kerbcreate')){

# Write operating to console when running interactive so user knows what is happening
if($NonInteractive){Write-Host "Creating kerberos files..." -ForegroundColor Yellow}

$PolicyServerObject= Register-PolicyServer -IncludeAlias `
    -Server $PolicyServer `
    -Alias $PolicyServerAlias

$ServiceAccount = Register-ServiceAccount -ValidateExists `
    -Account $ServiceAccount

# Create Keytab
$ResultCreateKeytab = New-Keytab `
    -Account $ServiceAccount `
    -Principal $PolicyServerObject.UPN `
    -Password $ServiceAccountPassword `
    -Outfile "$($ToolBoxConfig.Files)\$($ServiceAccount).keytab"

# Create Krb5 Configuration file
$ResultCreateKrb5Conf = New-Krb5Conf `
    -Forest $ToolBoxConfig.ParentDomain `
    -KDC $ToolBoxConfig.Domain `
    -Outfile "$($ToolBoxConfig.Files)\$($ServiceAccount)-krb5.conf"

# Dump Kerberos Files
} elseif($Tool -eq "kerbdump") {

# Write operating to console when running interactive so user knows what is happening
if($NonInteractive){Write-Host "Dumping kerberos files..." -ForegroundColor Yellow}

    # Get existing keytab file
    $Keytab = Register-File `
        -Message "Enter the full path to the keytab file" `
        -FilePath $Keytab `
        -FileType "Keytab" `
        -Validate

    # Dump contents
    $KeytabContents = Out-Keytab $Keytab
}
