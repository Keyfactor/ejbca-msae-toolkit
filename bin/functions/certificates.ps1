
function Build-X509Certificate {
    <#
      .Synopsis
        Builds X509 certificate object from provided value
      .Description
        Loads path to certificate file, or certificate object, and return X509Certificate object. 
        If provided certificate type is already an X509Certificate object, the object is immediately returned
      .Parameter Certificate
        System.String. File patth to certificate file
        System.Security.Cryptography.X509Certificates.X509Certificate2. Certificate object

      .OUTPUTS
        System.Security.Cryptography.X509Certificates.X509Certificate2. Returns a certificate object
    #>
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]$Certificate # no type specified so it can be either string or x509certificat2 object
    )

    process {

        $ParameterType = $Certificate.GetType().Name
        $LoggerFunctions.Info("Provided certificate parameter type is ${ParameterType}.")

        # Switch cert argument based on type
        switch($ParameterType){
            "String" { # create certificate object if string provided
                $ChildItem = Get-ChildItem $Certificate -ErrorAction Stop
                $LoggerFunctions.Debug("Building certificate with object found with provided path: $ChildItem")
                $Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]($ChildItem.FullName)
            }
            "X509Certificate2" { # do nothing if certificate object already loaded
                continue
            }
            default { # throw error if string or x509certificat2 object was not provided
                throw "Certificate parameter type is ${ParameterType}. It must be a String or X509Certificate2."
            }
        }
        return $Certificate
    }
}

