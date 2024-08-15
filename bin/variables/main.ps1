
$Global:ToolKitMenu = [PSCustomObject]@{
    Description = "Welcome to the Keyfactor Delivery MSAE PowerShell Toolbox! Select one of the tools below to get started. To get more information about each tool, select the README."
    Usage = @(
        ".\toolkit [tool] [options]"
    )
    Examples = @(
        ".\toolkit.ps1 acctcreate",
        ".\toolkit.ps1 validate -configfile .\tests\testing.conf -noninteractive"
    )
}

$Global:AvailableTools = @(
    [PSCustomObject]@{
        Title = "[Create MSAE Service Account]"
        Type = "utility"
        Name = "acctcreate"
        Script = "tool_acct_create.ps1"
        Description = "Create and configure a new service account to use in an MSAE integration."
        DescriptionAdditional= @(
            "Account attributes include Service Principal Name and Support Encryption keys."
        )
        Prerequisites = @(
            "Fully Qualified Domain Name (FQDN) of a single EJBCA Policy Server or Load Balancer in front of multiple EJBCA Policy Servers."
        )
        RequiredVars = @(
            "PolicyServer",
            "ServiceAccount",
            "ServiceAccountPassword",
            "ServiceAccountOrgUnit"
        )
        OptionalVars = @(
            "ServiceAccountExpiration"
        )
    }
    [PSCustomObject]@{
        Title = "Configure Active Directory Certificate Enrollment Policy (CEP)"
        Type = "utility"
        Name = "cepconfig"
        Script = "tool_cep_config.ps1"
        Description = "Configure the Certificate Enrollment Policy (CEP) endpoint (EJBCA)."
        DescriptionAdditional = @(
            "Provides descriptive translation of error messages that may be returned during configuration"
        )
        Prerequisites = @(
            "Service Account created",
            "Keytabe created",
            "Reachable Policy Server endpoint"
        )
       RequiredVars = @(
            "PolicyServer",
            "PolicyServerAlias",
            "ServiceAccount",
            "EnrollmentContext"
        )
    }
    [PSCustomObject]@{
        Title = "Create Kerberos Files"
        Type = "utility"
        Name = "kerbcreate"
        Script = "tool_kerberos.ps1"
        Description = "Generate Keytab and Krb5.conf files based Active Directory, Policy Server, and Service Account values."
        DescriptionAdditional = @(
            "Created with a single encryption key type: AES-256.",
            "Service Account password is used during creation.",
            "Files saved in the user home directory"
        )
        Prerequisites = @(
            "Existing service account create manually or with the 'acctcreate' tool."
        )
        RequiredVars = @(
            "ServiceAccount",
            "ServiceAccountPassword",
            "PolicyServer"
        )
    }
    [PSCustomObject]@{
        Title = "Dump Keytab"
        Type = "utility"
        Name = "kerbdump"
        Script = "tool_kerberos.ps1"
        Description = "Dump the contents of an existing keytab  and krb5 conf file."
        DescriptionAdditional = @()
        Prerequisites = @(
            "Existing keytab file."
            "Existing krb5 conf file."
        )
        RequiredVars = @(
            "Keytab",
            "Krb5"
        )
    }
    [PSCustomObject]@{
        Title = "Create Certificate Template"
        Type = "utility"
        Name = "tempcreate"
        Script = "tool_cert_template.ps1"
        Description = "Clone an existing template or create a new certificate template based on a Computer or User context."
        DescriptionAdditional = @(
            "Creates a new certificate template",
            "Grants autoenrollment permissions to a defined security group"
        )
        Prerequisites = @(
            "Active directory security group to configure with autoenrollment permissions."
        )
        RequiredVars = @(
            "EnrollmentContext"
            "TemplateComputer",
            "TemplateComputerGroup"
        )
    }
    [PSCustomObject]@{
        Title = "Modify Certificate Template"
        Type = "utility"
        Name = "tempperms"
        Script = "tool_cert_template.ps1"
        Description =  "Grants autoenrollment permissions to a defined security group on an existing certificate template."
        DescriptionAdditional = @()
        Prerequisites = @(
            "Existing certificate template",
            "Active directory security group to configure with autoenrollment permissions."
        )
        RequiredVars = @(
            "TemplateComputer",
            "TemplateComputerGroup"
        )
    }
    # [PSCustomObject]@{
    #     Title = "Configuration Wizard"
    #     Type = "tool"
    #     Name = "config"
    #     Script = "wizard_config.ps1"
    #     Description = "Cconfiguration of MSAE integration. Combines multiple tools in this toolkit."
    #     DescriptionAdditional = ""
    #     Prerequisites = @(
    #         "Fully Qualified Domain Name (FQDN) of a single EJBCA Policy Server or Load Balancer in front of multiple EJBCA Policy Servers."
    #         "Active directory security group to configure with autoenrollment permissions.",
    #         "Reachable Policy Server endpoint"
    #     )
    #     RequiredVars = @(
    #         "ServiceAccount",
    #         "PolicyServer",
    #         "PolicyServerAlias",
    #         "ServiceAccount",
    #         "CertificateTemplate"
    #     )
    # }
    [PSCustomObject]@{
        Title = "Configuration Validator"
        Type = "tool"
        Name = "validate"
        Script = "tool_validator.ps1"
        Description = "Validate an existing, or partially configured, MSAE integration."
        DescriptionAdditional = @(
            "A set a tests against known MSAE configuration issues."
        )
        Prerequisites = @(
            "Service Account",
            "Keytab and Krb5 Conf Files",
            "Certificate Template configured for MSAE"
        )
        RequiredVars = @(
            "Account",
            "Hostname",
            "Alias",
            "Keytab",
            "Krb5",
            "ComputerTemplate"
        )
    }
    
    # [PSCustomObject]@{
    #     Name = 'Certificates'
    #     Tools = @(
    #         [PSCustomObject]@{
    #             Title = "Build Certificate Chain"
    #             Type = "certificates"
    #             Name = "buildchain"
    #             Script = "tool_certificates.ps1"
    #             Description = "Build certificate chain using a entity certificate."
    #             Readme = ""
    #         }
    #         [PSCustomObject]@{
    #             Title = "Download CA Issuer"
    #             Type = "certificates"
    #             Name = "getcaissuer"
    #             Script = "tool_certificates.ps1"
    #             Description = "Download certificate from provided certificate CA Issuer extension."
    #             Readme = ""
    #         }
    #     )
    # }
)

