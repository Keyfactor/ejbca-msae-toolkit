Clear-Host

Write-Host $ToolCurrent.Title -ForegroundColor Blue 
Write-Host -ForegroundColor Blue  @("
- This tool will provide prompts for input and allow for different options.
- If a value is defined in the toolkit configuration file, it will be used as the default value.
- If a value is undefined, a prompt will appear requiring input.") 

Read-HostPrompt "`nHit enter to continue..." -NoInput

$PolicyServerAttributes = Register-PolicyServer

# Get service account attributes and store name in global attribute
$ServiceAccountAttributes = Register-ServiceAccount $ServiceAccount
#$Global:ServiceAccount = $ServiceAccountAttributes.name
$ServiceAccount = $ServiceAccountAttributes.name

#$Global:ServiceAccountPassword = Register-ServiceAccountPassword `
$ServiceAccountPassword = Register-ServiceAccountPassword `
    -ServiceAccount $ServiceAccount `
    -Password $ServiceAccountPassword `
    -Validate:$true

try {

    $KeytabOutfile = "$($ToolBoxConfig.Files)\$($ServiceAccount).keytab"
    $ResultCreateKeytab = New-Keytab `
        -Account $ServiceAccount `
        -Principal $PolicyServerAttributes.UPN `
        -Password $ServiceAccountPassword `
        -Outfile $KeytabOutfile

    # Create Krb5 Configuration file
    $Krb5ConfOutfile = "$($ToolBoxConfig.Files)\$($ServiceAccount)-krb5.conf"
    $ResultCreateKrb5Conf = New-Krb5Conf `
        -Domain $ToolBoxConfig.DomainFqdn `
        -Outfile $Krb5ConfOutfile

    if($ResultCreateKeytab -and $ResultCreateKrb5Conf){
        Read-HostPrompt -NoInput `
            -Message "Successfully created Keytab and Krb5 Conf file in $($ToolBoxConfig.Files). Hit enter to return to the main menu..." `
            -Color Green 
    }
    
}
catch {
    Write-Host $Error[0] -ForegroundColor Red
}
