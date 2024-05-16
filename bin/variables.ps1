
# Main
$ForestDistinguishedName = $((Get-ADDomain).DistinguishedName)

# Template security
$ObjectSecurityAutoenrollGUID = "a05b8cc2-17bc-4802-a710-e7c15ab866a2"
$ObjectSecurityEnrollGUID = "0e10c968-78fb-11d2-90d4-00c04f79dc55"

$Exceptions = @{
    AlreadyExists = "{0} already exists."
}

$Main = @{
    Description = (
        "Welcome to the Keyfactor Delivery MSAE PowerShell Toolbox! Select one of the tools below to get started. To get more information about each tool, select the README."
    )
}

$Tools = @(
    [PSCustomObject]@{
        Title = "Create Service Account"
        Script = "create_service_account.ps1"
        Readme = [String]
        Description = "Create and configure a new service account to use in an MSAE integration."
        DescriptionVerbose = (
            "This tool creates and configures a new service account to use in an MSAE integration.",
            "It is intended to be used in a lab or testing environment."
        )
    }
    [PSCustomObject]@{
        Title = "Create Kerberos Files"
        Script = "create_kerberos_files.ps1"
        Readme = [String]
        Description = "Generate Keytab and Krb5.conf files based Active Directory, Policy Server, and Service Account values."
        DescriptionVerbose = (
            "Generate Keytab and Krb5.conf files based Active Directory, Policy Server, and Service Account values."
        )
    }
    [PSCustomObject]@{
        Title = "Create Certificate Template"
        Script = "create_certificate_template.ps1"
        Readme = [String]
        Description = "Clone an existing template or create a new certificate template based on a Computer or User context."
        DescriptionVerbose = (
            "Clone an existing template or create a new certificate template based on a Computer or User context."
        )
    }
)


$Strings = @{
    GeneralException = "A general exception occurred and the tool was exited. Refer to the log for more details."
    MessageServiceAccount = "Enter the name of the Service Account used for MSAE."
    ObjectAvailable = "'{0}' does not exist in active directory and is available for use."
    DoesNotExist = "'{0}' does not exist. Provide another name."
    AlreadyExists = "'{0}' already exists. Provide another name."
    ObjectFound = "Found {0}: {1}."
    SuccessfullyCreated = "Successsfully created {0} '{1}'."
}