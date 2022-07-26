$Label1_Click = {
}
$Label3_Click = {
}
$Description_Click = {
}
$Title_Click = {
}
$logLevel= 'INFO'
$tlog =  Get-Date -Format "yyyyMMdd_hhmmss"

$Validate_Click = {

#Create ToolKit log file
try{
    New-Item "$PSScriptRoot\toolkit.log"
    $LogFileCreatedSuccess.ForeColor = 'green'
    $LogFileCreatedSuccess.Text = "The Toolkit log file was successfully created in $PSScriptRoot"
    
    }
    catch {
    
    $LogFileCreatedSuccess.ForeColor = 'red'
    $LogFileCreatedSuccess.Text = 'ToolKit.log file could not be created'

    }

    #Get username
    $User.ForeColor = 'orange'
    $User.Text = 'Getting user name...'
    $User.Text = '$env:USERNAME'
    Add-Content $PSScriptRoot\toolkit.log "$tlog -- INFO: The username of the operator is $User.Text"

    #Get computer name
    $ComputerNameCheck.ForeColor = 'orange'
    $ComputerNameCheck.Text = "Getting computer name..." 
    $Computer.Text = '$env:COMPUTERNAME'
    Add-Content $PSScriptRoot\toolkit.log "$tlog -- INFO: The computer name is $Computer.Text"
    
    #Get domain name
    $DomainStatus.ForeColor = 'orange'
    $DomainStatus.Text = 'Getting domain name...'
    $DomainName = systeminfo | findstr /i "domain"
    foreach($name in $domain){
        if($name -like '*Domain:*'){
    
        $DomainStatus.ForeColor = 'green'
        $DomainStatus.Text = $name.Substring($name.IndexOf(":")+1).Trim()
        $DomainName.Text = $name.Substring($name.IndexOf(":")+1).Trim()
        Add-Content $PSScriptRoot\toolkit.log "$tlog -- INFO: The domain is $DomainName.Text"

        }

    #Get member server status
    $MemberServerStatus.ForeColor = 'orange'
    $MemberServerStatus.Text = "Getting computer operating system..." 
    $ComputerOS = (Get-CimInstance -ClassName Win32_OperatingSystem).caption 
    if(ComputerOS -like '*Windows Server*'){

        $MemberServerStatus.ForeColor = 'green'
        $MemberServerStatus.Text = "This is a member server" 
        Add-Content $PSScriptRoot\toolkit.log "$tlog -- INFO: $MemberServerStatus.Text - $ComputerOS"

        #Get ADDS tool states
        $AddsInstallStatus.ForeColor = 'orange'
        $AddsInstallStatus.Text = "Getting ADDS RSAT tool status..." 
        $AddsInstalled = Get-WindowsFeature -Name RSAT-ADDS-Tools | Select-Object InstallState

        if($AddsInstalled.InstallState -eq 'Installed'){

            $AddsInstallStatus.ForeColor = 'green'
            $AddsInstallStatus.Text = "Already installed" 
            Add-Content $PSScriptRoot\toolkit.log "$tlog -- INFO: The ADDS RSAT tool was already installed"

            } else {
              try {
                
                #Installed tools if not already installed
                $AddsInstallStatus.ForeColor = 'orange'
                $AddsInstallStatus.Text = "Intalling ADDS RSAT tool..." 

                Install-WindowsFeature -Name RSAT-ADDS-Tools
                $AddsInstallStatus.ForeColor = 'green'
                $AddsInstallStatus.Text = "Successfully installed" 
                Add-Content $PSScriptRoot\toolkit.log "$tlog -- INFO: The AD DS and LDS tool tool successfully installed"
    
                } catch {
                
                #Throw error is caught
                $AddsInstallStatus.ForeColor = 'red'
                $AddsInstallStatus.Text = "Not successfully installed"
                Add-Content $PSScriptRoot\toolkit.log "$tlog -- ERROR: The AD DS and LDS tool was not successfully installed"

                }
            } 


        $AdcsInstalled.ForeColor = 'orange'
        $AdcsInstalled.Text = "Getting ADCS RSAT tool status..." 
        $rsatAdcsInstalled = Get-WindowsFeature -Name RSAT-ADCS | Select-Object InstallState

        if($rsatAdcsInstalled.InstallState -eq 'Installed'){

            $AdcsInstalled.ForeColor = 'green'
            $AdcsInstalled.Text = "Already installed" 
            Add-Content $PSScriptRoot\toolkit.log "$tlog -- INFO: The AD CS tool was already installed"

            } else {
              try{

                $AdcsInstalled.ForeColor = 'orange'
                $AdcsInstalled.Text = "Intalling Certificate Template management..." 

     
                Install-WindowsFeature -Name RSAT-ADDS-Tools
                $AdcsInstalled.ForeColor = 'green'
                $AdcsInstalled.Text = "Successfully installed" 
                Add-Content $PSScriptRoot\toolkit.log "$tlog -- INFO: The AD CS tool successfully installed"
    
                } catch {

                $AdcsInstalled.ForeColor = 'red'
                $AdcsInstalled.Text = "Not successfully installed"
                Add-Content $PSScriptRoot\toolkit.log "$tlog -- ERROR: The AD CS tool was not successfully installed"

                }
            }
            } else {
            
            $MemberServerStatus.ForeColor = 'red'
            $AdcsInstalled.Text = "This is not a member server. Run Tool Kit from a domain-joined member server." 

            Add-Content $PSScriptRoot\toolkit.log "$tlog -- ERROR: The script was run on a non-member server"
                }

    }
}
if($AddsInstallStatus.ForeColor -eq 'red' -or $AdcsInstalled.ForeColor -eq 'red' -or $MemberServerStatus.ForeColor -eq 'red'){

    FailedValidation.Text = 'The validation failed. Please fix the items in red using the Tool Kit log output before running again on this computer.'
} else {

    $SystemPrep.Controls.Add($Next)

        $Next_Click = {

            $SystemPrep.Close()
        }
    }

$Cancel_Click = {

    $SystemPrep.Close()

}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'sysprep_form.designer.ps1')
$SystemPrep.ShowDialog()