function Build-CertificateChain {
    <#
      .Synopsis
        Builds the trust chain of a certificate object
      .Description
        Creates a chain element collection of the provided certificate and iterates each certificate in the collection.

        Refer to the 'Properties' section in the following link for available properties to add to the return object:
        https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509certificate2
      .Parameter Certificate
        [String] file patth to certificate or [X509Certificate2] object
      .Parameter Context
        Computer or User store
    #>
    param(
        [Parameter(Mandatory=$true)][System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [Parameter(Mandatory=$false)][ValidateSet("tls","msae")][String]$Type = "tls",
        [Parameter(Mandatory=$false)][ValidateSet("Machine","User")][String]$Context,
        [Parameter(Mandatory=$false)][String]$OutDir
    )

    $LoggerFunctions.Info("Attempting to build '$Type' certificate trust path for $($Certificate.Subject),$($Certificate.Thumbprint)")

    # Set outfile base for saving
    $OutFileBase = "$($OutDir)\$($Type)-chain"

    # construct chain from certificate object
    $CertificateChainObject = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    [void]$CertificateChainObject.Build($Certificate)
    $LoggerFunctions.Debug("$($Certificate.Subject) chain status: $($CertificateChainObject.ChainStatus | Out-ListString)")

    $CertificateChain = [PSCustomObject]@{
        UntrustedRoot = $false
        UnknownValidationStatus = $false
        UnreachableCDP = $false
        Certificates = @() 
    }

    # update object values based on chain status
    switch($CertificateChainObject.ChainStatus.Status){
        'UntrustedRoot' { $CertificateChain.UntrustedRoot = $true }
        'RevocationStatusUnknown' { $CertificateChain.UnknownValidationStatus = $true }
        'OfflineRevocation' { $CertificateChain.UnreachableCDP = $true }
    }

    $CertificateChainObject.ChainElements | where {$_.Certificate.Extensions.CertificateAuthority} | foreach {
        $Element = [PSCustomObject]@{
            Name = $_.Certificate.Subject.Split(",")[0].Split("=")[1]
            Subject = $_.Certificate.Subject
            Issuer = $_.Certificate.Issuer
            Thumbprint = $_.Certificate.Thumbprint
            Root = if($_.Certificate.Subject -eq $_.Certificate.Issuer){ $true }else{ $false }
            Truststore = $false
        }

        # check if certificate is installed in the local trustore
        if((Test-CertificateTrustStoreInstall -Thumbprint $Element.Thumbprint  -Root:$Element.Root)){
            $LoggerFunctions.Info("$($Element.Name) is installed in the local certificate truststore.")
            $Element.Truststore = $true
        } else {
            $LoggerFunctions.Warn("$($Element.Name) is not installed in the local certificate truststore.")
        }

        $CertificateChain.Certificates += $Element

        # slugify name and save certificate
        $Outfile = "$($OutFileBase)-$($Element.Name|Convert-Slugify).crt" # replace white spaces with underscores and lowercase all letters
        if($_.Certificate.Extensions.CertificateAuthority -and $OutDir){ # Save CA certificate files
            $_.Certificate.Export("Cert") | Set-Content $Outfile -Encoding Byte
            $LoggerFunctions.Info("Saved $($_.Certificate.Subject),$($_.Certificate.Thumbprint) to $Outfile.")
        }
    }

    $LoggerFunctions.Info("Certificate chain count: $($CertificateChain.Certificates.Count)") 
    if($CertificateChain.Certificates.Count -eq 1){
        $LoggerFunctions.Warn("Certificate chain does not contain any Certificate Authority elements!") 
    }

    return $CertificateChain
}

function Get-CertificateValidationExtensions {
    <#
      .Synopsis
        Parses AIA and CDP extensions from an X509 certificate object
      .Description
        Gets the string values of the validation extensions in a certificate. 
        This is helpful when manually building a certificate chain or validting the certificate status.
      .Parameter Certificate
        [X509Certificate2] Certificate to parse
    #>
    param(
        [Parameter(Mandatory=$true)][System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )
    $ValidationUrls = @()
    $Certificate.Extensions | foreach {
        $LoggerFunctions.Debug("Checking extension: '$($_.Oid.FriendlyName), $($_.Oid.Value)'")

        # AIA extension
        if($_.where({$_.Oid.Value -eq "1.3.6.1.5.5.7.1.1"})){ 
            $LoggerFunctions.Debug("Found AIA extension using '$($_.Oid.FriendlyName) $($_.Oid.Value)':  `n$($_.Format(1))")

            # split each AIA object to access for both the CA Issuer and OCSP locator existing
            $AIA = ($_.Format(1) -Split "Authority Info Access").Trim()

            # convert each AIA object string by splitting on spaces and trimming the leading space of each line
            $ExtensionCAIssuer = ($AIA | where{$_.Contains("1.3.6.1.5.5.7.48.2")}).Split('',[StringSplitOptions]::RemoveEmptyEntries).Trim()
            $ExtensionOcspLocation = ($AIA | where{$_.Contains("1.3.6.1.5.5.7.48.1")}).Split('',[StringSplitOptions]::RemoveEmptyEntries).Trim()

            # find each line that starts with 'URL=', trim the first 4 characters to remove 'URL=', and add to the array.
            $ValidationUrls += @{CAIssuers = ($ExtensionCAIssuer | where{$_.Contains("URL=")}).Substring(4)}
            $ValidationUrls += @{OCSPLocator = ($ExtensionOcspLocation | where{$_.Contains("URL=")}).Substring(4)}
        }

        # CDP extension
        if($_.where({$_.Oid.Value -eq "2.5.29.31"})){
            $LoggerFunctions.Debug("Found CDP extension using $($_.Oid.Value):  `n$($_.Format(1))")

            # convert to string by splitting on spaces and trimming the leading space of each line
            $ExtensionCDPs = $_.Format(1).Split('',[StringSplitOptions]::RemoveEmptyEntries).Trim()

            # find each line that starts with 'URL=', trim the first 4 characters to remove 'URL=', and add to the array.
            $ValidationUrls += @{CDP = ($ExtensionCDPs | where{$_.Contains("URL=")}).Substring(4)}
        }
    }
    $LoggerFunctions.Info("Parsed the following URLs from $($X509Certificate.Subject): $($ValidationUrls|Out-ListString)")
    return $ValidationUrls
} 

function Get-TlsCertificate {
    param (
        [Parameter(Mandatory,ValueFromPipeline)][Uri]$Uri,
        [Parameter(Mandatory=$false)][ValidateSet("AIA","TLS")][String]$Source = "TLS",
        [Parameter(Mandatory=$false)][String]$OutDir
    )

     $LoggerFunctions.Info("Attempting to download tls certificate from ${Uri}.")

    switch($PSVersionTable.PSVersion.Major){ # switch Core and Framework
        {$_ -ge 6} { # Core version
        
            try {
                $TcpClient = [System.Net.Sockets.TcpClient]::new($Uri.Host, $Uri.Port)
                try {
                    $SslStream = [System.Net.Security.SslStream]::new($TcpClient.GetStream())
                    $SslStream.AuthenticateAsClient($Uri.Host)
                    $X509Certificate = $SSlStream.RemoteCertificate
                    $LoggerFunctions.Debug("Retrieved certificate $($SslStream.RemoteCertificate)")
                } finally {
                    $SslStream.Dispose()
                }
            } finally {
                $TcpClient.Dispose()
            }
        }
        {$_ -eq 5} { # Net Framework version

            $LoggerFunctions.Info("Downloading certficate from $Uri")
            $WebRequest = [Net.WebRequest]::Create($Uri)
            $WebRequest.ServerCertificateValidationCallback = {$true} # disable untrusted certificate errors
            $WebRequest.Timeout = 1000 # Required to keep multiple concurrent sessions from opening
            try {
                $LoggerFunctions.Info("Inovking GetResponse on '$($WebRequest.RequestUri)'")
                $WebRequest.GetResponse() | Out-Null
            } catch {
                $LoggerFunctions.Exception($_)
                if($_.Exception.Message -like '*Exception calling "GetResponse"*'){ # get specific string for trimming
                    Write-Error "$($_.Exception.Message.Substring($_.Exception.Message.IndexOf(':')+1).Replace('"','').Trim())"
                } else {
                    Write-Error $_
                }
                exit
            }
            switch($Source){
                "AIA" { # download certificate from aia if content type is correct
                    $OutFile = "$OutDir\$($Uri.Host).crt"
                    if($WebRequest.GetResponse().ContentType -eq "application/pkix-cert"){
                        $DownloadRequest = New-Object System.Net.WebClient # create web client
                        $DownloadRequest.DownloadFile($Uri, $OutFile) # download file

                    } else {
                        $LoggerFunctions.Error("The AIA in the certificate does not point to a certificate file and HTML is being returned instead.")
                    }
                }  
                "TLS" { # export tls certificate to file
                    $OutFile = "$OutDir\$($Uri.Host).crt"
                    $WebRequest.ServicePoint.Certificate.Export("Cert") | Set-Content $OutFile  -Encoding Byte 
                    $LoggerFunctions.Info("Retrieved TLS certificate $($WebRequest.ServicePoint.Certificate.Subject) from $($Uri).")
                } 
            }
        }    
    }
    try {
        if($OutDir){
            Get-ChildItem $OutFile -ErrorAction Stop | Out-Null # verify outfile exists before constructing as certificate object
            $LoggerFunctions.Info("Saved certificate file to $OutFile.")
            return $OutFile

        } else { # return certificate object constructed from saved file
            $X509Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]($OutFile) 
            return $X509Certificate
        }
    } catch {
        $LoggerFunctions.Error("Failed to download certificate from $($Uri)")
        $LoggerFunctions.Exception($_)
    }
}

function Install-CertificateTrustStore {
    <#
      .Synopsis
        Install CA certificate in the local certificate truststore
      .Description
        Install CA certificate in the local certificate truststore.
      .Parameter Cert
        [String] file patth to certificate or [X509Certificate2] object
      .Parameter Context
        Machine (LocalMachine) or User (CurrentUser) store. Machine/User are used to match 'Context' parameter values in other functions.
    #>
    param(
        [Parameter(Mandatory=$true)]$Cert, # no type specified so it can be either string or x509certificat2 object
        [Parameter(Mandatory=$false)][ValidateSet("Machine","User")][String]$Location="Machine"
    )

    # Switch cert argument based on type
    switch($Cert.GetType().Name){
        "String" { # create certificate object if string provided
            $CertificateChildItem = Get-ChildItem $Cert -ErrorAction Stop
            $LoggerFunctions.Debug("Building certificate with object found with provided path: $Cert")
            $Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]($CertificateChildItem.FullName)
        }
        "X509Certificate2" { # do nothing if certificate object already loaded
            continue
        }
        default { # throw error if string or x509certificat2 object was not provided
            throw "$($MyInvocation.MyCommand): Provided -Cert type is $($Cert.GetType().Name). It must be a String or X509Certificate2."
        }
    }

    $StorePSObject = [PSCustomObject]@{
        Subject = $Certificate.Subject
        Thumbprint = $Certificate.Thumbprint
        Location = [string]
        StoreName = [string]
        StoreDisplayName = [string]
    }

    # Build store name
    if(-not $Certificate.Extensions.CertificateAuthority){
        $StorePSObject.StoreName = "Personal"
        $StorePSObject.StoreDisplayName = "Personal" 
    } elseif($Certificate.Subject -eq $Certificate.Issuer){
        $StorePSObject.StoreName = "Root"
        $StorePSObject.StoreDisplayName = "Trusted Root Certificate Authorities" 
    } else{
        $StorePsObject.StoreName = "CA"
        $StorePsObject.StoreDisplayName = "Intermediate Certificate Authorities" 
    }

    # Build store location
    $StorePSObject.Location = %{
        if($Location -eq "Machine"){
            "LocalMachine"
        } else {
            "CurrentUser"
        }
    }
    $LoggerFunctions.Info("Provided certificate will be installed in the $($StorePSObject.Location)\$($StorePSObject.StoreDisplayName) store.")

    # Root certificate store object
    $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store($StorePSObject.StoreName,$StorePSObject.Location)
    $Store.Open("ReadWrite")
    $LoggerFunctions.Debug(("Loaded ($($Store.Certificates.Count)) certificates from the $($StorePSObject.StoreDisplayName) store."))
    
    if($Certificate.Thumbprint -notin $Store.Certificates.Thumbprint){ # install certificate if it does not already exist
        $Store.Add($Certificate)
    } else {
        $LoggerFunctions.Info("$($StorePSObject.Thumbprint) is already installed in the $($StorePSObject.StoreDisplayName) store.")
    }   

    return $StorePSObject    
}

