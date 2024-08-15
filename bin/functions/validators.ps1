function Test-ServiceAccount {
    param(
        [Parameter(Mandatory=$true)][String]$Account,
        [Parameter(Mandatory=$true)][String]$ServicePrincipalName,
        [Parameter(Mandatory=$false)][String]$EncrypionType = "AES256"
    )

    $LoggerMain.Debug("$($MyInvocation|Out-BoundParameters)")
    $LoggerMain.Info("Validating attributes for service account ${Account}.")

    $Attributes = Get-AdUser $Account -Properties * | Select Enabled,LockedOut,servicePrincipalName,KerberosEncryptionType
    $LoggerMain.Debug("Collected attributes for ${Account}: $($Attributes|Out-ListString)")

    $Results = @()
    $Index = 1

    foreach ($_ in $Validation.ServiceAccount.Tests.PSObject.Properties) {

        $Test = $_.Value
        $Test | Add-Member -Name "Status" -Type NoteProperty -Value "Skipped"  
        
        # Active
        if($Test.Title -eq $ValidationTitles.ActiveServiceAccount){
            if($Attributes.Enabled -and $Attributes.LockedOut -eq $false){
                $Test.Status = "Enabled and Unlocked."
                $Test.Result = $Result.Passed

            } elseif(-not $Attributes.Enabled -and $Attributes.LockedOut -eq $false){
                $Test.Status = "Disabled and Unlocked."
                $Test.Result = $Result.Failed

            } elseif($ValidateActive -and $Attributes.Enabled -and $Attributes.LockedOut){
                $Test.Status = "Enabled and locked."
                $Test.Result = $Result.Failed

            } else {
                $Message = $ValidationMessages.UnknownFailure
                $Test.Result = $Result.Failed
            }
                
        # Service Principal Name
        } elseif($Test.Title -eq $ValidationTitles.ValidServiceAccountSPN){
            if($Attributes.servicePrincipalName -contains $ServicePrincipalName){
                $Test.Status = "Contains the Service Principal Name ${ServicePrincipalName}."
                $Test.Result = $Result.Passed

            } elseif($Attributes.servicePrincipalName -notcontains $ServicePrincipalName){
                $Test.Status = "Does not contain the service principal name ${ServicePrincipalName}."
                $Test.Result = $Result.Failed

            } else {
                $Message = $ValidationMessages.UnknownFailure
                $Test.Result = $Result.Failed
            }

        # Supported Encryption Keys
        } elseif($Test.Title -eq $ValidationTitles.ServiceAccountKerberos){
            if($Attributes.KerberosEncryptionType -contains $EncrypionType){
                $Test.Status = "Supports Kerberos AES 256 bit encryption."
                $Test.Result = $Result.Passed

            } elseif($Attributes.KerberosEncryptionType -notcontains $EncrypionType ){
                $Test.Status = "Does not support Kerberos AES 256 bit encryption."
                $Test.Result = $Result.Failed

            } else {
                $Message = $ValidationMessages.UnknownFailure
                $Test.Result = $Result.Failed
            }
        }

        $LoggerValidation.Validate("$($Test.Title): $($Test.Status)", $Test.Result)
        $Index++
    }
}

