
$ValidateButton_Click = {

    $error.clear()
    try {
        #Create ToolKit log file
        $LogFileCreatedSuccess.ForeColor = 'orange'
        $LogFileCreatedSuccess.Text = 'Creating tool kit log file...'

        New-Item $logFile -ErrorAction Stop

        $LogFileCreatedSuccess.ForeColor = 'green'
        $LogFileCreatedSuccess.Text = 'The Tool Kit log was successully created.'
        WriteLog "INFO: The Toolkit log file was successfully created in $logFile"

            } catch { 

                if($error -like '*already exists*'){
                    $LogFileCreatedSuccess.ForeColor = 'green'
                    $LogFileCreatedSuccess.Text = 'The Tool Kit log already exists'
                    WriteLog "INFO: The Tool Kit log already exists"
        
                    } else {

                        $LogFileCreatedSuccess.ForeColor = 'red'
                        $LogFileCreatedSuccess.Text = $error
                        WriteLog "ERROR: $error"
                        $FailedValidation.Enabled = $true
                        }
                    }
        
    if($LogFileCreatedSuccess.ForeColor.Name -eq 'green'){

        try {
            #Get username
            $UserName.ForeColor = 'orange'
            $UserName.Text = 'Getting user name...'
            $Global:ClientUser = $env:USERNAME

            #Return username if not null
            if($Global:ClientUser -ne $null){
                $UserName.ForeColor = 'green'
                $UserName.Text = $Global:ClientUser
                WriteLog "INFO: The username executing this tool is '$Global:ClientUser'"
                    }

            } catch {

                $UserName.ForeColor = 'red'
                $UserName.Text = $error
                WriteLog "ERROR: $error"
                # $User.Text = 'Failed to retrieve the username of the account running the tool'
                # Write-Log ERROR "Failed to retrieve the username of the account running the tool"
                #Prevents next button from appearing
                $FailedValidation.Enabled = $true
                }
            

            try {

                #Get computer name
                $ComputerName.ForeColor = 'orange'
                $ComputerName.Text = "Getting computer name..." 
                $Global:ClientComputer = $env:COMPUTERNAME

                #Set-Variable "clientComputer" -Value $CurrentMachine -Scope Global

                #Return computer name if not null
                if($Global:ClientComputer -ne $null){
                    $ComputerName.ForeColor = 'green'
                    $ComputerName.Text =$Global:ClientComputer
                    WriteLog "INFO: The computer name executing this tool is '$Global:ClientComputer'"
                        }

                    } catch {

                        $ComputerName.ForeColor = 'red'
                        $ComputerName.Text = "Failed to retrieve the computer name." 
                        WriteLog "ERROR: $error"
                        #Prevents next button from appearing
                        $FailedValidation.Enabled = $true
                        }

                try {

                    #Get domain name
                    $Domain.ForeColor = 'orange'
                    $Domain.Text = 'Getting domain name...'
                    $Global:DomainFQDN = systeminfo | findstr /i "domain"

                    } catch {

                        if($Global:DomainFQDN -eq $null){
                        $Domain.ForeColor = 'red'
                        $Domain.Text = 'Failed to retrieve the name of the domain'
                        WriteLog "ERROR: $error"
                        #Prevents next button from appearing
                        $FailedValidation.Enabled = $true
                            }
                        }

                    foreach($name in $Global:DomainFQDN){

                        if($name -like '*Domain:*'){

                            $Domain.ForeColor = 'green'
                            $Domain.Text = $name.Substring($name.IndexOf(":")+1).Trim()
                            $Global:DomainFQDN = $name.Substring($name.IndexOf(":")+1).Trim()
                            WriteLog "INFO: The domain is '$Global:DomainFQDN'"
                        }
                    }

                try {

                    $MemberServerStatus.ForeColor = 'orange'
                    $MemberServerStatus.Text = "Getting computer operating system..." 
                    $ComputerOS = (Get-CimInstance -ClassName Win32_OperatingSystem).caption 
                    } catch {

                        #Failed to retrieve status of member server
                        $MemberServerStatus.ForeColor = 'red'
                        $MemberServerStatus.Text = "Failed to determine if this server is a member of a domain" 
                        WriteLog "ERROR: $error"
                        #Prevents next button from appearing
                        $FailedValidation.Enabled = $true
                        }
                    
                        #If computer is a member server the script will continue
                        #If computer is not a member server the script will stop
                        if($ComputerOS -like '*Windows Server*'){

                            #Computer is a member server
                            $MemberServerStatus.ForeColor = 'green'
                            $MemberServerStatus.Text = "This is a member server" 
                            WriteLog "INFO: The operating system is $ComputerOS"

                            try{

                                #Gets installation status of ADDS
                                $AddsInstallStatus.ForeColor = 'orange'
                                $AddsInstallStatus.Text = "Getting ADDS RSAT tool status..." 
                                $AddsInstalled = Get-WindowsFeature -Name RSAT-ADDS-Tools | Select-Object InstallState

                                } catch {

                                    #Throw error if failed to retrieve the list of Windows Features
                                    $AddsInstallStatus.ForeColor = 'red'
                                    $AddsInstallStatus.Text = "Failed to retrieve the status of the ADDS RSAT tool" 
                                    WriteLog "ERROR: $error"
                                    #Prevents next button from appearing
                                    $FailedValidation.Enabled = $true
                                    }

                                if($AddsInstalled.InstallState -eq 'Installed'){

                                    #Return tools are already installed
                                    $AddsInstallStatus.ForeColor = 'green'
                                    $AddsInstallStatus.Text = "Already installed" 
                                    WriteLog "INFO: The ADDS RSAT tool was already installed"

                                    } else {

                                        try {

                                            #Install tools
                                            $AddsInstallStatus.ForeColor = 'orange'
                                            $AddsInstallStatus.Text = "Intalling ADDS RSAT tool..." 

                                            Install-WindowsFeature -Name RSAT-ADDS-Tools
                                            $AddsInstallStatus.ForeColor = 'green'
                                            $AddsInstallStatus.Text = "Successfully installed" 
                                            WriteLog "INFO: The AD DS and LDS tool tool successfully installed"
                                
                                            } catch {
                                            
                                                #Throw error if caught
                                                $AddsInstallStatus.ForeColor = 'red'
                                                $AddsInstallStatus.Text = "Not successfully installed. Refer to the $logFile for more information"
                                                WriteLog "ERROR: $error"
                                                #Prevents next button from appearing
                                                $FailedValidation.Enabled = $true
                                                }
                                        } 


                                #Check if ADCS Tools are installed
                                $AdcsInstalled.ForeColor = 'orange'
                                $AdcsInstalled.Text = "Getting ADCS RSAT tool status..." 
                                $rsatAdcsInstalled = Get-WindowsFeature -Name RSAT-ADCS | Select-Object InstallState

                                
                                if($rsatAdcsInstalled.InstallState -eq 'Installed'){

                                    #Return tools are already installed
                                    $AdcsInstalled.ForeColor = 'green'
                                    $AdcsInstalled.Text = "Already installed" 
                                    WriteLog "INFO: The AD CS tool was already installed"

                                    } else {

                                        try{

                                            #ADCS tools intalling
                                            $AdcsInstalled.ForeColor = 'orange'
                                            $AdcsInstalled.Text = "Intalling Certificate Template management..." 
                                            Install-WindowsFeature -Name RSAT-ADDS-Tools

                                            #ADCS successfully isnstalled
                                            $AdcsInstalled.ForeColor = 'green'
                                            $AdcsInstalled.Text = "Successfully installed" 
                                            WriteLog "INFO: The AD CS tool successfully installed"
                                
                                            } catch {

                                                #ADCS failed to install
                                                $AdcsInstalled.ForeColor = 'red'
                                                $AdcsInstalled.Text = "Not successfully installed"
                                                WriteLog "ERROR: Not successfully installed. Refer to the $logFile for more information"
                                                #Prevents next button from appearing
                                                $FailedValidation.Enabled = $true
                                                }
                                        }

                                } else {
                                
                                    #Not a member server and script will stop
                                    $MemberServerStatus.ForeColor = 'red'
                                    $MemberServerStatus.Text = "This is not a member server. Run Tool Kit from a domain-joined member server." 
                                    $AddsInstallStatus.ForeColor = 'gray'
                                    $AddsInstallStatus.Text = "Skipped because Member Server validation failed"
                                    $AdcsInstalled.ForeColor = 'gray'
                                    $AdcsInstalled.Text = "Skipped because Member Server validation failed"
                                    WriteLog "ERROR: The tool was run on a non-member server. Run this tool on a member-server."
                                    
                                    #Prevents next button from appearing
                                    $FailedValidation.Enabled = $true
                                        }
                                    }
                                        
#If any of the validation checks, the Next button is not added and the user is told to fix failed validation
if($FailedValidation.Enabled = $true){

    $FailedValidation.Text = "The validation failed. Please fix the items in red using the Tool Kit log output located at $PSScriptRoot\toolkit.log before running again on this computer."

         } else {
            
            
            $SysPrepNext_Click = {

                $SystemPrep.DialogResult = 'OK'
                $SystemPrep.Close()
                    }

            }
        }

$SysPrepCancel_Click = {

    $SystemPrep.DialogResult = 'Cancel'
    $SystemPrep.Close()
        } 

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'sysprep_form.designer.ps1')

$SystemPrep.ShowDialog()