function New-CertificateTemplate {
    param(
        [Parameter(Mandatory)][String]$DisplayName,
        [Parameter(Mandatory)][String]$DomainController,
        [Parameter(Mandatory)][String]$ForestDn,
        [Parameter(Mandatory=$false)][String]$Group,
        [Parameter(Mandatory=$false)][String]$Duplicate,
        [Parameter(Mandatory=$true)]
        [Parameter(Mandatory=$false, ParameterSetName="Duplicate")][ValidateSet("Computer","User")][String]$Context="Computer"
    )

    $LoggerMain.Debug("$($MyInvocation|Out-BoundParameters)")

    try {
        
        # Build Certificate Templates object
        $ConfigContext = ([ADSI]"LDAP://RootDSE").ConfigurationNamingContext
        $TemplateContainerDn = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$ConfigContext"
        $TemplatePath = [ADSI]"LDAP://$TemplateContainerDn"

        # Get certificate template attributes if duplicating existing template
        if($Duplicate){
            $LoggerFunctions.Debug("$($Duplicate|ConvertTo-JSON)")
            $DuplicateTemplate = $TemplatePath.Children.where({$_.displayName -eq $Duplicate})
            
        }
        else {

            # if no duplicate set use default machine and user
            if($Computer){  $DuplicateTemplate = $TemplatePath.Children.where({ $_.displayName -eq "Computer"}) }
            else {          $DuplicateTemplate = $TemplatePath.Children.where({ $_.displayName -eq "User"}) }
            $LoggerFunctions.Debug("Duplicating base template: $($DuplicateTemplate.Name)")
            
        }
        $LoggerFunctions.Debug(("$($DuplicateTemplate.Name) attributes: $(($DuplicateTemplate|Select *)|Out-String)").Trim())

        # Create Template and populate initial values
        $CommonName = $DisplayName.Replace(" ","") # Remove whitespaces from name
        $NewTemplate = $TemplatePath.Create("pKICertificateTemplate", "CN=$CommonName")
        
        $NewOid = New-TemplateOID `
            -DomainController $DomainController `
            -Context $ConfigContext

        $NewTemplate.put("distinguishedName","CN=$CommonName,$TemplateContainerDn")
        $NewTemplate.put("displayName","$DisplayName")
        $NewTemplate.put("msPKI-Cert-Template-OID","$($NewOid.TemplateOID)")
        $NewTemplate.put("flags","$($DuplicateTemplate.flags)")
        $NewTemplate.put("revision","100")
        $NewTemplate.put("pKIDefaultKeySpec","$($DuplicateTemplate.pKIDefaultKeySpec)")

        [void]$NewTemplate.SetInfo()
        
        # create properties with default values
        if($DuplicateTemplate.pKICriticalExtensions){ 
            $NewTemplate.pKICriticalExtensions = $DuplicateTemplate.pKICriticalExtensions 
        }
        if($DuplicateTemplate.pKIDefaultCSPs){ 
            $NewTemplate.pKIDefaultCSPs = $DuplicateTemplate.pKIDefaultCSPs 
        }
        if($DuplicateTemplate.pKIMaxIssuingDepth){ 
            $NewTemplate.pKIMaxIssuingDepth = $DuplicateTemplate.pKIMaxIssuingDepth 
        }
        if($DuplicateTemplate.pKIExtendedKeyUsage){ 
            $NewTemplate.pKIExtendedKeyUsage = $DuplicateTemplate.pKIExtendedKeyUsage 
        }
        if($DuplicateTemplate.'msPKI-Certificate-Application-Policy'){ 
            $NewTemplate.'msPKI-Certificate-Application-Policy' = $DuplicateTemplate.'msPKI-Certificate-Application-Policy' 
        }
        if($DuplicateTemplate.'msPKI-Certificate-Name-Flag'){ 
            $NewTemplate.'msPKI-Certificate-Name-Flag' = $DuplicateTemplate.'msPKI-Certificate-Name-Flag' 
        }
        if($DuplicateTemplate.'msPKI-Enrollment-Flag'){ 
            $NewTemplate.'msPKI-Enrollment-Flag' = $DuplicateTemplate.'msPKI-Enrollment-Flag'
        }
        $NewTemplate.'msPKI-Minimal-Key-Size' = $DuplicateTemplate.'msPKI-Minimal-Key-Size'
        $NewTemplate.'msPKI-Private-Key-Flag' = $DuplicateTemplate.'msPKI-Private-Key-Flag'
        $NewTemplate.'msPKI-Template-Minor-Revision' = $DuplicateTemplate.'msPKI-Template-Minor-Revision'

        $NewTemplate.put('msPKI-Template-Schema-Version', "4")
        $NewTemplate.'msPKI-RA-Signature' = $DuplicateTemplate.'msPKI-RA-Signature'
        $NewTemplate.SetInfo()

        $DuplicateByteProps = $TemplatePath.Children.where({ $_.displayName -eq $DuplicateTemplate.DisplayName}) | Select-Object pKIKeyUsage,pKIExpirationPeriod,pKIOverlapPeriod

        # update properties values thats cant be set with put
        $NewTemplate.pKIKeyUsage = $DuplicateByteProps.pKIKeyUsage
        $NewTemplate.pKIExpirationPeriod = $DuplicateByteProps.pKIExpirationPeriod
        $NewTemplate.pKIOverlapPeriod = $DuplicateByteProps.pKIOverlapPeriod
        $NewTemplate.SetInfo()

        $LoggerFunctions.Success($Strings.Created -f ("certificate template", $DisplayName))
        return $true

    }
    catch [System.Management.Automation.MethodInvocationException] {
        if($_ -match "(The object already exists)"){
            $LoggerFunctions.Info($Strings.AlreadyExists -f $DisplayName, $True)
            return $false
        }
    }
    catch {
        $LoggerFunctions.Exception($_)
    }
}