function Test-Kerberos {
    param(
        [Parameter(Mandatory=$true)][String]$Keytab,
        [Parameter(Mandatory=$true)][String]$Krb5,
        [Parameter(Mandatory=$true)][String]$Principal
    )

    $LoggerMain.Debug("$($MyInvocation|Out-BoundParameters)")
    $LoggerMain.Info("Validating the kerberos files.")
    $Aes256Sha1String = "AES256-SHA1"
    $PermittedKeyString = "aes256-cts-hmac-sha1-96"

    # build objects
    $KeytabContents = Out-Keytab -Path $Keytab
    $Krb5Contents = Out-Krb5Conf -Path $Krb5
    $Domain = ((Get-ADDomain -Current LocalComputer).DNSRoot).ToUpper()

    $Results = @() # Initialize array for adding return results
    $Index = 1

    foreach ($_ in $Validation.Kerberos.Tests.PSObject.Properties) {

        $Test = $_.Value
        $Test | Add-Member -Name "Status" -Type NoteProperty -Value ""           

        # AES256 Encryption key check
        if($Test.Title -eq $ValidationTitles.KeytabEncryptionKeys){
            if($KeytabContents.Keys.Count -eq 1 -and $KeytabContents.Keys -contains $Aes256Sha1String){ # enabled and unlocked
                $Test.Status = "The keytab only contains a single AES256-SHA1 encryption key."
                $Test.Result = $Result.Passed

            } elseif($KeytabContents.Keys.Count -gt 1 -and $KeytabContents.Keys -contains $Aes256Sha1String){
                $Test.Status = "The keytab contains more than one encryption key."
                $Test.Result = $Result.Warning

            } else {
                $Test.Status = $ValidationMessages.UnknownFailure
                $Test.Result = $Result.Failed
            }

        # Principal Name
        } elseif($Test.Title -eq $ValidationTitles.KeytabPrincipalName){
            if($KeytabContents.Principal -eq $Principal){ # enabled and unlocked
                $Test.Status = "The keytab contains the principal name ${Principal}." 
                $Test.Result = $Result.Passed

            } elseif($KeytabContents.Principal -ne $Principal){
                $Test.Status = "The keytab does not contain the principal name ${Principal}." 
                $Test.Result = $Result.Failed

            } else {
                $Test.Status = $ValidationMessages.UnknownFailure
                $Test.Result = $Result.Failed
            }  

        # Permited Encryption Keys
        } elseif($Test.Title -eq $ValidationTitles.Krb5PermittedKeys){
            if($Krb5Contents.PermittedKeyTypes -contains $PermittedKeyString){ # enabled and unlocked
                $Test.Status = "The configuration file permits the use of '${PermittedKeyString}' kerboros encryption keys."
                $Test.Result = $Result.Passed

            } elseif($Krb5Contents.PermittedKeyTypes -notcontains $PermittedKeyString){
                $Test.Status = "The configuration file does not permit the use of '${PermittedKeyString}' kerboros encryption keys."
                $Test.Result = $Result.Failed

            } else {
                $Test.Status = $ValidationMessages.UnknownFailure
                $Test.Result = $Result.Failed
            }  

        # Krb5 Authorized Realms
        } elseif($Test.Title -eq $ValidationTitles.Krb5AuthorizedRealms){
            if($Krb5Contents.Realms.Name -ccontains $Domain){ # enabled and unlocked
                $Test.Status = "The configuration file includes a realm, in all capital letters, for ${Domain}."
                $Test.Result = $Result.Passed

            } elseif($Krb5Contents.Realms.Name -ccontains $Domain.ToLower()){
                $Test.Status = "The configuration file includes the required realm ${Domain}, but it is the wrong case."
                $Test.Result = $Result.Failed

            } elseif($Krb5Contents.Realms.Name -notcontains $Domain){
                $Test.Status = "The configuration file does not include the required realm ${Domain}."
                $Test.Result = $Result.Failed

            } else {
                $Test.Status = $ValidationMessages.UnknownFailure
                $Test.Result = $Result.Failed
            }  

        # Krb5 Realm Authorized KDCs
        } elseif($Test.Title -eq $ValidationTitles.Krb5RealmKdcs){
            $ForestDomainControllers = Get-ADDomainController -filter * | Select-Object Name
            $ForestDomains = Get-ForestDomains # combine forest root domain and sub domains

            if(($Krb5Contents.Realms.Kdcs -contains $ForestDomainControllers) -or ($Krb5Contents.Realms.Kdcs -ccontains $ForestDomains.Domains)){
                $Test.Status = "The realm includes a KDC that is either a child domain or single KDC host."
                $Test.Result = $Result.Passed

            } elseif(($Krb5Contents.Realms.Kdcs -notcontains $ForestDomainControllers) -or ($Krb5Contents.Realms.Kdcs -notcontains $ForestDomains.Domains)){
                $Test.Status = "The realm includes an invalid KDC host, or child domain, that does not belong to $($ForestDomains.Root)." 
                $Test.Result = $Result.Failed

            } else {
                $Test.Status = $ValidationMessages.UnknownFailure
                $Test.Result = $Result.Failed
            }  
        } 

        $LoggerValidation.Validate("$($Test.Title): $($Test.Status)", $Test.Result)
        $Index++
    }
}

