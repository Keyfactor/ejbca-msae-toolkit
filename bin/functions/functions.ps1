<#
Description:
All functions required by the MSAE-Toolkit are maintained on this page

Notes:
- Organized into regions for easier management
- Each function contains its "logger" used by the WriteLog function
    - Mandatory parameter for WriteLog
    - When creating a new function, create a new logger based off the name of the function
    - This allows easier identification in the logs for the source of an error or debug

Change log:
Author              Date            Notes
Jamie Garner        9.14.22         Created initial functions
#>

function Build-CaCertChain {
    <# validate a ca cert using a provided certificate
    author: jamie garner
    created: 9.19.22
    last updated: 9.19.22
    #> 
        [CmdletBinding()]
        Param (
        [Parameter(Mandatory=$True)]
        [string]$Cert,
    
        [Parameter(ParameterSetName="import")]
        [switch]$ImportFromFile,
    
        [Parameter(ParameterSetName="download")]
        [switch]$DownloadFromAIA,
    
        [Parameter(ParameterSetName="download", Mandatory=$True)]
        [string]$CertOutDir
        )
    
        try { 
    
            # build psobect for storing values
            $Results = New-Object PSCustomObject
    
            $CertStats = Get-EjbcaCertStats -Cert $Cert -InputFormat File
            if($CertStats.FriendlyName -eq ""){
                Write-Error -Message "The certificate chain object failed to build" -Exception ([System.NullReferenceException]::new()) -ErrorAction Stop}
                else {if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile build.ejbca.certchain "Successfully constructed the X509Certificate chain object for provided certificate"
                WriteLog DEBUG $LogFile validate.ejbca.certchain $CertStats | fl
            }}
    
            # construct cert name
            $CertName = ($CertStats.Subject.Substring(0,$CertStats.Subject.IndexOf(','))).Substring($CertStats.Subject.IndexOf('=')+1)
            WriteLog INFO $LogFile build.ejbca.certchain "$CertName is the certificate provided for chain validation"
    
            # construct issuer name
            $CaCertName = ($CertStats.Issuer.Substring(0,$CertStats.Issuer.IndexOf(','))).Substring($CertStats.Issuer.IndexOf('=')+1)
    
            $Results | Add-Member -NotePropertyName Name -NotePropertyValue $CaCertName
    
            # build variable with status of certificate store
            $CaCertStoreStatus = $CertStats.IssuerInStore
            WriteLog INFO $LogFile build.ejbca.certchain "$CaCertName is the Issuer of $CertName"
    
            WriteLog INFO $LogFile build.ejbca.certchain "Checking if $CaCertName is in the certificate store..."
            # download issuing ca certificate if not in store
            if($CaCertStoreStatus -eq $false){
    
                WriteLog INFO $LogFile build.ejbca.certchain "$CaCertName is not in the local machine store..."
                Write-Host "$CaCertName is not in the local machine store..." -ForegroundColor Yellow
    
                if([switch]$DownloadFromAIA -eq $true){
    
                    WriteLog INFO $LogFile build.ejbca.certchain "Getting AIA externsion from $CertName to download $CaCertName..."
                    Write-Host "Getting AIA externsion from $CertName to download $CaCertName..." -ForegroundColor Yellow
    
                    # get aia from certificate to download issuing ca cert
                    $CertExts = Get-CertValidationExts -Cert $Cert -InputFormat File
    
                    # store aia in variable
                    $CertExtsAIA = $CertExts.AIA
    
                    WriteLog INFO $LogFile build.ejbca.certchain "Attempting to download $CaCertName from $CertExtsAIA..."
                    Write-Host "Attempting to download $CaCertName from $CertExtsAIA..." -ForegroundColor Yellow
    
                    # download certificate from aia
                    $CaCert = Get-CertFromAIA -AIA $CertExtsAIA -CertOutDir $CertOutputDir
    
                    $Results | Add-Member -NotePropertyName Cert -NotePropertyValue $CaCert.File
    
                    # store certificate file in issuing ca cert variable
                    $CaCert = $CaCert.File
    
                }
    
                else {
    
                    WriteLog INFO $LogFile build.ejbca.certchain "Getting $CaCertName from user provided file..."
                    Write-Host "Getting $IssuingCaCertName from user provided file..." -ForegroundColor Yellow
    
                    # pop-up window
                    Add-Type -AssemblyName System.Windows.Forms
                    $CaCertInput = New-Object System.Windows.Forms.OpenFileDialog
                    $CaCertInput.InitialDirectory = [Environment]::GetFolderPath('Desktop')
                    $CaCertInput.Filter = 'All files (*.*)| *.*'            
                    $CaCertInput.ShowDialog()
                    $CaCert = $CaCertInput.FileName
                    
                    # add c
                    $Results | Add-Member -NotePropertyName Cert -NotePropertyValue $CaCertInput.FileName
                    
                }
    
                # install issuing ca certificate
                Write-Host "Attempting to install $CaCertName in the local machine certificate store..." -ForegroundColor Yellow
    
                # install certificate
                $CaCertStats = Get-EjbcaCertStats -Cert $CaCert -InputFormat File
    
                if($CaCertStats.IsRootCA -eq $true){
                    $Results | Add-Member -NotePropertyName Type -NotePropertyValue "Root"
    
                    # import certificate into root store
                    Import-Certificate -FilePath $CaCert -CertStoreLocation "Cert:\LocalMachine\Root" -ErrorAction SilentlyContinue | Out-Null
    
                    $CaCertStats = Get-EjbcaCertStats -Cert $CaCert -InputFormat File
                
                    # check the intermediate ca value to confirm success
                    if($CaCertStats.CertStore -eq $true){
    
                        $Message = "Successful"
                        WriteLog INFO $LogFile build.ejbca.certchain "Successfully installed the certificate $CaCertName in the Trusted Root Certification Authorities store"                  
            
                    }
    
                    else {
    
                        $Message = "Failed"
                        Write-Error "Failed to install the certificate $CaCertName in the Trusted Root Certification Authorities store" -ErrorAction Stop
    
                    }
                }
    
                else {
    
                    $Results | Add-Member -NotePropertyName Type -NotePropertyValue "Issuing"
                    $Results | Add-Member -NotePropertyName Issuer -NotePropertyValue "$($CaCertStats.Issuer)"
    
                    # import certificate into intermediate store
                    Import-Certificate -FilePath $CaCert -CertStoreLocation "Cert:\LocalMachine\CA" -ErrorAction SilentlyContinue | Out-Null
    
                    # check store for successful  certificate
                    $CaCertStats = Get-EjbcaCertStats -Cert $CaCert -InputFormat File
    
                    # check the intermediate ca value to confirm success
                    if($CaCertStats.CertStore -eq $true){
    
                        $Message = "Successful"
                        WriteLog INFO $LogFile build.ejbca.certchain "Successfully installed the certificate $CaCertName in the Intermediate Certification Authorities store"
                
                    }
    
                    else {
    
                        $Message = "Failed"
                        Write-Error "Failed to install the certificate $CaCertName in the Intermediate Certification Authorities store" -ErrorAction Stop
    
                    }
                }
            }
    
            else {
    
                $Message = "AlreadyInstalled"
                WriteLog INFO $LogFile build.ejbca.certchain "$CaCertName is already installed in the local machine store..."
    
            }
    
            $Results | Add-Member -NotePropertyName Message -NotePropertyValue $Message
    
            # return psobject from function
            return $Results
    
        }
    
        catch {
    
            WriteLog ERROR $LogFile validate.ejbca.certchain $Error[0]
            WriteLog ERROR $LogFile validate.ejbca.certchain $Error[0].ScriptStackTrace
            
        }
    
}
function Build-FormInput {
    <# log writing built into all other functions and scripts
    author: jamie garner
    created: 9.14.22
    last updated: 9.14.22
    #> 
        [CmdletBinding()]
        Param (
    
        [Parameter(Mandatory)]
        # question 1
        [string]$Title,
    
        # question 1
        [string]$Question1,
    
        # question 2
        [string]$Question2
        )
    
        Add-Type -AssemblyName System.Windows.Forms
    
        $Form = New-Object System.Windows.Forms.Form
        $Form.Size = '500,250'
        $Form.Font = [System.Drawing.Font]::new("Times New Roman", 12)
        $Form.StartPosition = 'CenterScreen'
        $Form.Text = ('Microsoft AutoEnrollment Tool Kit')
    
        $FirstQuestion = New-Object System.Windows.Forms.Label
        $FirstQuestion.Location = [System.Drawing.Point]::new(15,20)
        $FirstQuestion.Size = [System.Drawing.Point]::new(480,20)
        $FirstQuestion.Text = $Question1
        $Form.Controls.Add($FirstQuestion)
        
        $FirstResponse = New-Object System.Windows.Forms.TextBox
        $FirstResponse.Location = [System.Drawing.Point]::new(20,50)
        $FirstResponse.Size = [System.Drawing.Point]::new(250,20)
        $Form.Controls.Add($FirstResponse)
        
        $SecondQuestion = New-Object System.Windows.Forms.label
        $SecondQuestion.Location = [System.Drawing.Point]::new(15,90)
        $SecondQuestion.Size = [System.Drawing.Point]::new(480,20)
        $SecondQuestion.Text = $Question2
        $Form.Controls.Add($SecondQuestion)
        
        $SecondResponse = New-Object System.Windows.Forms.TextBox
        $SecondResponse.Location = [System.Drawing.Point]::new(20,120)
        $SecondResponse.Size = [System.Drawing.Point]::new(250,20)
        $Form.Controls.Add($SecondResponse)
    
        $OK = New-Object System.Windows.Forms.Button
        $OK.Location = [System.Drawing.Point]::new(300,165)
        $OK.Size = [System.Drawing.Point]::new(75,30)
        $OK.Text = 'OK'
        $OK.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $Form.AcceptButton = $OK
        $Form.Controls.Add($OK)
    
        $Cancel = New-Object System.Windows.Forms.Button
        $Cancel.Location = [System.Drawing.Point]::new(390,165)
        $Cancel.Size = [System.Drawing.Point]::new(75,30)
        $Cancel.Text = 'Cancel'
        $Cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $Form.CancelButton = $Cancel
        $Form.Controls.Add($Cancel)
        
        $Result = $Form.ShowDialog()
    
        if($Result -eq [System.Windows.Forms.DialogResult]::OK){
    
             $($FirstResponse.Text)
                $Two = $($SecondResponse.Text)
                $Two
        }
    
        return $Result
}
function CreateLogFiles {
<# creates log from array when script is run
author: jamie garner
created: 9.14.22
last updated: 9.14.22
#> 
    [CmdletBinding()]
    Param (

    [Parameter(Mandatory)]
    [string[]]$Logs,

    [Parameter(Mandatory)]
    [string]$LogFileDirectory,

    [int]$LogRetention,

    [switch]$Testing

    )

    try {

        if([string]::IsNullOrEmpty($Testing)){
            # create new log directory
            $NewLogDir = New-Item "$LogFileDirectory\logs_$((Get-Date).toString('MMdd_HHmmss'))" -ItemType Directory

            if($LogRetention -gt 0){

                # get all archived folders in the log directory
                $ArchivedLogs = Get-ChildItem -Recurse "$LogFileDirectory" | Where-Object {$_.Name -match "logs_"}
                # measure length
                $ArchivedLogsLength = $ArchivedLogs.Length
                # compare it to the provided retention
                if($ArchivedLogsLength -gt $LogRetention){
                
                    # subtract values
                    $NumberToBeDeleted = $ArchivedLogsLength-$LogRetention
                    # remove files based on retention
                    $ArchivedLogs | Sort-Object LastWriteTime | Select-Object -First $NumberToBeDeleted | Remove-Item -Recurse -Force

                }
            }
        }

        else {

            $Items = Get-ChildItem -LiteralPath "$LogFileDirectory" -Recurse
            foreach ($Item in $Items) {
                $Item.Delete()
            }

        }

        # loop each item in the logfiles array
        foreach($Log in $Logs){

            if([string]::IsNullOrEmpty($Testing)){

                # check for existing file
                Test-Path "$LogFileDirectory\$Log" | Where-Object {
                    if($_ -eq $true){

                        # move log file to new directory
                        Move-Item "$LogFileDirectory\$Log" -Destination $NewLogDir
                    }
                }
            }

            # create new file in base directory
            New-Item "$LogFileDirectory\$Log" | Out-Null

            # check if file exists
            Test-Path "$LogFileDirectory\$Log" | Where-Object {

                if($_ -eq $true){

                    WriteLog INFO $LogFileToolKit logger.create.log.files "Successfully created $Log"

                }

                else {

                    # write error if it failed to create
                    Write-Error "Failed to create $($Log)"

                }
            }
        }
    }

    catch {

        Write-Error $Error[0]
    }
    
}