function Set-CertificateTemplatePermissions {
    param(
        [Parameter(Mandatory)][String]$Template,
        [Parameter(Mandatory)][String]$Group,
        [Parameter(Mandatory)][String]$ForestDn,
        [Parameter(Mandatory=$false)][Switch]$ValidateFirst
    )

    # Get short name of current AD domain
    $NetBiosSecurityGroupName = "$((Get-ADDomain).NetBIOSName)\$Group"
    if($ValidateFirst){
        $LoggerFunctions.Info("Checking autoenrollment permission on '$Template' before attempting to set them.")

        $ResultVerification = Test-CertificateTemplatePermissions `
            -Template $Template `
            -NetBiosName $NetBiosSecurityGroupName

        if($ResultVerification){ return $ResultVerification }
    }

    # Retrieve template
    $ParentDomainDn = (Get-ADRootDSE).rootDomainNamingContext
    $CertificateTemplates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ParentDomainDn"
    $TemplateObject = $CertificateTemplates.Children.where({$_.displayName -eq $Template})

    # set autoenroll permissions
    $ActiveDirectoryObject = New-Object System.Security.Principal.NTAccount($NetBiosName,$Group)
    $LoggerFunctions.Debug("Created NTAccount object for: $(($ActiveDirectoryObject).Value)")
    $Identity = $ActiveDirectoryObject.Translate([System.Security.Principal.SecurityIdentifier])
    $ObjectType = "a05b8cc2-17bc-4802-a710-e7c15ab866a2"
    $Rights = "ExtendedRight"
    $Type = "Allow"

    # create access rule
    $ActiveDirectoryAccessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity,$Rights,$Type)
    $LoggerFunctions.Debug("Created access rule for $($ActiveDirectoryObject): $($ActiveDirectoryAccessRule|Out-ListString)")
    $TemplateObject.ObjectSecurity.SetAccessRule($ActiveDirectoryAccessRule)
    $TemplateObject.CommitChanges()

    $LoggerFunctions.Debug("Committed ACL changes on '$Template'.")

    # verify permissions were set
    $ResultVerification = Test-CertificateTemplatePermissions `
        -Template $Template `
        -NetBiosName $NetBiosSecurityGroupName

    if($ResultVerification){
        $LoggerFunctions.Success("Successfully granted security group '$Group' autoenrollment permissions on '$Template'.")
    } else {
        $LoggerFunctions.Error(
            "Failed to grant autoenrollment permission on '$Template' for security group: $Group. If the template was just created and '$($ToolBoxConfig.ParentDomain)' is a parent domain, this is most likely do to replication.")
    }
}