function Test-CepServerEndpoint {
    param(
        [Parameter(Mandatory=$true)][Uri]$Uri
    )

    $Hostname = $Uri.Host
    $LoggerValidation.Debug("$($MyInvocation|Out-BoundParameters)")
    $LoggerValidation.Info("Validating the CEP Server endpoint: ${Hostname}.")

    $Results = @(); $Index = 1
    foreach ($_ in $Validation.CepServerEndpoint.Tests.PSObject.Properties) {

        $Test = $_.Value
        $Test | Add-Member -Name "Status" -Type NoteProperty -Value ""           

        # DNS A Record
        if($Test.Title -eq $ValidationTitles.CepDnsRecord){
            try {
                $HostnameDns = (Resolve-DnsName $Hostname -ErrorAction Stop).Type

                if($HostnameDns -eq "A"){
                    $Test.Status = "The enrollment policy server ${Hostname} resolves with a DNS A record."
                    $Test.Result = $Result.Passed
                } elseif($HostnameDns -eq "CNAME"){
                    $Test.Status = "The enrollment policy server ${Hostname} resolves with a DNS CNAME record."
                    $Test.Result = $Result.Passed
                
                } else {
                    $Test.Status = $ValidationMessages.UnknownFailure
                    $Test.Result = $Result.Failed
                }

            } catch [System.ComponentModel.Win32Exception]{
                $Test.Status = "A DNS record does not exist for ${Hostname}."
                $Test.Result = $Result.Failed
            }

        # TLS Port Access
        } elseif($Test.Title -eq $ValidationTitles.CepTlsPortAccess){
            if($Validation.CepServerEndpoint.Tests.CepDnsRecord.Result -eq "Passed"){
                $TlsPortAccess = Test-RemoteEndpoint $Uri

                if($TlsPortAccess){
                    $Test.Status = "The enrollment policy server ${Hostname} is reachable over port 443."
                    $Test.Result = $Result.Passed

                } elseif(-not $TlsPortAccess){
                    $Test.Status = "The enrollment policy server ${Hostname} is not reachable over port 443."
                    $Test.Result = $Result.Failed
                
                } else {
                    $Test.Status = $ValidationMessages.UnknownFailure
                    $Test.Result = $Result.Failed
                }
            } else {
                $Test.Status = "Skipped because test '$($Validation.CepServerEndpoint.Tests.CepDnsRecord.Title)' failed."
                $Test.Result = $Result.Skipped
            }

        # Trust Chain
        } elseif($Test.Title -eq $ValidationTitles.CepBuildChain){
            if($Validation.CepServerEndpoint.Tests.CepTlsPortAccess.Result -eq $Result.Passed){
                $TlsCertificate = Get-TlsCertificate $Uri
                $Chain = Build-CertificateChain -Certificate $TlsCertificate

                $RootCaName = ($Chain.Certificates.where({$_.Root})).Name
                $MissingIntermediateCAs = ($Chain.Certificates | where {-not $_.Truststore -and -not $_.Root}).Name

                # The Root CA and all Intermediate CAs are installed
                if($Chain.UntrustedRoot -eq $false -and -not $MissingIntermediateCAs.Count){
                    $Test.Status = "The certificate chain was successfully built and chains to a Root CA installed in the trust store."
                    $Test.Result = $Result.Passed

                } else {
                    
                    # No certificates were returned. 
                    if(-not $Chain.Certificates.Name.Count){
                        $Test.Status = "A certificate chain could not be built because there are missing CA certificates that are not installed in the trust store and could not be downloaded."

                    # Only the Root CA is missing
                    } elseif($Chain.UntrustedRoot -and -not $MissingIntermediateCAs.Count){
                        $Test.Status = "The certificate chain was successfully built, but '${RootCaName}' is not installed in Trusted Root Certification Authorities store."

                    # Root CA and at least 1 Intermediate CA is missing
                    } elseif($Chain.UntrustedRoot -and $MissingIntermediateCAs.Count -gt 0){
                        $MissingCAs = @($RootCaName, $MissingIntermediateCAs) # add root ca and missing intermediate cas together
                        $Test.Status = "The certificate chain was successfully built, but the following CAs are not installed in the trust store: $($MissingCAs -join ", ")."
                    
                    } else {
                        $Test.Status = $ValidationMessages.UnknownFailure

                    }
                    $Test.Result = $Result.Failed
                }
            } else {
                if($Validation.CepServerEndpoint.Tests.CepTlsPortAccess.Result -eq "Skipped"){
                    $Test.Status = "Skipped because test '$($Validation.CepServerEndpoint.Tests.CepTlsPortAccess.Title)' was skipped."

                } elseif($Validation.CepServerEndpoint.Tests.CepTlsPortAccess.Result -eq "Failed"){
                    $Test.Status = "Skipped because test '$($Validation.CepServerEndpoint.Tests.CepTlsPortAccess.Title)' failed."
                }
            
                $Test.Result = $Result.Skipped
            }
        }

        $LoggerValidation.Validate("$($Test.Title): $($Test.Status)", $Test.Result)
        $Index++
    }
}

