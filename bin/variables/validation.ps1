
$Global:Result = @{
    Passed = "Passed"
    Failed = "Failed"
    NotTested = "Not Tested"
    Skipped = "Skipped"
}

$Global:Categories = @{
    ServiceAccount = "Service Account"
    Kerberos = "Kerberos"
    CepServerEndpoint = "Certificate Enrollment Policy Endpoint"
    CertTemplates = "Certificate Template"
}

$Global:ValidationMessages = @{
    NotTested = "Not Tested."
    Skipped = "Skipped"
    UnknownFailure = "Failed for an unknown reason. Refer to the logs for more information."
}

$Global:ValidationTitles = @{
    # Service Account
    ActiveServiceAccount = "Active Service Account"
    ValidServiceAccountSPN = "Valid Service Principal Name"
    ServiceAccountKerberos = "Account Supported Kerberos"

    # Kerberos
    KeytabEncryptionKeys = "Keytab Encryption Keys"
    KeytabPrincipalName = "Keytab Valid Principal Name"
    Krb5PermittedKeys = "Krb5 Permitted Keys"
    Krb5AuthorizedRealms = "Krb5 Authorized Realms"
    Krb5RealmKdcs = "Krb5 Realm Authorized KDCs"
    Krb5DomainRealms = "Krb5 Domain Realms"

    # CEP Server
    CepDnsRecord = "DNS A Record"
    CepTlsPortAccess = "TLS Port Access"
    CepBuildChain = "Build Chain"
    CepTrustStore = "Installed in Trust Store"

    # Certificate Template
    CertTemplateAutoenroll = "Autoenrollment Permissions"
    CertTemplateGroupMembership = "Security Group Membership"
}

$Global:Validation = @{
    ServiceAccount = [PSCustomObject]@{
        Title = $Categories.ServiceAccount
        Tests = [PSCustomObject]@{
            Active = [PSCustomObject]@{
                Title = $ValidationTitles.ActiveServiceAccount
                Description = "An active, dedicated service account is required to support EJBCA MSAE."
                Result = $Result.NotTested
            }
            SPN = [PSCustomObject]@{
                Title = $ValidationTitles.ValidServiceAccountSPN
                Description = "The policy server hostname must exist as a Service Principal Name (SPN) on the service account configured for auotenrollment. A misconfigured SPN prevents the KDC from located the correct keytab file used by domain computers when checking the Certificate Enrollment Policy."
                Result = $Result.NotTested
            }
            Kerberos = [PSCustomObject]@{
                Title = $ValidationTitles.ServiceAccountKerberos
                Description = "The EJBCA Microsoft Autoenrollment only support AES256-SHA1 encryption key types. It is recommended to enforce this at the account level instead of relying on enforcement through group policy to ensure the correct encryption key is issued by the KDC."
                Result = $Result.NotTested
            }
        }
    }
    Kerberos = [PSCustomObject]@{
        Title = $Categories.Kerberos
        Tests = [PSCustomObject]@{
            KeytabEncryptionKeys = [PSCustomObject]@{
                Title = $ValidationTitles.KeytabEncryptionKeys
                Description = "A keytab file should only contain an AES256-SHA1 encryption key."
                Result = $Result.NotTested
            }
            KeytabPrincipalName = [PSCustomObject]@{
                Title = $ValidationTitles.KeytabPrincipalName
                Description = "A keytab file should an encryption key with a Principal Name that matches the policy server and service principal name configured in the service account."
                Result = $Result.NotTested
            }
            Krb5PermittedKeys = [PSCustomObject]@{
                Title = $ValidationTitles.Krb5PermittedKeys
                Description = "A Krb5 configuration file must permit the use of 'aes256-cts-hmac-sha1-96' kerboros encryption keys."
                Result = $Result.NotTested
            }
            Krb5AuthorizedRealms = [PSCustomObject]@{
                Title = $ValidationTitles.Krb5AuthorizedRealms
                Description = "A Krb5 configuration file must have a Realm added for each Active Directory forest where clients might requests certificates from. The realm must be defined in the file with all capital letters."
                Result = $Result.NotTested
            }
            Krb5RealmKdcs = [PSCustomObject]@{
                Title = $ValidationTitles.Krb5RealmKdcs
                Description = "Each realm in the Krb5 configuration file needs to have Key Distribution Center (KDC) servers for EJBCA to defined authorized issuers of kerberos tickets. This value must each be a domain FQDN or single domain controller within the Realm forest."
                Result = $Result.NotTested
            }
        }
    }
    CepServerEndpoint = [PSCustomObject]@{
        Title = $Categories.CepServerEndpoint
        Tests = [PSCustomObject]@{
            CepDnsRecord = [PSCustomObject]@{
                Title = $ValidationTitles.CepDnsRecord
                Description = "The CEP Server must resolve to a DNS A record and not CNAME. This is a hard requirement by Microsoft's implementation of kerberos authentication."
                Result = $Result.NotTested
            }
            CepTlsPortAccess = [PSCustomObject]@{
                Title = $ValidationTitles.CepTlsPortAccess
                Description = "The CEP Server must accessible over port 443."
                Result = $Result.NotTested
            }
            CepBuildChain = [PSCustomObject]@{
                Title = $ValidationTitles.CepBuildChain
                Description = "The CEP Server TLS certificate must be issued by CA chain with a Root trusted by the local machine certificate store."
                Result = $Result.NotTested
            }
        }
    }
    CertTemplates = [PSCustomObject]@{
        Title = $Categories.CertTemplates
        Tests = [PSCustomObject]@{
            CertTemplateAutoenroll = [PSCustomObject]@{
                Title = $ValidationTitles.CertTemplateAutoenroll
                Description = "Authoenrollment 'Allow' access is required for a security group to enroll a certificate through Group Policy."
                Result = $Result.NotTested
            }
            CertTemplateGroupMembership = [PSCustomObject]@{
                Title = $ValidationTitles.CertTemplateGroupMembership
                Description = "A computer, or user, must belong to a security group with autoenrollment 'Allow' access on a certificate template mapped in the EJBCA MSAE Alias."
                Result = $Result.NotTested
            }
        }
    }
}