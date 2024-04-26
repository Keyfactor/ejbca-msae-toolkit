
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
        Title = "Create Kerberos Files"
        Script = "create_kerberos_files.ps1"
        Readme = "tool_config_wizard.txt"
        Description = "Generate Keytab and Krb5.conf files based Active Directory, Policy Server, and Service Account values."
    }
    [PSCustomObject]@{
        Title = "Create Certificate Template"
        Script = "create_certificate_template.ps1"
        Readme = "tool_config_wizard.txt"
        Description = "Clone an existing template or create a new certificate template based on a Computer or User context."
    }
)