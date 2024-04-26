<#
Configuration Functions

- Intended for reuse in configuration functions
#> 
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main)

function Register-PolicyServer {
    $LoggerFunctions.Logger = "KF.Toolkit.Function.RegisterPolicyServer"

    try {
        $LoggerFunctions.Debug("Getting policy server values and buildilng hash table with different values.")

        # Get values from default configuration file or user prompt
        $PolicyServer = Get-ConfigDefault `
            -Prompt "Enter the FQDN of the EJBCA CEP Server (example: policyserver.keyfactor.com)" `
            -Config "PolicyServer"

        $PolicyServerAlias = Get-ConfigDefault `
            -Prompt "Enter the name of the MSAE alias (case-sensitve)" `
            -Config "PolicyServerAlias"

        if(-not $Domain){
            $Domain = ((Get-ADDomain).Forest)
        }

        # Build object using values
        $BuilderUri = [System.Text.StringBuilder]::new("https://$PolicyServer/ejbca")
        $EjbcaUri = $BuilderUri.ToString()
        [void]$BuilderUri.Append("/msae/CEPService?$PolicyServerAlias")
        $AliasUri = $BuilderUri.ToString()

        # SPN
        $BuildPrincNames = [System.Text.StringBuilder]::new()
        [void]$BuildPrincNames.Append("HTTP/$PolicyServer")
        $ServicePrincipalName = $BuildPrincNames.ToString()

        # UPN
        [void]$BuildPrincNames.Append("@$($Domain.ToUpper())")
        $UniversalPrincipalName = $BuildPrincNames.ToString()

        $HashTable = [PSCustomObject]@{
            EjbcaUri = $EjbcaUri
            AliasUri = $AliasUri
            FQDN = $PolicyServer
            SPN = $ServicePrincipalName
            UPN = $UniversalPrincipalName
        }
    
        $LoggerFunctions.Debug(("Policy server values: `n$($HashTable|ConvertTo-JSON)"))
        return $HashTable
    }
    catch {
        $LoggerFunctions.Exception($_)
    }
    finally {
        $BuilderUri = $null
        if([String]::IsNullOrEmpty($BuilderUri)){
            $LoggerFunctions.Debug("Successfully emptied Policy Server [System.Text.StringBuilder]")
        }
        else {
            $LoggerFunctions.Warn("Failed to empty Policy Server [System.Text.StringBuilder]. This might cause memory problems.")
        }
    }
}

function Register-ServiceAccount {
    param(
        [Parameter(Mandatory)][Object]$PolicyServerObject
    )

    try {
        $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
        $LoggerFunctions.Debug("Getting service account and building service account attributes object.")

        while($true){
            $ServiceAccount = Get-ConfigDefault `
                -Prompt "Enter the name of the Service Account used for MSAE" `
                -Config "ServiceAccount"

            #$Attributes = @()
            $Attributes = Get-ADUserWrapper -Identity $ServiceAccount
            if($Attributes){
                break
            }
            $ServiceAccount = $null
        }
        
        # Password
        while($true){
            try {

                $ServiceAccountPassword = Get-ConfigDefault `
                -Config "ServiceAccountPassword" `
                -Prompt "Enter the password for $ServiceAccount. This will be used to create the keytab file to ensure the passwords match" #`
                #-Mask
                
                # ConverT to secure string
                $SecureServiceAccountPassword = ConvertTo-SecureString `
                    -String $ServiceAccountPassword `
                    -AsPlainText `
                    -Force
                
                # Build PSCredential and test password
                $Credential = New-Object `
                    -TypeName System.Management.Automation.PSCredential `
                    -ArgumentList $ServiceAccount, $SecureServiceAccountPassword 

                # Test Password
                Get-ADUser -Identity $ServiceAccount -Credential $Credential | Out-Null
                $LoggerFunctions.Debug("Successfully tested provided service account password.")

                # Append password to AD User array object
                $Attributes|Add-Member -MemberType NoteProperty -Name Password -Value $ServiceAccountPassword

                return $Attributes
            }
            catch [System.Security.Authentication.AuthenticationException] {
                $ServiceAccountPassword = $null # empty temporary password for another attempt
                Write-Host $Error[0] -ForegroundColor Red
                #Write-Host "The provided password is incorrect. Please enter the password again" -ForegroundColor Yellow
            } 
        }   
    }
    catch {
        Write-Host $_ -ForegroundColor Red
    } 
}