function Enable-Capi2 {
<# 
Enable CAPI2 logs
author: jamie garner
created: 9.19.22
last updated: 9.19.22 
#> 
    
    try {

        $LogName = 'Microsoft-Windows-CAPI2/Operational'
        $Log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $LogName
        $Log.IsEnabled = $true
        $Log.SaveChanges()

        WriteLog INFO $LogFile enable.log.capi2 "Succesfully enable the CAPI2 logs"

    }

    catch {

        WriteLog ERROR $LogFile enable.log.capi2 "Failed to enable the CAPI2 logs"
        WriteLog ERROR $LogFile enable.log.capi2 $Error[0]

    }
}
function CreateSupportBundle {
<# gets the current autoenrollment and certificate policy for the machine or user
author: jamie garner
created: 9.20.22
last updated: 9.20.22
#> 

    Param (
    [Parameter(Mandatory)]
    [string]$Directory,

    [Parameter(ValueFromPipeline)]
    [string]$SupportBundleSourceDirs

    )

    try {

        # check for existing directory and create directory if it does not exist
        Test-Path $Directory | ForEach-Object {if($_ -eq $true){Remove-Item $Directory}} -ErrorAction Stop | Out-Null

        $SupportArchive = "toolkit_bundle_" + (Get-Date).toString("MMdd_HHmm")
        # copy log directory
        $SourceDirs | ForEach-Object {Copy-Item -Include $_ -Destination $Directory -ErrorAction Stop | Out-null
        
        WriteLog INFO $LogFile new.support.bundle "Copied $_ to support bundle directory for compression" }

        # compress directory
        Compress-Archive $Directory -DestinationPath $PSScriptRoot\$SupportArchive -CompressionLevel Optimal -Force

    }

    catch {

        Writelog ERROR $LogFile new.support.bundle $Error[0]

    }
}
function GetServiceAccount {
<# get service account attribute details
author: jamie garner
created: 9.21.22
last updated: 9.21.22
#> 
    [CmdletBinding()]
    Param (

    [Parameter(Mandatory)]
    [string]$Name,

    [string]$Keytab,

    [string]$CepServer,

    [Parameter(Mandatory)]
    [ValidateSet(
        "UserPrincipalName",
        "DistinguishedName",
        "ServicePrincipalNames",
        "MemberOf",
        "KerberosEncryptionType",
        "Enabled",
        "LockedOut"
    )]
    [string[]]$Attributes

    )

    try {

        # query svc account for the provided attribue
        $AccountAttributes =  Get-ADUser $Name -Properties *

        # build spn variable from provided cep server param
        $CepServerSPN = "HTTP/$CepServer"

        # intializ properties array
        $Result = New-Object PSCustomObject

        foreach($Attribute in $Attributes){

            if($Attribute -eq "UserPrincipalName"){

                $UserPrincipalName = $AccountAttributes.UserPrincipalName
                $Result | Add-Member -NotePropertyName 'UserPrincipalName' -NotePropertyValue $UserPrincipalName
                #$Result += [PSCustomObject] @{UserPrincipalName = $UserPrincipalName}

            }

            if($Attribute -eq "DistinguishedName"){

                    $DistinguishedName = $AccountAttributes.DistinguishedName
                    $Result | Add-Member -NotePropertyName 'DistinguishedName' -NotePropertyValue $DistinguishedName
                    #$Result += [PSCustomObject] @{DistinguishedName = $DistinguishedName}

                }

            if($Attribute -eq "ServicePrincipalNames"){

                    if([string]::IsNullOrEmpty($AccountAttributes.ServicePrincipalNames)){

                        # store null value in psobject
                        $ServicePrincipalNames = $null
                        WriteLog INFO $LogFileToolKit get.service.account "'$Name' DOES NOT contain any Service Principal Name(s)"

                    }

                    else {

                        # update psobject get spn and split on space if more than one
                        $ServicePrincipalNames = foreach($spn in $AccountAttributes.ServicePrincipalNames){

                            # split on space
                            ($spn -split " ").Trim()

                        }

                        $Result | Add-Member -NotePropertyName 'ServicePrincipalNames' -NotePropertyValue $ServicePrincipalNames

                        WriteLog INFO $LogFileToolKit get.service.account "$Name contains the following the Service Principal Name(s): $ServicePrincipalNames"

                        # logging - if svcAccountSPN variable is null
                        if([string]::IsNullOrEmpty($ServicePrincipalNames) -eq $false){

                            if($logLevel -eq 'DEBUG'){WriteLog DEBUG $LogFileToolKit get.service.account "Successfully looped the $Name Service Principal Name(s)"}
                        } else { 

                            # throw ERROR $logFile if the variable is null and write to log
                            Write-Error "Failed to store the $Name service principal name(s) in the svcAccountSPN variable" -Exception ([System.NullReferenceException]::new()) -ErrorAction Stop

                        }
                    }

                    # check if spn was povided
                    if([string]::IsNullOrEmpty($CepServer) -ne $true){

                        # check for account that already contains spn
                        $Search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
                        $Search.filter = "(servicePrincipalName=*)"
                        $SearchResults = $Search.Findall()
                        foreach($Result in $SearchResults){
                            $Entry = $Result.GetDirectoryEntry()

                            if(($($Entry.servicePrincipalName) -eq $Spn) -and ($($Entry.Name) -ne $Name)){

                                $Result | Add-Member -NotePropertyName 'SpnAlreadyExists' -NotePropertyValue $true 
                                $Result | Add-Member -NotePropertyName 'SpnAlreadyExistsAccount' -NotePropertyValue $($ExistingSPNAccount.Name)

                                WriteLog WARN $LogFileToolKit get.service.account "'$CepServerSPN' is already assigned to '$($ExistingSPNAccount.Name)'"
                            }
                        }
                    }
                }

            if($Attribute -eq "MemberOf"){

                    $SecurityGroups = $AccountAttributes.MemberOf

                }

            if($Attribute -eq "KerberosEncryptionType"){

                    $SupportedKerbTypes = $AccountAttributes.DistinguishedName


                }

            if($Attribute -eq "Enabled"){

                    $Enabled = $AccountAttributes.Enabled
                    WriteLog INFO $LogFileToolKit get.service.account "The 'enabled' status of $Name if currently: $Enabled"
                    $Result | Add-Member -NotePropertyName 'Enabled' -NotePropertyValue $Enabled

                }

            if($Attribute -eq "Lockedout"){

                    $LockedOut = $AccountAttributes.Lockedout
                    WriteLog INFO $LogFileToolKit get.service.account "The 'locked out' status of $Name if currently: $LockedOut"
                    $Result | Add-Member -NotePropertyName 'Locked' -NotePropertyValue $LockedOut

            }
        }

        # write to log only if DEBUG $logFile is enabled
        if($logLevel -eq 'DEBUG'){WriteLog DEBUG $LogFileToolKit get.service.account "Returning the following attributes for $Name to the user: $Result"}

        # return result
        return $Result
    }

    # catch failed query
    catch [System.NullReferenceException]{

        WriteLog ERROR $LogFileToolKit get.service.account $($_.Exception.Message)
        return $($_.Exception.Message)

    }    
    # catch account not found
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{

        WriteLog ERROR $LogFileToolKit get.service.account "The provided service account '$Name' could not be located in Active Directory."
        return "AccountNotFound"
        
    }
    #catch all other errors
    catch {

        WriteLog ERROR $LogFileToolKit get.service.account $($_.Exception.Message)
        return $($_.Exception.Message)
    }
    
}
function Get-AutoEnrollPolicy {
<# gets the current autoenrollment and certificate policy for the machine or user
author: jamie garner
created: 9.14.22
last updated: 9.14.22
#> 

    Param (
    [string]$Scope,

    [Parameter(Mandatory)]
    [string]$Context
    )

    try {

        # initialize ps objects
        $AutoEnrollPolicyAppliedObject = @()
        $PolicyServersAppliedObject = @()

        <# get autoenroll policy #>
        $AutoEnrollPolicyApplied = Get-CertificateAutoEnrollmentPolicy -Scope Applied -Context $Context
            # logging
            if($LogLevel -eq 'DEBUG'){ WriteLog DEBUG $LogFile current.autoenroll.policy "Successfully retrieved autoenrollment settings applied to this $Context by group policy" }

        <# check if autoenrollment is enabled #>
        if($AutoEnrollPolicyApplied.PolicyState -eq 'Configured'){ $Configured = $true }
        else { $Configured = $false }
            # logging
            WriteLog INFO $LogFile current.autoenroll.policy "The Autoenrollment policy applied by group policy for this $Context is currently: $Configured"
            if($LogLevel -eq 'DEBUG'){ WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'Configured' has been added to return object 'AutoEnrollPolicyAppliedObject' with value: $Configured" }

        <# check if enabletempatecheck is enabled #>
        if($AutoEnrollPolicyApplied.EnabledTemplateCheck -eq $true){ $UpdateCerts = $true }
        else { $UpdateCerts = $false }
            # logging
            WriteLog INFO $LogFile current.autoenroll.policy "'Update Certs Used By Templates' (required by MSAE) applied by group policy for this $Context is currently: $UpdateCerts"
            if($LogLevel -eq 'DEBUG'){
                # update certs
                WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'UpdateCerts' has been added to return object 'AutoEnrollPolicyAppliedObject' with value: $UpdateCerts"
                # expiration percent
                WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'ExpirationPercent' has been added to return object 'AutoEnrollPolicyAppliedObject' with value: $($AutoEnrollPolicyApplied.ExpirationPercentage)"}
        
        # create object for return to user
        $AutoEnrollPolicyAppliedObject = [PSCustomObject]@{
            Name = 'AutoEnrollment-Applied'
            Configured = $Configured
            UpdateCerts = $UpdateCerts
            ExpirationPercent = [int]$AutoEnrollPolicyApplied.ExpirationPercentage
        }                

        <# enrollment policy server - gpo - ldap #>
        Get-CertificateEnrollmentPolicyServer -Scope Applied -Context $Context | where {($_.Length -ne '0')} | foreach {
            # logging
            if($LogLevel -eq 'DEBUG'){
                WriteLog DEBUG $LogFile current.autoenroll.policy "Starting loop on autoenrollment policy server applied to $Context by group policy"}
        
        <# check if policy is ldap or user defined is configured #>
        if($_.Url -match 'ldap:'){$Type = 'CEP-Applied-LDAP'; $PolicyServerName = 'LDAP'}
        if($_.Url -match '/ejbca/msae'){$Type = 'CEP-Applied-UserDefined'; $PolicyServerName = [Convert]::ToString($_.Url)
        $PolicyServerName = $UriToString.Substring($UriToString.LastIndexOf('?')+1)}
            # logging
            WriteLog INFO $LogFile current.autoenroll.policy "The 'Friendly Name' of this Autoenrollment policy server applied by group policy to this $Context is currently: $PolicyServerName"
            WriteLog INFO $LogFile current.autoenroll.policy "The 'Type' of this Autoenrollment policy server applied by group policy to this $Context is currently: $Type"
            WriteLog INFO $LogFile current.autoenroll.policy "The URL of autoenrollment policy server applied by group policy to this $Context is currently: $($_.Url)"
            if($LogLevel -eq 'DEBUG'){
                WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'Type' has been added to return object 'PolicyServersAppliedObject' with value: $Typed"
                WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'URL' has been added to return object 'PolicyServersAppliedObject' with value: $($_.Url) "}

        <# check if policy uses an msae alias #>
        if($_.Url -match 'ADPolicyProvider_CEP_Kerberos'){$MSAECep = $true}
        else {$MSAECep = $false}
            # logging
            WriteLog INFO $LogFile current.autoenroll.policy "The autoenrollment policy server applied by group policy to this $Context is configured with an EJBCA MSAE endpoint: $MSAECep"
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'CepGpoConfigured' has been added to return object 'PolicyServersAppliedObject' with value:  $CepGpoConfigured"}

        <# check if policy gpo is configured #>
        if($_.Priority -ne '-1'){$CepGpoConfigured = 'Enabled'}
        else {$CepGpoConfigured = 'NotConfigured'}
            # logging
            WriteLog INFO $LogFile current.autoenroll.policy "The 'Certificate Services Client - Certificate Enrollment Policy' GPO onfiguration status applied to this $Context is currently: $CepGpoConfigured"
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'CepGpoConfigured' has been added to return object 'PolicyServersAppliedObject' with value:  $CepGpoConfigured"}

        <# check if policy is enabled #>
        if($_.AutoEnrollmentEnabled -eq $true){$AutoEnrollEnabled = $true}
        else {$AutoEnrollEnabled = $false}
            # logging
            WriteLog INFO $LogFile current.autoenroll.policy "The default LDAP autoenrollment policy server setting 'Automatic Enrollment' applied by group policy to this $Context is currently: $AutoEnrollEnabled"
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'AutoEnrollmentEnabled' has been added to return object 'PolicyServersAppliedObject' with value:  $AutoEnrollEnabled"}

        <# check if policy the default policy #>
        if($_.IsDefault -eq $true){$DefaultPolicy = $true}
        else {$DefaultPolicy = $false}
            # logging
            WriteLog INFO $LogFile current.autoenroll.policy "The default LDAP autoenrollment policy server setting 'DefaultPolicy'applied by group policy to this $Context is currently: $DefaultPolicy"
            if($LogLevel -eq 'DEBUG'){ WriteLog DEBUG $LogFile current.autoenroll.policy "Property value 'DefaultPolicy' has been added to return object 'PolicyServersAppliedObject' with value: $DefaultPolicy" }

        $cepServers = [ordered]@{
            Type = $Type
            FriendlyName = $PolicyServerName
            URL = $_.Url
            MSAEAlias = $MSAECep
            CEPGpoConfigured = $CepGpoConfigured
            AutoEnrollmentEnabled = $AutoEnrollEnabled
            DefaultPolicy = $DefaultPolicy
        }

        $PolicyServersAppliedObject += @(New-Object psobject -Property $cepServers)

    }

        return $AutoEnrollPolicyAppliedObject, $PolicyServersAppliedObject

    }

    catch {

        $ErrorMessage = ($Error[0]).ToString()
        $ErrorMessageScriptStackTrace = $Error[0].ScriptStackTrace -split [Environment]::NewLine
        foreach($line in $ErrorMessageScriptStackTrace){
            WriteLog ERROR $LogFile get.ejbca.certstats ($ErrorMessage + $line)}

    }
}
function Get-CertStats {
<# 
Gets the chain and trust store an ejbca certificate as input and build ps object using with values useful to the toolkit
author: jamie garner
created: 9.14.22
last updated: 9.14.22 
#> 
    [CmdletBinding()]
    param(
    
    # get certificate path from pipeline or value
    [Parameter(Mandatory)]
    [String]$Cert,

    [Parameter(Mandatory)]
    [ValidateSet('File','String')]
    [string]$InputFormat = 'File',

    [string]$Attribute
    )

    try {

        # build psobect for storing values
        $CertProps = New-Object PSCustomObject

        # build x509 certifcate object for attributes if cert is from file
        $Crt = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($Cert)
        if([string]::IsNullOrEmpty($Crt)){
            Write-Error -Message "The certificate chain object failed to build" -Exception ([System.NullReferenceException]::new()) -ErrorAction Stop}
            else {if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.cert.stats " Successfully constructed the X509Certificate chain object for provided certificate"}}
        
        # contstruct cert name
        $CrtName = ($Crt.Subject.Substring(0,$Crt.Subject.IndexOf(','))).Substring($Crt.Subject.IndexOf('=')+1)
            WriteLog INFO $LogFile get.ejbca.certstats "$CrtName is the certificate provided for stat gathering"

        # add commmon cert properties to table
        $CertProps | Add-Member -NotePropertyName FriendlyName -NotePropertyValue $CrtName
        $CertProps | Add-Member -NotePropertyName Subject -NotePropertyValue $Crt.Subject
        $CertProps | Add-Member -NotePropertyName Issuer -NotePropertyValue $Crt.Issuer
        $CertProps | Add-Member -NotePropertyName Thumbprint -NotePropertyValue $Crt.Thumbprint
            # WriteLog INFO $LogFile get.ejbca.certstats "The Subject is: $($Crt.Subject)"
            # WriteLog INFO $LogFile get.ejbca.certstats "The Issuer is: $($Crt.Issuer)"
            # WriteLog INFO $LogFile get.ejbca.certstats "The Thumbprint is: $($Crt.Thumbprint)"

        # check the cert type
        if($Crt.Extensions.CertificateAuthority -eq $true){
            $CertType = 'CA'
            $CertProps | Add-Member -NotePropertyName CertType -NotePropertyValue $CertType

            # check if ca cert is a root cert
            if($Crt.Subject -eq $Crt.Issuer){
                $CertIsRootCA = $true
                $CertProps | Add-Member -NotePropertyName IsRootCA -NotePropertyValue $CertIsRootCA

                # check root store for certificate
                $CertStore = Get-ChildItem -Path Cert:\LocalMachine\Root | where {($_.Thumbprint -eq $crt.Thumbprint)}
                if([string]::IsNullOrEmpty($CertStore)){$CertStore = $false}
                else {$CertStore = $true} 

                $CertProps | Add-Member -NotePropertyName CertStore -NotePropertyValue $CertStore

            } else {

                $CertIsRootCA = $false
                $CertProps | Add-Member -NotePropertyName IsRootCA -NotePropertyValue $CertIsRootCA

                # check intermediate store for certificate
                $CertStore = Get-ChildItem -Path Cert:\LocalMachine\CA | where {($_.Thumbprint -eq $crt.Thumbprint)}
                if([string]::IsNullOrEmpty($CertStore)){$CertStore = $false} 
                else {$CertStore = $true}

                $CertProps | Add-Member -NotePropertyName CertStore -NotePropertyValue $CertStore

                # check if issuer is in cert store
                $CertStore = Get-ChildItem -Path Cert:\LocalMachine\Root | where {($_.Subject -eq $Crt.Issuer)}
                if([string]::IsNullOrEmpty($CertStore)){$CertIssuerInStore = $false} 
                else {$CertStore = $true}

                $CertProps | Add-Member -NotePropertyName IssuerInStore -NotePropertyValue $CertIssuerInStore
            }

            

        } else {

            $CertType = 'TLS Server'
            $CertProps | Add-Member -NotePropertyName CertType -NotePropertyValue $CertType
            $CertStore = Get-ChildItem -Path Cert:\LocalMachine\CA | where {($_.Subject -eq $Crt.Issuer)}
            if([string]::IsNullOrEmpty($CertStore)){$CertIssuerInStore = $false}
            else {$CertStore = $true}

            $CertProps | Add-Member -NotePropertyName IssuerInStore -NotePropertyValue $CertIssuerInStore

        }

        if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.cert.stats "Returning the following properties $($CertProps)"}
        # return psobject from function
        return $CertProps

    }
    
    catch [System.IO.FileNotFoundException]{

        $ErrorMessage = ($Error[0]).ToString()
        $ErrorMessageScriptStackTrace = $Error[0].ScriptStackTrace -split [Environment]::NewLine
        foreach($line in $ErrorMessageScriptStackTrace){
            WriteLog ERROR $LogFile get.cert.stats ($ErrorMessage + $line)}
    }

    catch {

        $ErrorMessage = ($Error[0]).ToString()
        $ErrorMessageScriptStackTrace = $Error[0].ScriptStackTrace -split [Environment]::NewLine
        foreach($line in $ErrorMessageScriptStackTrace){
            WriteLog ERROR $LogFile get.cert.stats ($ErrorMessage + $line)}

    }
}
function Get-CertChainStatus {
<# get trusted root provider status on cert
author: jamie garner
created: 9.19.22
last updated: 9.19.22
#> 
    [CmdletBinding()]
    Param (
    [Parameter(Mandatory=$True)]
    [string]$Cert
    )

    try {

        # build x509 certifcate object for attributes if cert is from file
        $Crt = New-Object System.Security.Cryptography.X509Certificates.X509Chain
        $Crt.Build($Cert) | Out-Null
        if([string]::IsNullOrEmpty($Crt.ChainStatus)){
            Write-Error -Message "The certificate chain object failed to build" -Exception ([System.NullReferenceException]::new()) -ErrorAction Stop}
            else {if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile  get.cert.chainstatus "Successfully constructed the X509Certificate chain object for provided certificate"}}

        $CertChainStatus = $Crt.ChainStatus | select Status | where {($_.Status -eq "PartialChain")}
        if([string]::IsNullOrEmpty($CertChainStatus)){
        
                $TrustedChain = $true
                WriteLog INFO $LogFile  get.cert.chainstatus "The certificate chain for the certificate file $Cert is completely trusted on this machine"
        
                # return status
                return $TrustedChain
        
        }
    }

    catch {

        WriteLog ERROR $LogFile get.cert.chainstatus $Error[0]

    }
}
function Get-CertValidationExts {
    <# Get aia and cdp urls from a certificate
    - Accepts both a certificate from file and a certificate from string
    author: jamie garner
    created: 9.15.22
    last updated: 9.15.22
    #> 
        [CmdletBinding()]
        param(
    
        # pass certificate file
        [Parameter(Mandatory)]
        [String]$Cert,
    
        # pass certificate file
        [ValidateSet("File","String")]
        [String]$InputFormat = 'File'
    
        )
    
        try {
        
            # dump cert
            $CertContent = $(certutil $Cert) -split [Environment]::NewLine         
            $CertContent | foreach {
                if($_ -eq "CertUtil: The system cannot find the file specified."){
                    Write-Host $_
                    Write-Error -Message "The provided certificate file cannot be found" -Exception ([System.IO.FileNotFoundException]::new()) -ErrorAction Stop
                }
            }
    
            # logging
            WriteLog INFO $LogFile get.certvalidation.exts "Dumped the contents of $CertFileName to get the CDP and AIA"
    
            # remove temporary cert
            if($BaseType -eq 'String'){ 
                Remove-Item $TempCertPath -ErrorAction Stop
                    WriteLog INFO $LogFile get.certvalidation.exts "Deleted temporary certificate file: $Cert"
            }
    
            # create counter for loop based on cert dump length
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.certvalidation.exts "Started loop looking for the AIA and CDP extensions..."}
            for ($x = 0; $x -lt $CertContent.Count; $x++) {
    
                # set count to 0
                $line = $CertContent[$x]
        
                <# regex cdp extension #>
                if($certContent[$x] -match "(1.3.6.1.5.5.7.1.1)+"){
                    if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.certvalidation.exts "Found the Authority Information Access extension identified by: (1.3.6.1.5.5.7.1.1)"}
    
                    # continue loop until a blank line is found
                    while($line -ne ""){
    
                        # regex aia in line to get url
                        if($line -match ".*AIA*") {
                            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.certvalidation.exts "Found the Certification Authority Issuer URL identified by: AIA"}
    
                            # clean up aia
                            $CertAIA = $line.Substring($line.IndexOf('=')+1)
                                WriteLog INFO $LogFile get.certvalidation.exts "The AIA to download the Issuing CA certificate is $CertAIA"
                                if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.certvalidation.exts "Property value 'AIA' has been added to return object with the value: $CertAIA"}
    
                        }
                        # continue until total count of CertContent lines are completed
                        $line = $CertContent[$x++]
    
                    }
                }
    
                # reset count to 0
                $line = $CertContent[$x]
    
                <# regex cdp extension #>
                if($CertContent[$x] -match "(2.5.29.31)+"){
                    if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.certvalidation.exts "Found the CRL Distribution Points extension identified by: (2.5.29.31)"}
    
                    # continue loop until a blank line is found
                    while($line -ne ""){
    
                        # regex cdp in line to get url
                        if($line -match ".*URL*"){
                            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.certvalidation.exts "Found the CRL Distribution Point identified by: URL"}
    
                            # clean up url
                            $CertCDP = $line.Substring($line.IndexOf('=')+1)
                                WriteLog INFO $LogFile get.certvalidation.exts "The CDP to download the Issuing CA CRL is $CertCDP"
                                if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.certvalidation.exts "Property value 'CDP' has been added to return object with the value: $CertCDP"}
    
                        }
                        # continue until total count of CertContent lines are completed
                        $line = $CertContent[$x++]
    
                    }
                }
    
                # store variables into certificate object
                $CertExts = [PSCustomObject]@{
                    AIA = $CertAIA
                    CDP = $CertCDP
                
                }
    
                # end loop with continue statement
                continue
    
            }
    
            return $CertExts
    
        }
        catch [System.IO.FileNotFoundException] {
    
            $ErrorMessage = ($Error[0]).ToString()
            $ErrorMessageScriptStackTrace = $Error[0].ScriptStackTrace -split [Environment]::NewLine
            foreach($line in $ErrorMessageScriptStackTrace){
                WriteLog ERROR $LogFile get.ejbca.certstats ($ErrorMessage + $line)}
    
        }
        catch {
    
            $ErrorMessage = ($Error[0]).ToString()
            $ErrorMessageScriptStackTrace = $Error[0].ScriptStackTrace -split [Environment]::NewLine
            foreach($line in $ErrorMessageScriptStackTrace){
                WriteLog ERROR $LogFile get.ejbca.certstats ($ErrorMessage + $line)}
    
        }
} 
function Get-CertSans {
<# Accepts an ejbca tls certificate as input and validates the chain and sn values
- Otputs both an X509certificate and string versions of the certificate
- The string version needs to be ouput to a file before used in certutil
author: jamie garner
created: 9.14.22
last updated: 9.14.22 
#> 

    [CmdletBinding()]
    param(
    # get url from pipeline or value
    [Parameter(Mandatory)]
    [string]$Cert,

    [Parameter(Mandatory)]
    [string]$CepServer
    )

    try {

        $Result = New-Object PSCustomObject
        # build x509 certifcate object for attributes if cert is from file
        $Crt = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($Cert)
        if([string]::IsNullOrEmpty($Crt)){
            Write-Error -Message "The certificate chain object failed to build" -Exception ([System.NullReferenceException]::new()) -ErrorAction Stop}
            else {if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.cert.sans " Successfully constructed the X509Certificate chain object for provided certificate"}}

        # contstruct cert name
        $CrtCN = ($Crt.Subject.Substring(0,$Crt.Subject.IndexOf(','))).Substring($Crt.Subject.IndexOf('=')+1)
        WriteLog INFO $LogFile get.cert.sans "$CrtCN is the certificate provided for SAN verfication"

        # loop through the SAN values and filter for a matching entry
        foreach($line in $Crt.DnsNameList){
            if($line -eq $CepServer){

            WriteLog INFO $LogFile get.cert.sans "$line was found in the $CrtCN SAN values as a DNS and matches the $CepServer"

            # add property as true
            $Result | Add-Member -NotePropertyName MatchingSAN -NotePropertyValue $true
        
            # end function and return true if found
            return $Result
        
            }
        }

        # add property as false
        $Result | Add-Member -NotePropertyName MatchingSAN -NotePropertyValue $false

        WriteLog INFO $LogFile get.cert.sans "A DNS entry matching $CepServer was not found in the $CrtCN SAN values. Checking if the CN matches..."

        # compare the CN to FQDN
        if($CrtCN -eq $CepServer){

            WriteLog INFO $LogFile get.cert.sans "$CrtCN matches the $CepServer"
            WriteLog WARN $LogFile get.cert.sans "It is recommended to use a DNS entry in the SAN for matching the CEP Server"

            # add property as true
            $Result | Add-Member -NotePropertyName MatchingCN -NotePropertyValue $true

            # end function and return true if found
            return $Result

        }

        else {

            # add propert as false
            $Result | Add-Member -NotePropertyName MatchingCN -NotePropertyValue $false

            # return false
            return $Result

            # write error
            Write-Error -Message "$CrtCN does not have a matching CN or SAN values that matches $CepServer. This will generate an INVALID_CN error message when configuring the CEP Server."
        
        }
    }

    catch {

        WriteLog ERROR $LogFile get.cert.sans $Error[0]

    }
       
}
function Get-CepCert {
<# Accepts an ejbca tls certificate as input and validates the chain and sn values
- Otputs both an X509certificate and string versions of the certificate
- The string version needs to be ouput to a file before used in certutil
author: jamie garner
created: 9.14.22
last updated: 9.14.22 
#> 
    [CmdletBinding()]
    param(
    # get url from pipeline or value
    [Parameter(Mandatory)]
    [string]$Url,

    [Parameter(Mandatory)]
    [string]$CertOutput
    )

    # http web request try/catch
    # needed to continue after catching expected tls/ssl exception in response
    try {

        # create http web request with provided url
        $Req = [Net.HttpWebRequest]::Create($Url)
        $Req.GetResponse() | Out-Null
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.cep.tlscert "Retrieved the HTTP response from $url. Response contents are: $req.GetResponse()"}     
    }
    catch [System.Net.WebException] { 
        
        WriteLog WARN $LogFile get.cep.tlscert "An exception was caught: $($_.Exception.Message)"

    }

    # build cert try/catch
    try {

        # check for empty certificate and create error if empty 
        if([string]::IsNullOrEmpty($Req.ServicePoint.Certificate)){Write-Error 'A TLS certificate was not returned in the request response' -ErrorAction Stop}

        # store raw cert data into variable for conversion
        $RawCertData = $Req.ServicePoint.Certificate.GetRawCertData()
        # convert raw data to base64 string
        $CertString = [Convert]::ToBase64String($RawCertData)
        $CertString | Out-File $CertOutput -ErrorAction Stop
        # build certificate object
        $CertObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        # import certificate string
        $CertObject.Import([Convert]::FromBase64String($CertString))
        # contstruct cert name
        $CertName = ($CertObject.Subject.Substring(0,$CertObject.Subject.IndexOf(','))).Substring($CertObject.Subject.IndexOf('=')+1)
        WriteLog INFO $LogFile get.cep.tlscert "$CertName is the CEP downloaded for validation"

            #logging
            WriteLog INFO $LogFile get.cep.tlscert "Created new certificate object from request response"
            #if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile get.cep.tlscert "Created the following certificate string from raw cert data in request response: $CertString"}
        
        $Result = [pscustomobject] @{
            Name = $CertName
            Object = $CertObject
            String = $CertString
            }

        return $Result


    }
    catch {

        WriteLog ERROR $LogFile get.cep.tlscert $Error[0]

    }

}
function Get-CertFromAIA {
<# Download and install certificate in certstore from AIA extension
author: jamie garner
created: 9.14.22
last updated: 9.14.22
#> 

    [CmdletBinding()]
    Param (

    [Parameter(Mandatory=$True)]
    [string]$AIA,

    [Parameter(Mandatory=$True)]
    [object]$CertOutDir
    )


    try{

        # create pingable hostname from the provided aia
        $AIAFqdn = $AIA.Replace('http://',"")
        $AIAFqdn = $AIAFqdn.Substring(0,$AIAFqdn.IndexOf('/'))
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile download.cert.fromaia "Create the pingable hostname $AIAFqdn from $AIA"}
        # create certificate name fom aia
        $CertName = $AIA.Substring($AIA.LastIndexOf('/')+1)
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile download.cert.fromaia "Certificate being downloaded will be saved as $CertName"}

        # look for dns record of aia server
        Resolve-DnsName $AIAFqdn -ErrorAction Stop | Out-Null
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile download.cert.fromaia "A DNS record exists for $AIAFqdn"}

        # test port 80 of aia server
        Test-RemoteServerPort $AIAFqdn -ErrorAction Stop | Out-Null
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFile download.cert.fromaia "$AIAFqdn is reachable over port 80"}
        
        # create output file variable
        $CertFilePath = "$CertOutDir$CertName"

        # try to download crt from aia
        $Result = Invoke-WebRequest $AIA 
        
        $str = $Result.RawContent -split [environment]::NewLine
        $ContentType = foreach($line in $str){
            if($line -match 'Content-Type'){

            ($line.Substring($line.IndexOf("/")+1))

            }
        }

        if($ContentType -ne "pkix-cert"){

            $Status = 'Failed'
            return $Status 
            $ErrorMessage = "The AIA in the certificate does not point to a certificate file and HTML is being returned instead."
            Write-Error $ErrorMessage -ErrorAction Stop

        }

        else {

            $Result = Invoke-WebRequest $AIA -OutFile $CertFilePath

        }

        if($Result.StatusCode -eq "200"){
            if($Result.StatusDescription -eq "No Content"){

                $Status = 'Failed'
                $ErrorMessage = "The AIA endpoint was reachable but there was no certificate available to download. Verify with a web browser the AIA from the certificate downloads a file"
                Write-Error $ErrorMessage -ErrorAction Stop

            return $ErrorMessage

            }

            # check for a succesfull download of certificate
            if($Result.StatusDescription -eq "OK"){

                $Status = 'Success'
                $SuccessMessage = "Successfully downloaded $CertName from $AIAFqdn is reachable over port 80"
                WriteLog INFO $LogFile download.cert.fromaia  $SuccessMessage

            }
        }

        $Result = [pscustomobject]@{
            Status = $Status
            File = $CertFilePath
            }

        return $Result

    }
    
    catch {

        WriteLog ERROR $LogFile download.cert.fromaia $Error[0]

    }

}
function Install-EjbcaCert {
<# Download and install certificate in certstore from AIA extension
author: jamie garner
created: 9.14.22
last updated: 9.14.22
#> 

    [CmdletBinding()]
    Param (

    [Parameter(Mandatory=$True)]
    [string]$Cert

    )


    try{
    
        # install certificate
        $CertStats = Get-EjbcaCertStats -Cert $Cert -InputFormat File
        if($CertStats.IsRootCA -eq $true){

            # import certificate into root store
            Import-Certificate -FilePath $Cert -CertStoreLocation "Cert:\LocalMachine\Root" -ErrorAction SilentlyContinue | Out-Null
           
            # check the intermediate ca value to confirm success
            if($CertStats.CertStore -eq $true){

                $SuccessMessage = "Successfully installed the certificate $($CertStats.Subject) in the Trusted Root Certification Authorities store"
                WriteLog INFO $LogFile install.ejbca.cert $SuccessMessage

                return $SuccessMessage
    
            }

            else {

                $ErrorMessage = "Failed to install the certificate $($CertStats.Subject) in the Trusted Root Certification Authorities store"
                Write-Error $ErrorMessage -ErrorAction Stop

                return $ErrorMessage 

            }
        }

        else {

            # import certificate into intermediate store
            Import-Certificate -FilePath $Cert -CertStoreLocation "Cert:\LocalMachine\CA" -ErrorAction SilentlyContinue | Out-Null

            # check store for successful  certificate
            $CertStats = Get-EjbcaCertStats -Cert $Cert -InputFormat File

            # check the intermediate ca value to confirm success
            if($CertStats.CertStore -eq $true){

                WriteLog INFO $LogFile install.ejbca.cert "Successfully installed the certificate $($CertStats.Subject) in the Intermediate Certification Authorities store"

                return "Successful"
        
            }

            else {

                $ErrorMessage = "Failed to install the certificate $($CertStats.Subject) in the Intermediate Certification Authorities store"
                Write-Error $ErrorMessage -ErrorAction Stop

                return "Failed"

            }
        }
    }
        
    catch {

        WriteLog ERROR $LogFile install.ejbca.cert $Error[0]

    }

}
function SearchForestSpn{
<# search for an SPN current assigned to an account in AD
author: jamie garner
created: 9.27.22
last updated: 9.27.22
#> 
    [CmdletBinding()]
    Param (

    [Parameter(Mandatory)]
    [string]$Spn

    )

    try {

        # check for account that already contains spn
        $Search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
        $Search.filter = "(servicePrincipalName=*)"
        $SearchResults = $Search.Findall()

        foreach($Result in $SearchResults){
            $Entry = $Result.GetDirectoryEntry()

            if(($($Entry.servicePrincipalName) -eq $Spn) -and ($($Entry.Name) -ne $Name)){

                $Result | Add-Member -NotePropertyName 'SpnAlreadyExists' -NotePropertyValue $true 
                $Result | Add-Member -NotePropertyName 'SpnAlreadyExistsAccount' -NotePropertyValue $($ExistingSPNAccount.Name)

                WriteLog WARN $LogFileToolKit get.service.account "'$CepServerSPN' is already assigned to '$($ExistingSPNAccount.Name)'"

                    $Results = [PSCustomObject]@{
                        Exists = $true
                        Account = $($ExistingSPNAccount.Name)
                    }

                return $Results

            }

            else {

                WriteLog INFO $LogFileToolKit search.forest.spn "'$Spn' is not already assigned to an account in $(((Get-ADDomain).Forest))"
                return $false

            }
        }
    }

    catch {

        WriteLog ERROR $LogFileToolKit search.forest.spn  "'$Spn' is already assigned to '$($ExistingSPNAccount.Name)'"
    }

}
function SearchForOrgUnit {
<# search active directory with or without a user provided ou
author: jamie garner
created: 9.22.22
last updated: 9.22.22
#> 

    [CmdletBinding()]
    Param (

    [string]$Name

    # [Parameter(Mandatory=$true)]
    # [bool]$UserProvidedName

    )

    try {

        # enter loop to make sure valid ou name is provided
        if($logLevel -eq 'DEBUG'){WriteLog DEBUG $LogFileToolKit search.ad.orgunit "Entering CreateSvcAccountOU loop..."}

        # query active directory
        $OUResults = Get-ADOrganizationalUnit -Filter "Name -like '*$Name*'" | Select-Object Name,DistinguishedName

        # if matching string could not be found in AD
        if([string]::IsNullOrEmpty($OUResults)){

            return "No OUs could be found that match the provided string"

        }

        else {

            # write the found objects to the log
            foreach($item in $CreateSvcAccountOUObject){

                WriteLog INFO $LogFileToolKit search.ad.orgunit "$($item.DistinguishedName) was found in ActiveDirectory"

            }
        }

        if($logLevel -eq 'DEBUG'){WriteLog DEBUG $LogFileToolKit create.service.account "CreateSvcAccountOU loop exited"}

        # if multiple ous with the provided name exist
        if($OUResults.Name.Count -gt 1){

            # initialize empty object
            $OuPsObject = @()

            # loop each item and add selection number to each
            $OUResults | ForEach-Object {$Selection = 0}{

                $OuPsObject += [PSCustomObject] @{Selection = $Selection; DN = $_.DistinguishedName};$Selection++
        
            }

            # return dn to user
            return $OuPsObject
        }
    }

    catch {

        WriteLog ERROR $LogFileToolKit search.ad.orgunit $Error[0] 
    }
}
function UserInputPrompt {
<# shows and message box or read host prompt for user
author: jamie garner
created: 9.19.22
last updated: 9.19.22
#> 
    [CmdletBinding()]
    Param (

    [Parameter(Mandatory=$True)]
    [string]$Title,

    [Parameter(Mandatory=$True)]
    [string]$Prompt,

    [switch]$NoInputRequired
    )

    try { 

        do {
    
            # use if windows forms is turned on
            if($WindowsForms -eq $true){
    
                $Result=[Microsoft.VisualBasic.Interaction]::InputBox("$Prompt,$Title")
    
                # exit script because a name wasnt entered
                if([string]::IsNullOrEmpty($Result)){
    
                    # inform user they did not input anything
                    Write-Host "Input was not provided. Please provide input to continue..." -ForegroundColor Yellow
            
                }
                # user exited the message box
                if($Result -match "Cancel"){
    
                    Write-Host "You cancelled the $Title input box and the script will now exit..." -ForegroundColor Red
                    WriteLog INFO $LogFileToolKit logger.toolkit.prompt "User closed the $Title input box and the script exited"

                    # wait before closing script
                    Start-Sleep -Seconds 2
                    Exit
    
                }
                else {

                    Write-Host "You have entered '$Result' as the $Title..." -ForegroundColor Green
                    WriteLog INFO $LogFileToolKit logger.toolkit.prompt "User provided '$Result' as the $Title"
                    return $Result
    
                }
            }
            # use if forms is turned off
            else {
    
                if($NoInputRequired -eq $true){

                    Write-Host "$Prompt Hit enter to continue..." -ForegroundColor Blue
                    $Result = Read-Host

                }
                else{

                    Write-Host "$Prompt to continue..." -ForegroundColor Cyan
                    $Result = Read-Host 

                }

                # exit script is NO was selected
                if([string]::IsNullOrEmpty($Result) -or $NoInputRequired -eq $true){

                    # inform user they did not input anything
                    Write-Host "Input was not provided. Please provide input to continue..." -ForegroundColor Yellow
    
                }

                else {
    
                    if($NoInputRequired -eq $false){

                        WriteLog INFO $LogFileToolKit logger.toolkit.prompt "User provided '$Result' as the $Title"
                    }

                    else {

                        WriteLog INFO $LogFileToolKit logger.toolkit.prompt "User confirmed to proceed at the $Title prompt"

                    }

                    return $Result

                }
            }
    
        } until ([string]::IsNullOrEmpty($Result) -ne $true -or $NoInputRequired -eq $true)

    }

    catch {

        WriteLog ERROR $LogFile validate.ejbca.certchain $Error[0]
        WriteLog ERROR $LogFile validate.ejbca.certchain $Error[0].ScriptStackTrace
    }
}
function TestADUser {
<# checks if ad user exists using samaccountname and adsisearcher
author: jamie garner
created: 9.19.22
last updated: 9.19.22
#> 
    param(

      [Parameter(Mandatory = $true)]
      [String] $SamAccountName

    )

    $null -ne ([ADSISearcher] "(sAMAccountName=$sAMAccountName)").FindOne()

}