function Test-CertificateTemplates {
    param(
        [Parameter(Mandatory=$true)][Uri]$Template,
        [Parameter(Mandatory)][String]$Group,
        [Parameter(Mandatory)][String]$ForestDn,
        [Parameter(Mandatory=$false)][ValidateSet("Computer","User")][String]$Context="Computer"

    )

    $LoggerValidation.Debug("$($MyInvocation|Out-BoundParameters)")
    $LoggerValidation.Info("Validating the Certificate Template: ${Template}.")

    Switch ($Context){
        "Computer"  { 
            $GroupMembership = Get-SecurityGroups -Computer 
            $CommonName = $env:COMPUTERNAME
        }
        "User"      { 
            $GroupMembership = Get-SecurityGroups -User 
            $CommonName = $env:USERNAME
        }
    }

    # Build netbios name for permissions check
    $NetBiosSecurityGroupName = "$((Get-ADDomain).NetBIOSName)\$Group"

    $Results = @(); $Index = 1
    foreach ($_ in $Validation.CertTemplates.Tests.PSObject.Properties) {

        $Test = $_.Value
        $Test | Add-Member -Name "Status" -Type NoteProperty -Value ""   

        if($Test.Title -eq $ValidationTitles.CertTemplateGroupMembership){
            # Get object from list if a match exists
            $NetBiosSecurityGroup = $GroupMembership | where {$_.IdentityReference -eq $NetBiosSecurityGroupName}

            if($NetBiosSecurityGroup){
                $Test.Status = "$CommonName is a member of '$NetBiosSecurityGroupName'."
                $Test.Result = $Result.Passed
            
            } else {
                $Test.Status = "$CommonName is not a member of '$NetBiosSecurityGroupName'."
                $Test.Result = $Result.Failed
            }

        } elseif($Test.Title -eq $ValidationTitles.CertTemplateAutoenroll){
            $TemplateTest = Test-CertificateTemplatePermissions `
                -Template $Template `
                -NetBiosName $NetBiosSecurityGroupName 

            if($TemplateTest){
                $Test.Status = "'$NetBiosSecurityGroupName' is configured with autoenrollment permissions on '$Template'."
                $Test.Result = $Result.Passed
            } else {
                $Test.Status = "'$NetBiosSecurityGroupName' is not configured with autoenrollment permissions on '$Template'."
                $Test.Result = $Result.Failed
            }
        } 

        $LoggerValidation.Validate("$($Test.Title): $($Test.Status)", $Test.Result)
        $Index++
    }
}