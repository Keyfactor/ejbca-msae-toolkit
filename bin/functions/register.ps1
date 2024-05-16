<#
Configuration Functions

- Intended for reuse in configuration functions
#> 
$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main)

# $Strings = @{
#     GeneralException = "A general exception occurred and the tool was exited. Refer to the log for more details."
#     MessageServiceAccount = "Enter the name of the Service Account used for MSAE."
#     ObjectAvailable = "'{0}' does not exist in active directory and is available for use."
#     DoesNotExist = "'{0}' does not exist. Provide another name."
#     AlreadyExists = "'{0}' already exists. Provide another name."
#     ObjectFound = "Found {0}: {1}."
# }

function Register-PolicyServer {
    param(
        [Parameter(Mandatory=$false)][String]$Message="Enter the FQDN of the EJBCA CEP Server.",
        [Parameter(Mandatory=$false)][Boolean]$Validate=$false,
        [Parameter(Mandatory=$false)][Switch]$Alias
    )
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Logger = "KF.Toolkit.Function.RegisterPolicyServer"

    try {
        $LoggerFunctions.Debug("Getting policy server values and buildilng hash table with different values.")

        # Get domain
        $Domain = ((Get-ADDomain).Forest) 

        # Policy Server
        # Get if value is empty or confirm if use defaults not overriden
        # Loop until value is not null
        do {
            
            if([String]::IsNullOrEmpty($PolicyServer) -or ($ToolBoxConfig.UseDefaults -eq $false)){
                $PolicyServer = Read-HostPrompt `
                    -Message $Message `
                    -Default $PolicyServer
            }
              
            # Find all the service principal names in active directory and loop directory entry results
            # create and return object if matching service princpal name 
            if($Validate){
                $Searcher = [adsisearcher]"(servicePrincipalName=*)"
                $SearchResults = $Searcher.Findall()
                foreach($Result in $SearchResults){
                    $Entry = $Result.GetDirectoryEntry()
                    if($Entry.servicePrincipalName -eq "HTTP/$PolicyServer"){
                        $LoggerFunctions.Info("The EJBCA policy server FQDN '$PolicyServer' is already configured on '$($Entry.Name)'. Provide a different name.", $True)
               
                        # Empty policy server string and start over
                        $LoggerFunctions.Debug("Emptying PolicyServer variable and starting over.")
                        $PolicyServer = $null 
                    }
                }   
            }
        } until (
            (-not [String]::IsNullOrEmpty($PolicyServer))
        )

        $LoggerFunctions.Debug("Service principal name $ServicePrincipalName is not already assigned to an account and is free to use.") 
        $ServicePrincipalName = "HTTP/$PolicyServer"
        $UniversalPrincipalName = "$ServicePrincipalName@$($Domain.ToUpper())"

        $EjbcaUri = "https://$PolicyServer/ejbca"

        # Alias 
        if($Alias){
            if(-not $PolicyServerAlias){
                $PolicyServerAlias = Read-HostPrompt -Message "Enter the name of the MSAE alias (case-sensitve)"
                $LoggerFunctions.Info("Setting user-provided variabele PolicyServerAlias=$($PolicyServerAlias)") 
            }
            else {
                $LoggerFunctions.Info("Using PolicyServerAlias=$($PolicyServerAlias) from configuration file.") 
            }

            $AliasUri = "$EjbcaUri/msae/CEPService?$PolicyServerAlias"
        }
        else {
            $AliasUri = $null
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
        [Parameter(Mandatory=$false)][String]$Message=$Strings.MessageServiceAccount,
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$ServiceAccount,
        [Parameter(Mandatory=$false)][Bool]$GetExisting=$true
    )

    $LoggerFunctions.Logger = "KF.Toolkit.Function.RegisterServiceAccount"
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Debug("Getting service account and building service account attributes object.")

    while($true){
    
        if([String]::IsNullOrEmpty($ServiceAccount) -or ($ToolBoxConfig.UseDefaults -eq $false)){
            $ServiceAccount = Read-HostPrompt `
                -Message $Message `
                -Default $ServiceAccount
        }

        try {

            # Query service account
            $ServiceAccountObject = Get-ADUser -Identity $ServiceAccount

            # Return existing account attributes if GetExisting switch was provided
            if($GetExisting){
                $LoggerFunctions.Info(($Strings.ObjectFound -f ("Service account", $ServiceAccount)))
                $LoggerFunctions.Debug("$ServiceAccount attributes: $($ServiceAccountObject|ConvertTo-JSON)")
                return $ServiceAccountObject

            # Return message stated account already exists and empty default variable
            } else {
                $LoggerFunctions.Info($Strings.AlreadyExists -f $ServiceAccount, $True)
                $ServiceAccount = $null
            }

        }
        # catch exception for service account not existing
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            # continue loop because account does not exist and GetExisting switch was passed
            if($GetExisting){
                $LoggerFunctions.Error($Strings.DoesNotExist -f $ServiceAccount, $True)
                $ServiceAccount = $null
            
            # return user-provided service account 
            } else {
                $LoggerFunctions.Info(($Strings.ObjectAvailable -f $ServiceAccount))
                return $ServiceAccount
            }
        } 
        catch {
            $LoggerFunctions.Exception($_)
            throw $Strings.GeneralException
        } 
    }
}

function Register-ServiceAccountPassword {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$Password,
        [Parameter(Mandatory=$false)][String]$Message="Enter the password for the MSAE service account.",
        [Parameter(Mandatory=$false)][String]$ServiceAccount,
        [Parameter(Mandatory=$false)][Boolean]$Validate=$false,
        [Parameter(Mandatory=$false)][Switch]$SecureString
    )
    $LoggerFunctions.Logger = "KF.Toolkit.Function.RegisterServicePassword"
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)
    $LoggerFunctions.Debug("Testing password for service account: $ServiceAccount.")

    while($true){
        try {

            if([String]::IsNullOrEmpty($Password) -or ($ToolBoxConfig.UseDefaults -eq $false)){
                $Password = Read-HostPrompt `
                    -Message $Message `
                    -Default $Password
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

function Register-AutoenrollComputerSecurityGroup{
    param(
        [Parameter(Mandatory)][AllowEmptyString()][String]$SecurityGroup,
        [Parameter(Mandatory=$false)][String]$Message="Enter the name for the Security Group to add to the certificate template with autoenrollment permissions.",
        [Parameter(Mandatory=$false)][Switch]$Validate
    )
    $LoggerFunctions.Logger = "KF.Toolkit.Function.RegisterAutoenrollComputerSecurityGroup"
    $LoggerFunctions.Level($ToolBoxConfig.LogLevel)

    while($true){
        try {

            if([String]::IsNullOrEmpty($SecurityGroup) -or ($ToolBoxConfig.UseDefaults -eq $false)){
                $SecurityGroup = Read-HostPrompt `
                    -Message $Message `
                    -Default $SecurityGroup
            }

            if($SecurityGroup){
                if($Validate){
                    Get-ADGroup -Identity $SecurityGroup | Out-Null
                    $LoggerFunctions.Info(($Strings.ObjectFound -f ("security group",$SecurityGroup)))
                }
                return $SecurityGroup
            }
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            $LoggerFunctions.Error(($Strings.DoesNotExist -f ("Security group",$SecurityGroup)), $True)
            $SecurityGroup = $null
        } 
        catch {
            Write-Host $_ -ForegroundColor Red
        } 
    }  
}