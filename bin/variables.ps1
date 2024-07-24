
# Template security
$Global:ObjectSecurityAutoenrollGUID = "a05b8cc2-17bc-4802-a710-e7c15ab866a2"
$Global:ObjectSecurityEnrollGUID = "0e10c968-78fb-11d2-90d4-00c04f79dc55"

$Global:KerberosEncryptionTypes = @(
    @{Name = "DES-CBC-CRC";Type = "0x1"}
    @{Name = "DES-CBC-MD5";Type = "0x3"}
    @{Name = "AES128-SHA1";Type = "0x11"}
    @{Name = "AES256-SHA1";Type = "0x12"}
    @{Name = "RC4-HMAC";Type = "0x17"}
)

$Global:AvailableTools = @(
    [PSCustomObject]@{
        Title = "Create MSAE Service Account"
        Type = "ad"
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
            "ServiceAccount",
            "ServiceAccountPassword",
            "ServiceAccountOrgUnit",
            "PolicyServer"
        )
        OptionalVars = @(
            "ServiceAccountExpiration"
        )
    }
    [PSCustomObject]@{
        Title = "Create Kerberos Files"
        Type = "kerberos"
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
        Type = "kerberos"
        Name = "kerbdump"
        Script = "tool_kerberos.ps1"
        Description = "Dump the contents of an existing keytab file."
        DescriptionAdditional = @()
        Prerequisites = @(
            "Existing keytab file."
        )
        RequiredVars = @(
            "Keytab",
            "Krb5"
        )
    }
    [PSCustomObject]@{
        Title = "Create Certificate Template"
        Type = "gpo"
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
        Type = "gpo"
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
    #     Name = 'Wizards'
    #     Tools = @(
    #         [PSCustomObject]@{
    #             Title = "Cnfiguration Wizard"
    #             Type = "wizard"
    #             Name = "config"
    #             Script = "wizard_config.ps1"
    #             Description = "Cconfiguration of MSAE integration. Combines multiple tools in this toolkit."
    #             Readme = "Cconfiguration of MSAE integration. Combines multiple tools in this toolkit."
    #             RequiredVars = @(
    #                 "ServiceAccount",
    #                 "PolicyServer",
    #                 "PolicyServerAlias",
    #                 "ServiceAccount",
    #                 "CertificateTemplate"
    #             )
    #         }
    #     )
    # }
    
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
    # [PSCustomObject]@{
    #     Name = 'Group Policy'
    #     Tools = @(
    #         [PSCustomObject]@{
    #             Title = "Create Certificate Template"
    #             Type = "gpo"
    #             Name = "tempcreate"
    #             Script = "tool_cert_template.ps1"
    #             Description = "Clone an existing template or create a new certificate template based on a Computer or User context."
    #             Readme = (
    #                 "Clone an existing template or create a new certificate template based on a Computer or User context."
    #             )
    #         }
    #         [PSCustomObject]@{
    #             Title = "Modify Certificate Template"
    #             Type = "gpo"
    #             Name = "tempmodify"
    #             Script = "tool_cert_template.ps1"
    #             Description = "Add enroll and autoenrollment permissions to an existing certificate template."
    #             Readme = (
    #                 "Add enroll and autoenrollment permissions to an existing certificate template."
    #             )
    #         }
    #         [PSCustomObject]@{
    #             Title = "Configure CEP"
    #             Type = "gpo"
    #             Name = "cepconfig"
    #             Script = "tool_cep_config.ps1"
    #             Description = "Configure the Certificate Enrollment Policy (CEP) endpoint (EJBCA)."
    #             Readme = $ReadMeCepConfig
    #             RequiredVars = @(
    #                 "PolicyServer",
    #                 "PolicyServerAlias",
    #                 "ServiceAccount",
    #                 "EnrollmentContext"
    #             )
    #         }
    #     )
    # }
            
)

$StringsExceptions = @{
    General = "A general exception occurred and the tool was exited. Refer to the log for more details."
    ReferToLog = "{0}. Refer to the log for more details."
}

$StringsGeneral = @{
    ToolSelection = "Enter a tool from the available list above"
    ToolNonSelection = "Invalid selection. Enter a tool from the list above"
    ClearVariable = "Clearing temporary variable {0}={1}."
    GeneralException = "An exception occurred and the tool was exited. Refer to the log for more details."
    

}

$StringsObject = @{
    AlreadyExists = "{0} '{1}' already exists. Provide another name"
    Available = "'{0}' does not exist in active directory and is available for use."
    Created = "Successsfully created {0} '{1}'." 
    DifferentName = "Provide a different name or create a new {0} to continue."
    DoesNotExist = "{0}: '{1}' does not exist. Provide another name"
    Found = "Found {0}: {1}."
    Search = "Searching for a {0} that matches '{1}'"
    WhiteSpaceNoChoice = "The user chose not to provide a name without white spaces or let theGetServiceAccountPassword tool automatically change it."
    UsingCachedValue = "Using cached value {0}: {1} "
    
}

$StringsPrompts = @{
    GetFile = "Enter the full path to the {0}"
    GetPolicyServer = "Enter the FQDN of the EJBCA CEP Server"
    GetPolicyServerAlias = "Enter the name of the MSAE alias (case-sensitve)"
    GetServiceAccount = "Enter the name of the Service Account used for MSAE"
    GetServiceAccountPassword = "Enter the password for the MSAE service account"
    GetServiceAccountOrgUnit = "Enter the Organization Unit to create the Service Account in"
    GetAutoenrollSecurityGroup = "Enter the name for the Security Group to add to the certificate template with autoenrollment permissions"
    GetCertificateTemplate = "Enter the name for the new Computer context certiticate template."
    ChoiceMessageAutomateFix = "Would you like the automatically fix the issue and try again?"
    ChoiceMessageAutomateFixChoices = @("Automate","Quit")
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