$Global:AvailableConfigValues = @(
    
    # Service Account
    [PSCustomObject]@{ Name = "AccountName"                 ; Description = "Active Directory service account."}
    [PSCustomObject]@{ Name = "AccountPassword"             ; Description = "Active Directory service account password."}
    [PSCustomObject]@{ Name = "AccountExpiration"           ; Description = "Days the service account will be valid for (Account Creation)."}
    [PSCustomObject]@{ Name = "AccountOrgUnit"              ; Description = "Common Name, or Distinguished Name, of service account organization unit in Active Directory."}

    # Policy Server
    [PSCustomObject]@{ Name = "PolicyServer"                ; Description = "EJBCA Policy Server hostname containing the MSAE alias. Ex: policy-server.keyfactor.com."}
    [PSCustomObject]@{ Name = "PolicyServerAlias"           ; Description = "Name of configured msae alias in EJBCA."}
    [PSCustomObject]@{ Name = "PolicyServerAliasPolicy"     ; Description = "Name of EJBCA Policy Name configured in the msae alias."}

    # Kerberos
    [PSCustomObject]@{ Name = "KerberosKeytab"              ; Description = "Absolute path to keytab."}
    [PSCustomObject]@{ Name = "KerberosKrb5"                ; Description = "Absolute path to krb5 conf."}

    # Templates
    [PSCustomObject]@{ Name = "TemplateContext"             ; Description = "Group Policy configuration context. Options: Computer or User"}
    [PSCustomObject]@{ Name = "TemplateComputer"            ; Description = "Computer context autoenrollment template name."}
    [PSCustomObject]@{ Name = "TemplateComputerGroup"       ; Description = "Computer context autoenrollment security group name."}
    [PSCustomObject]@{ Name = "TemplateUser"                ; Description = "User context autoenrollment template name."}
    [PSCustomObject]@{ Name = "TemplateUserGroup"           ; Description = "User context autoenrollment security group name."}
)

$Global:ToolkitMenuOptions = @(
    [PSCustomObject]@{ Name = "noninteractive"              ; Description = "Suppress all prompts. The toolkit will exit if a required variable is undefined."}
    [PSCustomObject]@{ Name = "configfile"                  ; Description = "Configuration file containing predefined parameters vand values. Default: main.conf"}
    [PSCustomObject]@{ Name = "debug"                       ; Description = "Enable debug logging and additional features"}
    [PSCustomObject]@{ Name = "help"                        ; Description = "Print tool help"}
)

$Global:KerberosEncryptionTypes = @(
    @{Name = "DES-CBC-CRC";Type = "0x1"}
    @{Name = "DES-CBC-MD5";Type = "0x3"}
    @{Name = "AES128-SHA1";Type = "0x11"}
    @{Name = "AES256-SHA1";Type = "0x12"}
    @{Name = "RC4-HMAC";Type = "0x17"}
)

$Global:FontColor = @{
    Base = "Gray"
    Warn = "Yellow"
    Error = "Red"
    Success = "Green"
}

$Global:Strings = @{
    AlreadyExists = "{0} '{1}' already exists. Provide another name"
    Available = "'{0}' does not exist in active directory and is available for use."
    Created = "Successsfully created {0} '{1}'." 
    DifferentName = "Provide a different name or create a new {0} to continue."
    DoesNotExist = "Provided {0} '{1}' does not exist. Provide another value"
    Found = "Found {0}: {1}."
    NotValidated = "Provided {0} '{1}' was not validated."
    RegisterImported = "Setting {0} as '{1}' from imported configuration file."
    RegisterUserProvided = "Setting {0} as '{1}' based on user provied input."
    Search = "Searching for a {0} that matches '{1}'"
    WhiteSpaceNoChoice = "The user chose not to provide a name without white spaces or let theGetServiceAccountPassword tool automatically change it."
    UndefinedNonInterfactive = "{0} Error: A value for '{1}' was not found in the configuration file or as a parameter."
    UsingCachedValue = "Using cached value {0}: {1} "
}

$Global:Exceptions = @{
    General = "A general exception occurred and the tool was exited. Refer to the log for more details."
    ConditionalChecks = "Failed all conditional checks when registering Certificate Template."
    ReferToLog = "{0}. Refer to the log for more details."
}

$Global:WinErrors = @{
    AccessDenied = [PSCustomObject]@{
        Code = "0x803d0005"
        Message = "Access was denied by EJBCA."
    }
    NameNotResolved = [PSCustomObject]@{
        Code = "0x80072ee7"
        Message = "The server name or address could not be resolved."
    }
    EndpointFailure = [PSCustomObject]@{
        Code = "0x803d000f"
        Message = "The remote endpoint could not process the request"
    }
}

$Global:MsaeErrors = @{
    MissingKerbTicket = "A ticket was not be issued by the KDC because a Service Princpal Name that matches the provided policy server hostname was not found in active directory."
}