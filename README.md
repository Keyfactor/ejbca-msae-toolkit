# EJBCA Microsoft Auto-Enrollment (MSAE) Tool Kit

The purpose of this toolkit is to provide users with the ability to properly validate their Active Directory configuration of the EJBCA MSAE integration.

## Scope

* It currently provides tools to help execture different configuration steps in an MSAE configuration

## Requirments
### PowerShell Version

The current version of this tool has only been tested on PowerShell 5.1 and 7.1.

### Environment

* User with the following administrative access:
  * Create/modify Service Accounts
  * Create/modify Certificate Templates

* The tool is run on one of the following:
  * Domain Controller
  * Member Server

## Getting Started
1. Open a Powershell console as Admin on a Windows Server (Domain Controller or Member Server)

1. Navigate to the msae-toolkit directory and open the configuration file. Populate any known values, save, and close.
    ```pwsh
    notepad .\main.conf
    ```

1. Launch the main script.
    ```pwsh
    .\toolkit.ps1
    ```

1. The console will display the available Tools and Options.
    ```pwsh
    Welcome to the Keyfactor Delivery MSAE PowerShell Toolbox! Select one of the tools below to get started. To get more information about each tool, select the README.
   
   .\toolkit [tool] [options]
   
   Tools
      validate                       Validate an existing, or partially configured, MSAE integration.
    
   Utilities
      acctcreate                     Create and configure a new service account to use in an MSAE integration.
      cepconfig                      Configure the Certificate Enrollment Policy (CEP) endpoint (EJBCA).
      kerbcreate                     Generate Keytab and Krb5.conf files based Active Directory, Policy Server, and Service Account values.
      kerbdump                       Dump the contents of an existing keytab file.
      tempcreate                     Clone an existing template or create a new certificate template based on a Computer or User context.
      tempperms                      Grants autoenrollment permissions to a defined security group on an existing certificate template.
   
   
   Options
      -noninteractive                Suppress prompts. Does not include prompts for undefined variables.
      -configfile                    Configuration file containing predefined parameters vand values. Default: main.conf
      -debug                         Enable debug logging and additional features
      -help                          Print tool help
   
   Configuration File
     The following values can be prepopulated in the config file in the section name from the description.
   
      Name                           Service Account. Active Directory service account.
      Password                       Service Account. Active Directory service account password.
      Expiration                     Service Account. Days the service account will be valid for (Account Creation).
      OrgUnit                        Service Account. Common Name, or Distinguished Name, of service account organization unit in Active Directory.
      Hostname                       Policy Server. EJBCA Policy Server hostname containing the MSAE alias. Ex: policy-server.keyfactor.com.
      Alias                          Policy Server. Name of configured msae alias in EJBCA.
      Policy                         Policy Server. Name of EJBCA Policy Name configured in the msae alias.
      Keytab                         Kerberos. Absolute path to keytab.
      Krb5                           Kerberos. Absolute path to krb5 conf.
      Context                        Template. Group Policy configuration context. Options: Computer or User
      Computer                       Template. Computer context autoenrollment template name.
      ComputerGroup                  Template. Computer context autoenrollment security group name.
      User                           Template. User context autoenrollment template name.
      UserGroup                      Template. User context autoenrollment security group name.
   
   Examples
   .\toolkit.ps1 acctcreate
   .\toolkit.ps1 validate -configfile .\tests\testing.conf -noninteractive
    ```

1. Run a specific tool using one of the positional parameters with all console prompts
    ```pwsh
    .\toolkit.ps1 acctcreate
    ```

### Configuration File

A configuration file is provided to allow the prepopulate of parameter values. This reduces the number of prompts that may appear asking for values when a tool is selected. It is recommended to update this configuration file when an available variable defined in the file has a known value.

* Leave empty configurations commented out if they do not have a value

```pwsh
.\toolkit.ps1 acctcreate -configfile "prod.conf"
```

## Logging

* All actions are written to a 'main.log' file located in the toolkit root directory 
* The log appends new entries to the Tool Kit and does not overwrite. If you wish to overwrite, you will need to delete the log file before each run. **Be careful as this might erase essential information to a support case**.
* Configuration different log levels include INFO and DEBUG.

## Under Development
### Configuration Wizard

This will allow the user to completely deploy EJBCA MSAE in their enterprise environment with the MSAE Tool Kit. There might be limitations based on existing enterprise Role-Based Access Controls (RBAC).

## Support

We welcome contributions. This Tool Kit is open source and community supported, meaning that no SLA is applicable. 

* To report a problem or suggest a new feature, use the **[Issues](../../issues)** tab. 
* If you want to contribute actual bug fixes or proposed enhancements, use the **[Pull requests](../../pulls)** tab.
