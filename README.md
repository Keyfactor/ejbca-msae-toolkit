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

## Configuration File

A configuration file is provided to allow the prepoluation of MSAE values. This reduces the number of prompts that may appear asking for values when a tool is selected. It is recommended to update this configuration file when an available variable defined in the file has a known value.

* Leave empty configurations commented out if they do not have a value

## Tools
### Create Service Account

Create service account with the attributes required to support an MSAE integration configuration.

### Create Kerberos Files

Generates Keytab and Krb5.conf files based Active Directory, Policy Server, and Service Account values.

### Create Certificate Template

Create a new certificate template based on a Computer or User context.

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

1. Enter a selection number at the main menu.
    ```pwsh
    Welcome to the Keyfactor Delivery MSAE PowerShell Toolbox! Select one of the tools below to get started. To get more in
    formation about each tool, select the README.

    Choice   Title                          Description                                                                   
    ------   -----                          -----------                                                                   
    1        Create Kerberos Files          Generate Keytab and Krb5.conf files based Active Directory, Policy Server,    
                                            and Service Account values.                                                   
    2        Create Certificate Template    Clone an existing template or create a new certificate template based on a    
                                            Computer or User context.                                                     

    Selection: 2
    ```

1. Complete the prompts as the appear in the console and enter 'quit' or Crtl-C when you wish to exit.


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