function Test-CertificateTemplateExists {
    param(
        [Parameter(Mandatory)][String]$DisplayName
    )

    $ConfigContext = (Get-ADRootDSE).rootDomainNamingContext
    $CertificateTempates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ConfigContext"
    $Template = $CertificateTempates.Children.where({$_.displayName -eq $DisplayName})
    if($Template){
        return $true
    } else {
        return $false
    }
}

function Test-CertificateTemplatePermissions {
    param(
        [Parameter(Mandatory=$true)][String]$Template,
        [Parameter(Mandatory=$true)][String]$NetBiosName
    )

    # Permission GUIDs for conditional matching
    $Guids = @(
        "a05b8cc2-17bc-4802-a710-e7c15ab866a2",
        "00000000-0000-0000-0000-000000000000"
    )

    $LoggerFunctions.Info("Testing autoenrollment permissions for ${Template}")

    # Get template directory object
    $ConfigContext = (Get-ADRootDSE).rootDomainNamingContext
    $CertificateTemplates = [ADSI]"LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$ConfigContext"
    $ProvidedTemplate = $CertificateTemplates.Children.where({$_.Name -eq $Template})
    $LoggerFunctions.Debug($($ProvidedTemplate.ObjectSecurity.Access|Out-ListString))

    # Loop through Access rules that only contain the name of the provided security group
    $ProvidedTemplate.ObjectSecurity.Access.where({$_.IdentityReference -eq $NetBiosName}).foreach{
        # Return true if autoenrollment and allow permissions found
        if($_.ObjectType.ToString() -in $Guids -and $_.ActiveDirectoryRights -match "(ExtendedRight)"){ $AlreadyPermissioned = $true }
    }

    if($AlreadyPermissioned){
        $LoggerFunctions.Info("Security group '$NetBiosName' is already configured with autoenrollment permissions on '$Template'.")
        return $true
    } else {
        $LoggerFunctions.Info("Security group '$NetBiosName' is not configured with autoenrollment permissions on '$Template'.")
        return $false
    }
}