function Test-RemoteServerPort {
<# User to test server connections over specified ports with a timeout
author: jamie garner
created: 9.14.22
last updated: 9.14.22
#> 
    [CmdletBinding()]
    Param (

    [Parameter(Mandatory=$True)]
    [string]$Hostname,

    [string]$Port=80,

    [String]$Timeout=100
    )

    try {

        $RequestCallback = $state = $null
        $Client = New-Object System.Net.Sockets.TcpClient
        $beginConnect = $Client.BeginConnect($Hostname,$Port,$RequestCallback,$State)
        Start-Sleep -milli $Timeout
        if ($Client.Connected){

            $Open = $true

        }

        else{

            $Open = $false
            Write-Error -Message "$Hostname is not reachable over port $Port"
            
        }

        $client.Close()
        $result = [pscustomobject]@{
            Hostname = $Hostname
            Port = $Port
            Open = $open
        }
    }

    catch {

        WriteLog ERROR $LogFile test.server.endpoint $Error[0]

    }

    return $result

}  
function TestADPassword {
<# test user provided password requriments
author: jamie garner
created: 9.14.22
last updated: 9.14.22
#> 
    [CmdletBinding()]
    Param (

    [Parameter(Mandatory=$True)]
    [string]$Password

    )

    # check if password meets minimum length
    If($Password.Length -gt (Get-ADDefaultDomainPasswordPolicy).MinPasswordLength) {
        
        # check if password meets complexity requirements
        if ((Get-ADDefaultDomainPasswordPolicy).ComplexityEnabled -eq $true) {
            If ((($Password -cmatch "[A-Z]")) -and (($Password -cmatch "[a-z]")) -and (($Password -match "[\d]")) -and (($Password -match "!|@|#|%|^|&|$"))) { 

                return $true
            }

            else {

                return "Does not meet complexity requirements"

            }
        }
    }

    else {

        return "Password doesnt meet the minimum password length of $((Get-ADDefaultDomainPasswordPolicy).MinPasswordLength)"

    }

}
function WriteLog {
<# log writing built into all other functions and scripts
author: jamie garner
created: 9.14.22
last updated: 9.14.22
#> 
    [CmdletBinding()]
    Param (

    # log level
    [Parameter(Mandatory=$True)]
    [ValidateSet("INFO","WARN","ERROR","VALIDATION","DEBUG")]
    [string]$Level,

    # log file
    [Parameter(Mandatory=$True)]
    [string]$Log,  

    # function or form executing code
    [Parameter(Mandatory=$True)]
    [string]$Logger,

    # log message
    [Parameter(Mandatory=$True)]
    [string]$Message
    )

    # create timestamp
    $TimeStamp = (Get-Date).toString("yyyyMMdd HH:mm:ss")
    # concatenate all the parameters together into a string
    $LogMessage = "$TimeStamp $Level [$Logger] $Message"
    # add concatenated message to log file
    Add-Content $Log -Value $LogMessage
}
    




