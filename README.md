# EJBCA Microsoft Auto-Enrollment (MSAE) Tool Kit

The purpose of this toolkit is to provide users with the ability to properly validate their Active Directory configuration of the EJBCA MSAE integration. To improve usability for a wider audience, this toolkit provides the user with a User Interface vice requiring the user to execute a PowerShell script directly.  

## Scope

* It is designed to run on a domain that has already had MSAE configured and has been unsuccessful in auto-enrolling certificates or validating the Policy Server URL.
* Users can run the toolkit after configurating the environment and before attempting auto-enrollment to confirm their settings are correct. 
* All gathered information is logged and can be compressed for later use (see "Support Bundle").

## Requirments
### PowerShell Version

The current version of this tool has only been tested on PowerShell 5.1. This version is the most common among Active Directory enterprise environments.

**Future releases may support PS7 if the use-case is large enough**

### Environment

* User with the following administrative access:
  * Create/modify Service Accounts
  * Create/modify Certificate Templates

* The tool is run on one of the following:
  * Domain Controller
  * Member Server

## Features
### Validation

This feature will validate configured MSAE settings against Keyfactor MSAE implementation recommendations and industry best practices for Kerberos and Microsoft Active Directory. You will be asked to input data specific to your MSAE implementation and the validation process will confirm all configurations. All results will be provided to the user in the console

### Support Bundle

Users are given the option to generate a "support bundle" at the end of the toolkit. The bundle can be uploaded to a new or existing support ticket for additional troubleshooting by Keyfactor support.

## To Run

* PowerShell ISE (not automated privilege elevation.
  * Open an elevated PowerShell ISE console.
  * Open the 'tool-kit-container.ps1' .
  * Click 'Run'.

* PowerShell (configured with automated privelege elevation).
  * Right-click 'tool-kit-container.ps1'.
  * Click 'Run with PowerShell'.

## Logging

* All actions are written to a 'toolkit.log' file located in the same directory as 'tool-kit-container.ps1'. 
* The log appends new entries to the Tool Kit and does not overwrite. If you wish to overwrite, you will need to delete the log file before each run. **Be careful as this might erase essential information to a support case**.
* Current different log levels include INFO and DEBUG.

## Under Development
### Configuration Tool

This will allow the user to completely deploy EJBCA MSAE in their enterprise environment with the MSAE Tool Kit. There might be limitations based on existing enterprise Role-Based Access Controls (RBAC).

### Testing Tool

This option will allow a user to test auto-enrollment using MSAE. Additionally, users will be provided the option to use the Testing tool directly after the validation or configuration tool has been complete without having to restart the Tool Kit. 

### EJBCA Component Integration (optional)

* Import Certificate Profiles, End-Entity Profiles, and Syslogs into the Tool Kit for analysis and validation against previously provided user input.
* Provide input fields for MSAE alias fields for analysis.
* LDAP/LDAP bind verification using query.

## Support

We welcome contributions. This Tool Kit is open source and community supported, meaning that no SLA is applicable. 

* To report a problem or suggest a new feature, use the **[Issues](../../issues)** tab. 
* If you want to contribute actual bug fixes or proposed enhancements, use the **[Pull requests](../../pulls)** tab.
* Read more in our public documentation: **[Microsoft Auto-enrollment Configuration Guide](https://doc.primekey.com/ejbca/ejbca-operations/ejbca-operations-guide/ca-operations-guide/enrollment-protocol-configuration/microsoft-auto-enrollment-operations/microsoft-auto-enrollment-configuration-guide)**