function Test-CertificateTrustStoreInstall {
    <#
      .Synopsis
        Tests if certificate issuer is installed in the local certificate trustore
      .Description
        Loads path to certificate file, or certificate object, and checks if the certificate is installed in the local machine truststore.
    #>
    param(
        [Parameter(Mandatory=$false)]$Certificate, # no type specified so it can be either string or x509certificat2 object
        [Parameter(Mandatory=$false)]$Thumbprint,
        [Parameter(Mandatory=$false)]$Root=$false,
        [Parameter(Mandatory=$false)][ValidateSet("Machine","User")][String]$Context="Machine"
    )

    # set truststore location values based on context parameter
    switch($Context){
        'Machine' { $Location = 'LocalMachine' }
        'User' { $Location = 'User' }
    }

    # build certificate object
    if($Certificate){ 
        $X509Certificate = Build-X509Certificate -Certificate $Certificate 
        $Thumbprint = $X509Certificate.Thumbprint
    }

    # open store type based root boolean
    switch($Root){
        $true { 
            $TrustStoreType = 'Trusted Root Certificate Authority'
            $TrustStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root",$Location) 
        }
        $false { 
            $TrustStoreType = 'Intermediate Certificate Authority'
            $TrustStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("CA",$Location) 
        }

    }
    $TrustStore.Open("ReadWrite")
    $LoggerFunctions.Info("Checking if $TrustStoreType certificate store contains matching thumprint for '$Thumbprint'.")
    $LoggerFunctions.Debug("$Location\$TrustStoreType store certificate thumbprints: $($TrustStore.Certificates | Select Subject,Thumbprint | Out-ListString)")

    # check truststore for installed certificate based on provided thumbprint
    if($Thumbprint -in $TrustStore.Certificates.Thumbprint){
        $LoggerFunctions.Info("Located matching thumprint for '$Thumbprint'.")
        return $true
    } else {
        $LoggerFunctions.Info("Did not locate matching thumprint for '$Thumbprint'.")
        return $false
    }
}

