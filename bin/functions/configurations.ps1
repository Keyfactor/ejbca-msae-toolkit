<#
Configuration Functions

- Intended for reuse in configuration functions
#> 
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main)

function Register-PolicyServer {
    param(
        [Parameter(Mandatory=$false)][Boolean]$Validate=$false,
        [Parameter(Mandatory=$false)][Switch]$Alias
    )
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "KF.Toolkit.Function.RegisterPolicyServer"

    try {
        $LoggerFunctions.Debug("Getting policy server values and buildilng hash table with different values.")

        if(-not $PolicyServer){
            $PolicyServer = Read-HostPrompt -Message "Enter the FQDN of the EJBCA CEP Server (example: policyserver.keyfactor.com)"
            $LoggerFunctions.Info("Setting user-provided variable PolicyServer=$($PolicyServer).") 
        }
        else {
            $LoggerFunctions.Info("Using PolicyServer=$($PolicyServer) from configuration file.", $true) 
        }

        if(-not $PolicyServerAlias){
            $PolicyServerAlias = Read-HostPrompt -Message "Enter the name of the MSAE alias (case-sensitve)"
            $LoggerFunctions.Info("Setting user-provided variabele PolicyServerAlias=$($PolicyServerAlias)") 
        }
        else {
            $LoggerFunctions.Info("Using PolicyServerAlias=$($PolicyServerAlias) from configuration file.") 
        }

        if(-not $Domain){
            $Domain = ((Get-ADDomain).Forest) 
        }
        else {
            $LoggerFunctions.Info("Using Domain=$($Domain) from configuration file.", $true) 
        }

        # Build object using values
        $BuilderUri = [System.Text.StringBuilder]::new("https://$PolicyServer/ejbca")
        $EjbcaUri = $BuilderUri.ToString()

        # Alias
        if($Alias){
            [void]$BuilderUri.Append("/msae/CEPService?$PolicyServerAlias")
            $AliasUri = $BuilderUri.ToString()
        }
        else {
            $AliasUri = $null
        }

        # SPN
        $BuildPrincNames = [System.Text.StringBuilder]::new()
        [void]$BuildPrincNames.Append("HTTP/$PolicyServer")
        $ServicePrincipalName = $BuildPrincNames.ToString()

        # UPN
        [void]$BuildPrincNames.Append("@$($Domain.ToUpper())")
        $UniversalPrincipalName = $BuildPrincNames.ToString()

        # Find all the service principal names in active directory and loop directory entry results
        # create and return object if matching service princpal name 
        if($Validate){
            $Searcher = [adsisearcher]"(servicePrincipalName=*)"
            $SearchResults = $Searcher.Findall()
            foreach($Result in $SearchResults){
                $Entry = $Result.GetDirectoryEntry()
                if($Entry.servicePrincipalName -eq $ServicePrincipalName){
                    $Results = [PSCustomObject]@{
                        Exists = $true
                        SPN = $ServicePrincipalName
                        Account = $($Entry.Name)
                    }
                    $LoggerFunctions.Info("Service principal name $ServicePrincipalName is already assigned: $($Results|ConvertTo-JSON)") 
                    Write-Host -ForegroundColor Yellow `
                        "$ServicePrincipalName is already configured on '$($Entry.Name)'. Provide a different name or remove the SPN from $($Entry.Name)." 
                    return $false
                }
            }  
            $LoggerFunctions.Debug("Service principal name $ServicePrincipalName is not already assigned to an account and is free to use.") 
        }

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
            $LoggerFunctions.Debug("Emptied System.Text.StringBuilder used to construct policy server object")
        }
        else {
            $LoggerFunctions.Warn("Failed to empty Policy Server System.Text.StringBuilder. This might cause memory problems.")
        }
        
    }
}

function Register-ServiceAccount {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$ServiceAccount,
        [Parameter(Mandatory=$false)][Boolean]$CheckExisting=$true
        
    )
    $LoggerFunctions.Logger = "KF.Toolkit.Function.RegisterServiceAccount"

    try {
        $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
        $LoggerFunctions.Debug("Getting service account and building service account attributes object.")

        while($true){
            if([String]::IsNullOrEmpty($ServiceAccount)){
                $ServiceAccount = Read-HostPrompt -Message "Enter the name of the Service Account used for MSAE"
                $LoggerFunctions.Info("Setting user-provided variabele ServiceAccount=$($ServiceAccount)", $true)
            }
            else {
                $LoggerFunctions.Info("Using ServiceAccount=$($ServiceAccount) from configuration file.", $true) 

            }
            $Searcher = [adsisearcher]::new()
            $Searcher.Filter = "(samAccountName=$($ServiceAccount))" 
            $ServiceAccountObject = $Searcher.FindOne().properties

            if($ServiceAccountObject){
                if($CheckExisting){
                    $LoggerFunctions.Info("Found provided service account: '$ServiceAccount'")
                    $LoggerFunctions.Debug("$ServiceAccount attributes: $($ServiceAccountObject|Out-TableString)")
                    return $ServiceAccountObject
                }
                else {
                    $LoggerMain.Warn("An account name '$ServiceAccount' already exists. Provide another name.", $true)
                    $ServiceAccount = $null
                }
            }
            else {
                if($CheckExisting){
                    $LoggerFunctions.Warn("Could not locate provided service account: $ServiceAccount.", $true)
                    $ServiceAccount = $null
                }
                else {
                    $LoggerFunctions.Info("The provided service account name '$ServiceAccount' does not existing in active directory and is available for use.")
                    return $ServiceAccount
                }     
            }      
        }
    }
    catch {
        Write-Host $_ -ForegroundColor Red
    } 
}

function Register-ServiceAccountPassword {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$Password,
        [Parameter(Mandatory=$false)][String]$ServiceAccount,
        [Parameter(Mandatory=$false)][Boolean]$Validate=$false,
        [Parameter(Mandatory=$false)][Switch]$SecureString
    )
    $LoggerFunctions.Logger = "KF.Toolkit.Function.RegisterServicePassword"
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Debug("Testing password for service account: $ServiceAccount.")

    while($true){
        try {
        
            if([String]::IsNullOrEmpty($Password)){
                $Password = Read-HostPrompt `
                    -Message "Enter the password for $ServiceAccount. This will be used to create the keytab file to ensure the passwords match"
                $LoggerFunctions.Info("Setting user-provided variable ServiceAccountPassword=<masked>")
            }
            else {
                $LoggerFunctions.Info("Using ServiceAccountPassword=<masked> from configuration file.")
                $LoggerFunctions.Console("Yellow")
            }

            # Convert to secure string
            $SecureServiceAccountPassword = ConvertTo-SecureString `
                -String $Password `
                -AsPlainText `
                -Force

            if($Validate){
                # Build PSCredential and test password
                $Credential = New-Object `
                    -TypeName System.Management.Automation.PSCredential `
                    -ArgumentList $ServiceAccount, $SecureServiceAccountPassword 

                # Test Password
                Get-ADUser -Identity $ServiceAccount -Credential $Credential | Out-Null
                $LoggerFunctions.Debug("Successfully tested $ServiceAccount password.")

            }
            if($Password -and $SecureString){
                return $SecureServiceAccountPassword
            }
            elseif($Password){
                return $Password
            }
        }
        catch [System.Security.Authentication.AuthenticationException] {
            $LoggerFunctions.Error("Incorrect password provided for $ServiceAccount."); $LoggerFunctions.Console("Yellow")
            $Password = $null # empty temporary password for another attempt
    
        }
        catch {
            Write-Host $_ -ForegroundColor Red
        } 
    }  
}