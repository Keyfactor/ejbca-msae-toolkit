# Start validation
$error.clear()

try {
    #Create ToolKit log file
    $prerequisitesCheckLogFile.ForeColor = 'orange'
    $prerequisitesCheckLogFile.Text = 'Log check: Creating Tool Kit log file...'

    New-Item $logFile -ErrorAction Stop

    Start-Sleep -s 2

    $prerequisitesCheckLogFile.ForeColor = 'green'
    $prerequisitesCheckLogFile.Text = 'Log check: The Tool Kit log was successully created!'
    WriteLog "INFO: Log creation - The Toolkit log file was successfully created in $logFile"

        } catch { 

            if($error -like '*already exists*'){
                $prerequisitesCheckLogFile.ForeColor = 'green'
                $prerequisitesCheckLogFile.Text = 'Log check: The Tool Kit log already exists!'
                WriteLog "INFO: Log creation - The Tool Kit log already exists"
    
                } else {

                    #$prerequisitesCheckLogFile.ForeColor = 'red'
                    $prerequisitesCheckLogFile.Text = $error
                    WriteLog "ERROR: Log creation - $error"
                    $prerequisitesCheckLogFile.Enabled = $true
                    }
            }

if($prerequisitesCheckLogFile.ForeColor.Name -eq 'green'){

    try {

        $prerequisitesCheckServer.ForeColor = 'orange'
        $prerequisitesCheckServer.Text = "Server check: Getting computer operating system..." 
        $ComputerOS = (Get-CimInstance -ClassName Win32_OperatingSystem).caption 
        } catch {

            #Failed to retrieve status of member server
            $prerequisitesCheckServer.ForeColor = 'red'
            $prerequisitesCheckServer.Text = "Server check: Failed! Refer to the $logFile for more information" 
            WriteLog "ERROR: Server check - $error"
            #Prevents next button from appearing
            $FailedValidation.Enabled = $true
            }
        
            #If computer is a member server the script will continue
            #If computer is not a member server the script will stop
            if($ComputerOS -like '*Windows Server*'){

                #Computer is a member server
                $prerequisitesCheckServer.ForeColor = 'green'
                $prerequisitesCheckServer.Text = "Server check: Passed!" 
                WriteLog "INFO: Server Check - The operating system is $ComputerOS"

                try{

                    #Gets installation status of ADDS
                    $prerequisitesCheckADDS.ForeColor = 'orange'
                    $prerequisitesCheckADDS.Text = "ADDS check: Getting the ADDS feature status..." 
                    $AddsInstalled = Get-WindowsFeature -Name RSAT-ADDS-Tools | Select-Object InstallState

                    } catch {

                        #Throw error if failed to retrieve the list of Windows Features
                        $prerequisitesCheckADDS.ForeColor = 'red'
                        $prerequisitesCheckADDS.Text = "ADDS check: Failed! Refer to the $logFile for more information" 
                        WriteLog "ERROR: ADDS check - $error"
                        }

                    if($AddsInstalled.InstallState -eq 'Installed'){

                        #Return tools are already installed
                        $prerequisitesCheckADDS.ForeColor = 'green'
                        $prerequisitesCheckADDS.Text = "ADDS check: Already installed!" 
                        WriteLog "INFO: ADDS check - The ADDS tool was already installed"

                        } else {

                            try {

                                #Install tools
                                $prerequisitesCheckADDS.ForeColor = 'orange'
                                $prerequisitesCheckADDS.Text = "ADDS check: Intalling the ADDS feature..." 

                                Install-WindowsFeature -Name RSAT-ADDS-Tools
                                $prerequisitesCheckADDS.ForeColor = 'green'
                                $prerequisitesCheckADDS.Text = "ADDS check: Successfully installed!" 
                                WriteLog "INFO: ADDS check - The ADDS tool tool successfully installed"
                    
                                } catch {
                                
                                    #Throw error if caught
                                    $AddsInstallStatus.ForeColor = 'red'
                                    $AddsInstallStatus.Text = "ADDS check: Failed. Refer to the $logFile for more information"
                                    WriteLog "ERROR: ADDS check - $error"
                                    }
                            } 


                    #Check if ADCS Tools are installed
                    $prerequisitesCheckADCS.ForeColor = 'orange'
                    $prerequisitesCheckADCS.Text = "ADCS check: Getting the ADCS feature status..." 
                    $AdcsInstalled = Get-WindowsFeature -Name RSAT-ADCS | Select-Object InstallState

                    
                    if($AdcsInstalled.InstallState -eq 'Installed'){

                        #Return tools are already installed
                        $prerequisitesCheckADCS.ForeColor = 'green'
                        $prerequisitesCheckADCS.Text = "ADCS check: Already installed!" 
                        WriteLog "INFO: ADCS check - The AD CS tool was already installed"

                        } else {

                            try{

                                #ADCS tools intalling
                                $prerequisitesCheckADCS.ForeColor = 'orange'
                                $prerequisitesCheckADCS.Text = "ADCS check: Intalling Certificate Template management..." 
                                Install-WindowsFeature -Name RSAT-ADDS-Tools

                                #ADCS successfully isnstalled
                                $prerequisitesCheckADCS.ForeColor = 'green'
                                $prerequisitesCheckADCS.Text = "ADCS check: Passed!" 
                                WriteLog "INFO: ADCS check - The ADCS tool successfully installed"
                    
                                } catch {

                                    #ADCS failed to install
                                    $prerequisitesCheckADCS.ForeColor = 'red'
                                    $prerequisitesCheckADCS.Text = "ADCS check: Failed! Refer to the $logFile for more informatio"
                                    WriteLog "ERROR: ADCS check - $error"
                                    }
                            }

                    } else {
                    
                        #Not a member server and script will stop
                        $prerequisitesCheckServer.ForeColor = 'red'
                        $prerequisitesCheckServer.Text = "Server check: Failed! Run Tool Kit from a member server or domain controller" 
                        $prerequisitesCheckADDS.Text = "ADDS check: Skipped! Server validation failed"
                        $prerequisitesCheckADCS.Text = "ADCS check: Skipped! Server validation failed"
                        WriteLog "ERROR: Server check - Failed! The tool is being run on a non-server machine. The tool needs to be run on a Windows server."
                        
                            }
                
                        }   

        $close_Click = {

            $prerequisitesCheck.Close()
            # $userInputMenu.Focus()

        }
        
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot '..\form-designs\prerequisites_check_design.ps1')
$prerequisitesCheck.ShowDialog()