### Fixes ###
## Encryption Key Check ##
#Check if Encryption Key Check failed and update service account if it did
if($encKeyCheck -eq $true){
Write-Host "Setting $svcAccount to support AES256..." -ForegroundColor Yellow
    try{

        Set-ADUser $svc_account -KerberosEncryptionType AES256
        $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
        Add-Content $msaeLog "$tlog -- INFO: SERVICE ACCOUNT - Successfully set the Service Account to support AES-256"

        }
        catch {

        $tlog = Get-Date -Format "yyyyMMdd_HH:mm:ss"
        Add-Content $msaeLog "$tlog -- ERROR: SERVICE ACCOUNT - Unsuccessfully set the Service Account to support AES-256"
        }

}
