# Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear();

# $logFile = "$PSScriptRoot\toolkit.log"

# # Start validation


# function WriteLog
# {
# Param ([string]$logString)
# $timeStamp = (Get-Date).toString("yyyyMMdd HH:mm:ss")
# $logMessage = "$timeStamp $logString"
# Add-content $logFile -value $logMessage
# }

$check_Click = {

# remove description control from form
$prerequisites.Controls.Remove($prerequisitesDescription)
$prerequisites.Controls.Remove($prerequisitesCheckButton)

# add check controls to form
$prerequisites.Controls.Add($prerequisitesCheckTitle)
$prerequisites.Controls.Add($prerequisitesCheckLogFile)
$prerequisites.Controls.Add($prerequisitesCheckServer)
$prerequisites.Controls.Add($prerequisitesCheckADDS)
$prerequisites.Controls.Add($prerequisitesCheckADCS)
$prerequisites.Controls.Add($prerequisitesCheckStatus)

try {

    [bool]$prereqCheckPass=$true

    #Create ToolKit log file
    $prerequisitesCheckLogFile.ForeColor = 'orange'
    $prerequisitesCheckLogFile.Text = '1. Log check: Creating Tool Kit log file...'

    # add suspense
    start-sleep -s 1

    # check if log file already exists
    Get-Item $logFile -OutVariable result

    # if log file already exists
    if($result.Exists -eq 'True'){

        $prerequisitesCheckLogFile.ForeColor = 'green'
        $prerequisitesCheckLogFile.Text = '1. Log check: The Tool Kit log already exists!'
        WriteLog "INFO: Log creation - The Tool Kit log already exists at $logFile"
        
        } else {

        New-Item $logFile -ErrorAction Stop 

        $prerequisitesCheckLogFile.ForeColor = 'green'
        $prerequisitesCheckLogFile.Text = '1. Log check: The Tool Kit log was successully created!'
        WriteLog "INFO: Log creation - '1. Log check: The Tool Kit log was successully created!'"
    }

        } catch { 

            $prerequisitesCheckLogFile.Text = $error
            WriteLog "ERROR: Log creation - $error"

            # prevents next button from appearing
            [bool]$prereqCheckPass=$false

    }

    if($prerequisitesCheckLogFile.ForeColor -eq 'green'){

    try {

        $prerequisitesCheckServer.ForeColor = 'orange'
        $prerequisitesCheckServer.Text = '2. Server check: Getting computer operating system...'

        # add suspense
        start-sleep -s 1

        # get operating system
        $ComputerOS = (Get-CimInstance -ClassName Win32_OperatingSystem).caption 

        } catch {
            
            #Failed to retrieve status of member server

            $prerequisitesCheckServer.ForeColor = 'red'
            $prerequisitesCheckServer.Text = '2. Server check: Failed!'
            WriteLog "ERROR: Server check - $error"

            # prevents next button from appearing
            [bool]$prereqCheckPass=$false

    }
            
        # add suspense
        start-sleep -s 1

        # if computer is a member server the script will continue
        # if computer is not a member server the script will stop
        if($ComputerOS -like '*Windows Server*'){

            # computer is a member server
            $prerequisitesCheckServer.ForeColor = 'green'
            $prerequisitesCheckServer.Text = "2. Server check: Passed!" 
            WriteLog "INFO: Server Check - The operating system is $ComputerOS"

        try{

            # # add suspense
            # start-sleep -s 2

            $prerequisitesCheckADDS.ForeColor = 'orange'
            $prerequisitesCheckADDS.Text = '3. ADDS check: Getting the ADDS feature status...'

            # get installation status of adds                        
            $AddsInstalled = Get-WindowsFeature -Name RSAT-ADDS | Select-Object InstallState
            WriteLog "INFO: ADDS check - Getting the ADDS feature status..."

            } catch {

                # add suspense
                start-sleep -s 1

                # throw error if caught
                $prerequisitesCheckADDS.ForeColor = 'red'
                $prerequisitesCheckADDS.Text = '3. ADDS check: Failed!'
                WriteLog "ERROR: ADDS check - $error"

                # prevents next button from appearing
                [bool]$prereqCheckPass=$false

        }

            if($AddsInstalled.InstallState -eq 'Installed'){

                # add suspense
                start-sleep -s 1

                # return tools are already installed
                $prerequisitesCheckADDS.ForeColor = 'green'
                $prerequisitesCheckADDS.Text = '3. ADDS check: Passed!'
                WriteLog 'INFO: ADDS check - The ADDS tool was already installed'

                } else {

                try {

                    # add suspense
                    start-sleep -s 1

                    # install tools
                    $prerequisitesCheckADDS.ForeColor = 'orange'
                    $prerequisitesCheckADDS.Text = '3. ADDS check: Intalling the ADDS feature...'
                    riteLog 'INFO: ADDS check - Intalling the ADDS feature...'

                    # add suspense
                    start-sleep -s 1                     

                    # install adds
                    Install-WindowsFeature -Name RSAT-ADDS
                    $prerequisitesCheckADDS.ForeColor = 'green'
                    $prerequisitesCheckADDS.Text = '3. ADDS check: Successfully installed!'
                    WriteLog 'INFO: ADDS check - The ADDS tool tool successfully installed'
                            
                    } catch {
                                    
                        # add suspense
                        start-sleep -s 1

                        #Throw error if caught
                        $AddsInstallStatus.ForeColor = 'red'
                        $AddsInstallStatus.Text = '3. ADDS check: Failed!'
                        WriteLog "ERROR: ADDS check - $error"

                        # prevents next button from appearing                                        
                        [bool]$prereqCheckPass=$false

                }
            } 

            # add suspense
            start-sleep -s 1

            $prerequisitesCheckADCS.ForeColor = 'orange'
            $prerequisitesCheckADCS.Text = '4. ADCS check: Getting the ADCS feature status...'

            # get installation status of adcs                       
            $AdcsInstalled = Get-WindowsFeature -Name RSAT-ADCS
            WriteLog 'INFO: ADCS check - Getting the ADCS feature status...'

            # installs adcs if not installed
            if($AdcsInstalled.InstallState -ne 'Installed'){

            try {

                # add suspense
                start-sleep -s 1

                $prerequisitesCheckADCS.ForeColor = 'orange'
                $prerequisitesCheckADCS.Text = '4. ADCS check: Installing the Certificate Template management feature...'

                # install adcs
                Install-WindowsFeature -Name RSAT-ADCS | Select-Object InstallState -WarningAction Ignore
                WriteLog 'INFO: ADCS check - Installing the Certificate Template management feature...'

                } catch {

                    # add suspense
                    start-sleep -s 1

                    # throw error if caught
                    $prerequisitesCheckADCS.ForeColor = 'red'
                    $prerequisitesCheckADCS.Text = '4. ADCS check: Failed!'
                    WriteLog "ERROR: ADCS check - $error"

                    # prevents next button from appearing                                    
                    [bool]$prereqCheckPass=$false

            }

                } else {

                # add suspense
                start-sleep -s 1

                $prerequisitesCheckADCS.Text = '4. ADCS check: The ADCS tool is already installed...'
                WriteLog 'INFO: ADCS check - The ADCS tool is already installed'

                # add suspense
                start-sleep -s 1

                $prerequisitesCheckADCS.Text = '4. ADCS check: Checking for existing certificate templates...'
                WriteLog 'INFO: ADCS check - Checking for existing certificate templates'

                try {

                    # check for installed  default templates
                    $certificateTemplates = certutil -template

                    # split certutil -template into new lines
                    $str = $certificateTemplates -split [environment]::NewLine
                                        
                    # loop lines of $str looking for template count
                    $defaultCertificateTemplates = foreach($line in $str){
                                        
                        if($line -like '*Templates*'){
                                        
                        # split line and isolate count of templates that existing AD
                        ($line.Substring(0,$line.IndexOf(" ")))

                        }
                    }

                    # add suspense
                    start-sleep -s 1

                    # if 0 is returned, default templates will be installed

                    if($defaultCertificateTemplates -eq '0'){

                    $prerequisitesCheckADCS.Text = '4. ADCS check: Installing default certificate templates...'
                    WriteLog 'INFO: ADCS check - Installing default certificate templates'

                    # install default certificates
                    certutil -installdefaultdemplates

                    # add suspense
                    start-sleep -s 1

                    $prerequisitesCheckADCS.Text = '4. ADCS check: Default certificate templates successfully installed...'
                    WriteLog 'INFO: ADCS check - Installing default certificate templates'

                        } else {

                        $prerequisitesCheckADCS.Text = '4. ADCS check: Default certificate templates already installed...'
                        WriteLog 'INFO: ADCS check - Default certificate templates already installed'
                    }

                        # add suspense
                        start-sleep -s 1

                                            
                    } catch {

                        $prerequisitesCheckADCS.ForeColor = 'red'
                        $prerequisitesCheckADCS.Text = '4. ADCS check: Failed!'
                        WriteLog "ERROR: ADCS check - $error"

                        # prevents next button from appearing
                        [bool]$prereqCheckPass=$false

                }

                # add suspense
                start-sleep -s 1                                    

                #ADCS successfully isnstalled
                $prerequisitesCheckADCS.ForeColor = 'green'
                $prerequisitesCheckADCS.Text = '4. ADCS check: Passed!'

            }
        
        # else statement for windows server condition
        # skips adds and adcs if computer is not windows server
        } else {
                        
            # add suspense
            start-sleep -s 1

            # not a member server and script will stop
            # change fonts to italic and strikethrough since skipped
            $prerequisitesCheckADDS.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Strikeout)
            $prerequisitesCheckADDS.ForeColor = 'LightGray'   
            $prerequisitesCheckADCS.Font = [System.Drawing.Font]::new("Times New Roman", 12, [System.Drawing.FontStyle]::Strikeout)
            $prerequisitesCheckADCS.ForeColor = 'LightGray'     

            $prerequisitesCheckServer.ForeColor = 'red'
            $prerequisitesCheckServer.Text = '2. Server check: Failed! Run Tool Kit from a member server or domain controller.' 
            $prerequisitesCheckADDS.Text = '3. ADDS check: Skipped! Server validation failed'
            $prerequisitesCheckADCS.Text = '4. ADCS check: Skipped! Server validation failed'
            WriteLog "ERROR: Server check - Failed! The tool is being run on a non-server machine. The tool needs to be run on a Windows server."

            # prevents next button from appearing
            [bool]$prereqCheckPass=$false

    }
                
    }
            
    $prerequisites.Controls.Add($prerequisitesCheckStatusTitle)
    if([bool]$prereqCheckPass -eq 'True'){

    $prerequisitesCheckStatus.ForeColor = 'green'
    $prerequisitesCheckStatus.Text = "All checks have passed. Click 'Next' to continue"
    $prerequisites.Controls.Add($prerequisitesNextButton)

    } else {

        $prerequisitesCheckStatus.ForeColor = 'red'
        $prerequisitesCheckStatus.Text = "One, or more, of the checks have failed. Refer to $logFile to fix any issues before running the tool again."

    }

}

$next_Click = {

    $userInputMenu.Focus()

        }

$cancel_Click = {

    $toolKitApp.Close() | Out-Null

}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot '..\form-designs\prerequisites_design.ps1')

$prerequisites.Show()
#$prerequisites.ShowDialog()
