function Get-CertificateExtensions {
    param(
        [Parameter(Mandatory=$true)][String]$Certificate,
        [Parameter(Mandatory=$false)][Boolean]$File=$true
    )
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.GetCertificateValidationExts"

    try {

        # Get file
        if($File){
            $CertificateFile = Get-ChildItem $Certificate -ErrorAction Stop
        }
       
        # Dump cert
        $CertificateContent = $(certutil $Certificate) -split [Environment]::NewLine       
        $LoggerFunctions.Debug("Dumped the contents of $CertificateFile.")

        # Loop dump to get extensions
        for ($x = 0; $x -lt $CertificateContent.Count; $x++) {
            $Line = $CertificateContent[$x]

            # Authority Key Identifier
            $Line = $CertificateContent[$x]
            if($CertificateContent[$x] -match "(2.5.29.35)+"){
                while($Line -ne ""){
                    if($Line -match "(KeyID=)"){
                        $CertifcateAKI = $Line.Substring($Line.IndexOf('=')+1)
                        $LoggerFunctions.Info("Authority Key Identifier: $CertifcateAKI.")
                    }
                    $Line = $CertificateContent[$x++]
                }
            }

            # Authority Information Access
            if($CertificateContent[$x] -match "(1.3.6.1.5.5.7.48.2)+"){
                while($line -ne "" -and $Line -notmatch "(1.3.6.1.5.5.7.48.1)+"){
                    # regex aia in line to get url
                    if($Line -match "(URL=)") {
                        $CertificateAIA = $Line.Substring($Line.IndexOf('=')+1)
                        $LoggerFunctions.Info("Authority Information Access: $CertificateAIA.")
                    }
                    $line = $CertificateContent[$x++]
                }
            }

            # Certificate Distribution Point
            $Line = $CertificateContent[$x]
            if($CertificateContent[$x] -match "(2.5.29.31)+"){
                while($Line -ne ""){
                    if($Line -match "(URL=)"){
                        $CertifcateCDP = $Line.Substring($Line.IndexOf('=')+1)
                        $LoggerFunctions.Info("Certificate Distribution Point: $CertifcateCDP.")
                    }
                    $Line = $CertificateContent[$x++]
                }
            }

            # store variables into certificate object
            $CertificateExtensions = [PSCustomObject]@{
                AuthorityInformationAccess = $CertificateAIA
                AuthorityKeyIdentifier = $CertifcateAKI
                CrlDistributionPoint = $CertifcateCDP
            }
            continue
        }
        return $CertificateExtensions

    } catch [System.Management.Automation.ItemNotFoundException]{
        $LoggerFunctions.Error($_)
    }
    catch {
        $LoggerFunctions.Exception($_)
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
      .Parameter Cert
        [String] file patth to certificate or [X509Certificate2] object
      .Parameter Context
        Computer or User store
    #>
    [CmdletBinding(DefaultParameterSetName="File")]
    param(
        [Parameter(Mandatory=$true)]$Cert, # no type specified so it can be either string or x509certificat2 object
        [Parameter(Mandatory=$false)][ValidateSet("Machine","User")][String]$Context,
        [Parameter(Mandatory=$false)][String]$OutDir
    )

    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.GetCertificateTrustStatus"

    try {

        # Get certificate from provided file path and construct X509CertificateObject
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

        $LoggerFunctions.Debug("Building certificate chain.")
        $CertificateChain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
		[void]$CertificateChain.Build($Certificate)
        $LoggerFunctions.Info("Attempting to build certificate trust path for $($Certificate.Subject),$($Certificate.Thumbprint)")
        $Chain = [PSCustomObject]@{
            Status = %{ $CertificateChain.ChainStatus.where({$_.Status -notlike "*Revocation*"})
                if($_.Status){
                    $LoggerFunctions.Debug("$($($_.StatusInformation).Trim())")
                    $_.Status
                # } # else {
                #     "Trusted"
                # }
                }
            }
            #Certificates = @()
        }
        $CertificateChain.ChainElements | foreach {
            $Certificates = [PSCustomObject]@{
                Subject = $_.Certificate.Subject
                Issuer = $_.Certificate.Issuer
                Thumbprint = $_.Certificate.Thumbprint
                Type = %{if($_.Certificate.Extensions.CertificateAuthority){"CA"}else{"Entity"}}
            }
            $Chain.Certificates += $Certificates
            
            $CommonName = $_.Certificate.Subject.Split(",")[0].Split("=")[1]
            $Outfile = "$($OutDir)\$($CommonName|Convert-Slugify).crt" # replace white spaces with underscores and lowercase all letters
            if($_.Certificate.Extensions.CertificateAuthority -and $OutDir){ # Save CA certificate files
                $_.Certificate.Export("Cert") | Set-Content $Outfile -Encoding Byte
                $LoggerFunctions.Info("Saved $($_.Certificate.Subject),$($_.Certificate.Thumbprint) to $Outfile.")
            }
        }

        $LoggerFunctions.Info("Certificate chain count: $($Chain.Count)") 
        if($Chain.Count -eq 1){
            $LoggerFunctions.Warn("Certificate chain does not contain any Certificate Authority elements!") 
            #$LoggerFunctions.Info("Failed to download Certificate Authority certificates from Default Isser URIs in provided entity certificate.") 
        }

        return $Chain

    } catch [System.Management.Automation.ItemNotFoundException]{
        $LoggerFunctions.Error($_)

    } catch {
        $LoggerFunctions.Exception($_)
    }
    # } finally {
    #     # Dispoce of stores after
    #     $RootCertStore.Dispose()
    #     $IntermediateCertStore.Dispose()
    # }

    #return $ChainStatusResults
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
    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.InstallCertificateTrustStatus"
    $LoggerFunctions.Debug("Enumerating local certificate truststores to verify chain exists locally.")

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



    # # Build Intermediate certificate store object
    # $IntermediateCertStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("CA","LocalMachine")
    # $IntermediateCertStore.Open("ReadWrite")
    # $LoggerFunctions.Debug((
    #     "Loaded ($($IntermediateCertStore.Certificates.Count)) certificates from Intermedidate CA store."
    #     #"Intermediate Certificate Store certificates: $($IntermediateCertStore.Certificates|Select Subject,Thumbprint|Out-TableString)"
    # ))

    # # Check certificate stores for certificate
    # # Required because the X509Chain object includes internet access to the AIA but the certificate need to always be in the local cert store
    # $ChainStatusResults = @()
    # $CertificateChain.ChainElements | where {$_.Certificate.Extensions.CertificateAuthority} | foreach { # save each chain element
    #     $CACertificate = [PSCustomObject]@{
    #         Subject = $_.Certificate.Subject
    #         Thumbprint = $_.Certificate.Thumbprint
    #         Store = %{if($_.Certificate.Subject -eq $_.Certificate.Issuer){"Root"}else{"Intermediate"}}
    #         Status = ""
    #     }
        
    #     # Create outfile path from Common Name and save certificate
    #     $CommonName = $_.Certificate.Subject.Split(",")[0].Split("=")[1]
    #     $Outfile = "$($OutDir)\$($CommonName|Convert-Slugify).crt" # replace white spaces with underscores and lowercase all letters
    #     $_.Certificate.Export("Cert") | Set-Content $Outfile -Encoding Byte # Save certificate files
    #     $LoggerFunctions.Info("Saved $($_.Certificate.Subject),$($_.Certificate.Thumbprint) to $Outfile.")

    #     # Install certificate if specified
    #     if($Install -and $CACertificate.Store -eq "Root" -and $_.Certificate.Thumbprint -notin $RootCertStore.Certificates.Thumbprint){
    #         $LoggerFunctions.Info("Installing $($_.Certificate.Subject) in the Root CA Certificate store...")
    #         $RootCertStore.Add($_.Certificate)
    #         $CACertificate.Status = "Installed"

    #     } elseif($Install -and $CACertificate.Store -eq "Intermediate" -and $_.Certificate.Thumbprint -notin $IntermediateCertStore.Certificates.Thumbprint){
    #         $LoggerFunctions.Info("Installing $($_.Certificate.Subject) in the Intermediate CA Certificate store...")
    #         $IntermediateCertStore.Add($_.Certificate)
    #         $CACertificate.Status = "Installed"

    #     } elseif($Install) {
    #         $LoggerFunctions.Info("$CommonName already exists in the $($CACertificate.Store) CA Certificate store.")
    #         $CACertificate.Status = "Already Installed"
    #     } else {
    #         $LoggerFunctions.Info("$($_.Certificate.Subject),$($_.Certificate.Thumbprint) will need to be manually install the certificate store because the user chose not to automatically install.", $True)
    #     }

    #     $ChainStatusResults += $CACertificate # add certificate status object to array
    # }

    
}

function Invoke-CertificateDownload {
    param (
        [Parameter(Mandatory,ValueFromPipeline)][Uri]$Uri,
        [Parameter(Mandatory=$false)][ValidateSet("AIA","TLS")][String]$Source,
        [Parameter(Mandatory=$false)][String]$OutFile
    )

    $LoggerFunctions.Logger = "MSAE.Toolkit.Function.InvokeCertificateDownload"
    Switch($PSVersionTable.PSVersion.Major){ # switch Core and Framework

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
            }
            Switch($Source){

                "AIA" { # download certificate from aia if content type is correct
                    if($WebRequest.GetResponse().ContentType -eq "application/pkix-cert"){
                        $DownloadRequest = New-Object System.Net.WebClient # create web client
                        $DownloadRequest.DownloadFile($Uri, $OutFile) # download file

                    } else {
                        $LoggerFunctions.Error("The AIA in the certificate does not point to a certificate file and HTML is being returned instead.")
                    }
                }  
                "TLS" { # export tls certificate to file
                    $WebRequest.ServicePoint.Certificate.Export("Cert") | Set-Content $OutFile  -Encoding Byte 
                    $LoggerFunctions.Info("Retrieved TLS certificate $($WebRequest.ServicePoint.Certificate.Subject) from $($Uri).")
                    $LoggerFunctions.Console("Green")
                } 
            }
        }    
    }
    try {
        if($Outfile){
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

