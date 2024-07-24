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

    Tools
        acctcreate           Create and configure a new service account to use in an MSAE integration.
        kerbcreate           Generate Keytab and Krb5.conf files based Active Directory, Policy Server, and Service Account values.
        kerbdump             Dump the content of an existing keytab file.

    Options
        -PolicyServer        Configurable. EJBCA Policy Server hostname containing the MSAE alias. Ex: policy-server.keyfactor.com
        -PolicyServerAlias   Configurable. Name of configured msae alias in EJBCA.
        -ServiceAccount      Configurable. Active Directory service account.
        -TemplateComputer    Configurable. Computer context autoenrollment template name.
        -ComputerGroup       Configurable. Computer context autoenrollment security group.
        -EnrollmentContext   Autoenrollment context
        -NonInteractive      Suppress prompts. Does not include prompts for undefined variables.
        -Configfile          Configuration file containing predefined parameters vand values. Default: main.conf
        -Help
    ```

1. Run a specific tool using one of the positional parameters with all console prompts
    ```pwsh
    .\toolkit.ps1 acctcreate
    ```

## Parameters

The available parmeter values that can be passed in one of the two methods below can be viewed with `-help`

### Configuration File

A configuration file is provided to allow the prepoluation of parameter values. This reduces the number of prompts that may appear asking for values when a tool is selected. It is recommended to update this configuration file when an available variable defined in the file has a known value.

* Leave empty configurations commented out if they do not have a value

```pwsh
.\toolkit.ps1 acctcreate -configfile "prod.conf"
```

### Commond Line

Parameter values can be passed on the CLI when launching a tool

```pwsh
.\toolkit.ps1 acctcreate -PolicyServer "ejbca.policyserver.com" -ServiceAccount "ra-service"
```

## Logging

* All actions are written to a 'main.log' file located in the toolkit root directory 
* The log appends new entries to the Tool Kit and does not overwrite. If you wish to overwrite, you will need to delete the log file before each run. **Be careful as this might erase essential information to a support case**.
* Configuration different log levels include INFO and DEBUG.

## Under Development
### Configuration Tool

This will allow the user to completely deploy EJBCA MSAE in their enterprise environment with the MSAE Tool Kit. There might be limitations based on existing enterprise Role-Based Access Controls (RBAC).

### Testing Tool

This option will allow a user to test auto-enrollment using MSAE. Additionally, users will be provided the option to use the Testing tool directly after the validation or configuration tool has been complete without having to restart the Tool Kit. 

## Support

We welcome contributions. This Tool Kit is open source and community supported, meaning that no SLA is applicable. 

* To report a problem or suggest a new feature, use the **[Issues](../../issues)** tab. 
* If you want to contribute actual bug fixes or proposed enhancements, use the **[Pull requests](../../pulls)** tab.
