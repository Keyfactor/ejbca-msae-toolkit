Write-Host $ToolCurrent.Title -ForegroundColor Blue 
Write-Host -ForegroundColor Blue  @("
- This tool will provide prompts for input and allow for different options.
- If a value is defined in the toolkit configuration file, it will be used as the default value.
- If a value is undefined, a prompt will appear requiring input.") 

Read-HostPrompt "`nHit enter to continue..." -NoInput

$PolicyServerAttributes = Register-PolicyServer
$ServiceAccountAttributes = Register-ServiceAccount $PolicyServerAttributes
$Global:ServiceAccount = $ServiceAccountAttributes.Name

try {

    $KeytabOutfile = "$($ToolBoxConfig.Files)\$($ServiceAccount).keytab"
    $ResultCreateKeytab = New-Keytab `
        -Account $ServiceAccount `
        -Principal $PolicyServerAttributes.UPN `
        -Password $ServiceAccountAttributes.Password `
        -Outfile $KeytabOutfile

    # Create Krb5 Configuration file
    $Krb5ConfOutfile = "$($ToolBoxConfig.Files)\$($ServiceAccount)-krb5.conf"
    $ResultCreateKrb5Conf = New-Krb5Conf `
        -Domain $ToolBoxConfig.DomainFqdn `
        -Outfile $Krb5ConfOutfile

    if($ResultCreateKeytab -and $ResultCreateKrb5Conf){
        Read-HostPrompt "Successfully created Keytab and Krb5 Conf file in $($ToolBoxConfig.Files). Hit enter to return to the main menu..." -NoInput -Color Green
    }
    
}
catch {
    Write-Host $Error[0] -ForegroundColor Red
}
