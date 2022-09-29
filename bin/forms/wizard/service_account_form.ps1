# form focus events
$ServiceAccountForm_Shown = {

    # spn search
    # $Global:ForestSpnStatus = SearchForestSpn -Spn $Global:CepServerSPN

    # update navigation pane
    $NavigationItem1.ForeColor = 'LightGray'
    $NavigationItem2.ForeColor = 'Black'

}

$ExistsRadio_Click = { 

    # update nagication menu
    $NavigationItem3.Text = 'Kerberos Authentication'
    $NavigationItem4.Text = 'Certificate Templates'
    $NavigationItem5.Text = ''

    # add exists controls
    $ServiceAccountForm.Controls.AddRange(@(
        $ServiceAccountFormDetailsTitle,
        $ServiceAccountFormExistsDetailsLabel
        $ServiceAccountFormName,
        $ServiceAccountFormNameTextBox,
        $ServiceAccountFormNameStatus,
        $ServiceAccountFormFixButton
        ))

    # remove controls added during create click
    $ServiceAccountForm.Controls.Remove($ServiceAccountFormCreateSelection)


    
    # set next button text to validate
    $ServiceAccountFormValidateNextButton.Text = 'Validate'

    # set next button text to next
    $ServiceAccountFormNameStatus.Text = ''

    # reset value of create new service account to null
    $Global:ServiceAccountCreateNew = $null

}

$CreateRadio_Click = {

    # update nagication menu
    $NavigationItem3.Text = 'Create Service Account'
    $NavigationItem4.Text = 'Kerberos Authentication'
    $NavigationItem5.Text = 'Certificate Templates'

    # add create controls
    $ServiceAccountForm.Controls.Add($ServiceAccountFormCreateSelection)

    # remove controls added during during existing click
    $ServiceAccountForm.Controls.Remove($ServiceAccountFormDetailsTitle)
    $ServiceAccountForm.Controls.Remove($ServiceAccountFormExistsDetailsLabel)
    $ServiceAccountForm.Controls.Remove($ServiceAccountFormName)
    $ServiceAccountForm.Controls.Remove($ServiceAccountFormNameTextBox)
    $ServiceAccountForm.Controls.Remove($ServiceAccountFormNameStatus)
    $ServiceAccountForm.Controls.Remove($ServiceAccountFormFixButton)

    # set next button text to next
    $ServiceAccountFormValidateNextButton.Text = 'Next'

    # set form answer for new account creation to true
    $Global:ServiceAccountCreateNew = $true

}

$ValidateNext_Click = {

    # continue to next form if service account successfully created
    if(($Global:SeviceAccountCreateSuccess -eq $true) -or ($Global:ServiceAccountCreateNew -eq $true)){

        if($Global:ServiceAccountCreateNew -eq $true){

            # show create service account form if selected and close service account form
            $CreateServiceAccountForm.Show()
            $ServiceAccountForm.Close()

        }

        else {
       
        #$ServiceAccountForm.Close()
        $ToolKitApp.Close()

        }

    }

    # continue to next form if service account successfully created
    if($Global:ServiceAccountValidatedSuccess -eq $true){

        $ServiceAccountForm.Close()

    }
    

    # set value back to $null on additional click
    $ServiceAccountFormNameStatus.Text = ''

    # service account validation

    # if text has not been entered, user is INFO $logFilermed
    if([string]::IsNullOrEmpty($ServiceAccountFormNameTextBox.Text)){
    
        # change color to orange, INFO $logFilerm user validation is occuring, and write to log
        $ServiceAccountFormNameStatus.ForeColor = 'red'
        $ServiceAccountFormNameStatus.Text = "Error: Service account name field cannot be empty`n"

    }
    
    else {

        # store account name in global variable
        $Global:ServiceAccount = $ServiceAccountFormNameTextBox.Text
            
        $Result = GetServiceAccount -Name $Global:ServiceAccount -Attributes @('Enabled','LockedOut','ServicePrincipalNames') -CepServer $Global:CepServer

        foreach($Item in $Result){

            # # if account is disabled
            if($Result.Enabled -eq $false){

                $ServiceAccountFormNameStatus.ForeColor = 'red'
                $ServiceAccountFormNameStatus.Text += "Error: '$Global:ServiceAccount' is currently disabled`n"
                $ServiceAccountFormNameStatus.Text += "Click the 'Fix' button to enable the account`n"
    
            }

            # if account is locked
            if($Result.Locked -eq $true) {

                $ServiceAccountFormNameStatus.ForeColor = 'red'
                $ServiceAccountFormNameStatus.Text += "Error: '$Global:ServiceAccount' is currently locked out`n"
                $ServiceAccountFormNameStatus.Text += "Click the 'Fix' button to unlock the account`n"
                    
            }

            # check if spn is set on accound and account exists in domain
            if(($Result.ServicePrincipalNames -ne "$Global:CepServerSPN") -and ($Result -ne 'AccountNotFound')){

                # check if spn already exists in forest
                if($Result.SpnAlreadyExists -eq $true){

                    # store name in global variable to be modified later
                    $Global:SpnAlreadyExistsAccount = $Result.SpnAlreadyExistsAccount
                    $ServiceAccountFormNameStatus.ForeColor = 'red'
                    $ServiceAccountFormNameStatus.Text += "Error: $Global:CepServerSPN is already assigned to '$Global:SpnAlreadyExistsAccount'`n"
                    $ServiceAccountFormNameStatus.Text += "Click the 'Fix' button to remove it from '$Global:SpnAlreadyExistsAccount' and add it to '$Global:ServiceAccount'`n"

                }

                # if spn does not exist in forest and does not exist in forest
                else {

                    $ServiceAccountFormNameStatus.ForeColor = 'red'
                    $ServiceAccountFormNameStatus.Text += "Error: '$Global:ServiceAccount' does not contain a service principal name that matches '$Global:CepServerSPN'`n"
                    $ServiceAccountFormNameStatus.Text += "Click the 'Fix' button to add '$Global:CepServerSPN' as an SPN to '$Global:ServiceAccount'`n"

                }
            }

            # if account not found
            if($Result -eq 'AccountNotFound'){

                $ServiceAccountFormNameStatus.ForeColor = 'red'
                $ServiceAccountFormNameStatus.Text += "Error: '$Global:ServiceAccount' does not exist in $Global:Domain`n"
                $ServiceAccountFormNameStatus.Text += "Enter another name or select the 'No' radio button above to create a new account"

            }

            # if account passed all checks
            if(($Result.Enabled -eq $true) -and ($Result.Locked -eq $false) -and ($Result.ServicePrincipalNames -eq $Global:CepServerSPN)){

                # set global validated variable
                $Global:ServiceAccountValidatedSuccess = $true

                # inform user of successful validate
                $ServiceAccountFormNameStatus.ForeColor = 'green'
                $ServiceAccountFormNameStatus.Text = "Successfully validated"

                # change validate button to next
                $ServiceAccountFormValidateNextButton.Text = 'Next'

                # disable name textbox
                $ServiceAccountFormNameTextBox.Enabled = $false

            }
        }
    }

    # check if service account validation failed
    if(($Global:ServiceAccountValidatedSuccess -ne $true) -and ($Result -ne 'AccountNotFound')){

        # enable fix button
        $ServiceAccountFormFixButton.Enabled = $true 
    }
}

$Fix_Click = {

    if($logLevel -eq 'DEBUG'){WriteLog DEBUG $LogFileToolKit fix.service.account "The 'Fix Account' button was clicked"}

    try {

        # enabled account if false
        if($Result.Enabled -eq $false){
            
            Enable-AdAccount $Global:ServiceAccount -ErrorAction Stop
            WriteLog INFO $LogFileToolKit fix.service.account "Enabled '$Global:ServiceAccount'"

        }

        # unlock account true
        if($Result.Locked -eq $true){
            
            Unlock-AdAccount $Global:ServiceAccount -ErrorAction Stop
            WriteLog INFO $LogFileToolKit fix.service.account "Unlocked '$Global:ServiceAccount'"
            
        }

        # set spn if does not exist
        if($Result.ServicePrincipalNames -ne $Global:CepServerSPN){

            # remove previous spn if it already exists
            if([string]::IsNullOrEmpty($Global:SpnAlreadyExistsAccount) -ne $true){

                # remove spn
                Set-ADUser $Global:SpnAlreadyExistsAccount -ServicePrincipalNames @{Remove=$Global:CepServerSPN} -ErrorAction Stop
                WriteLog INFO $LogFileToolKit fix.service.account "Removed SPN '$Global:CepServerSPN' from '$Global:SpnAlreadyExistsAccount'"
    
            }

            # add spn
            Set-ADUser $Global:ServiceAccount -ServicePrincipalNames @{Add=$Global:CepServerSPN} -ErrorAction Stop
            WriteLog INFO $LogFileToolKit fix.service.account "Added SPN '$Global:CepServerSPN' to '$Global:ServiceAccount'"

        }

        # get attributes of service account
        $Result = GetServiceAccount $Global:ServiceAccount -Attributes @('Enabled','LockedOut','ServicePrincipalNames')

        # check if all attributes are correct
        if(($Result.Enabled -eq $true) -and ($Result.Locked -eq $false) -and ($Result.ServicePrincipalNames -eq $Global:CepServerSPN)){

            # inform user the issues were fixed succesffuly
            $ServiceAccountFormNameStatus.ForeColor = 'green'
            $ServiceAccountFormNameStatus.Text = "Fixed successfully. Click 'Next' to continue."

            # set global validated variable
            WriteLog INFO $LogFileToolKit get.service.account "All fixed completed successfully and user now has a valid service account"
            $Global:ServiceAccountValidatedSuccess  = $true

            # change validate button to next
            $ServiceAccountFormValidateNextButton.Text = 'Next'

            # diable fix button
            $ServiceAccountFormFixButton.Enabled = $false
            
        }

        else {

            $ServiceAccountFormNameStatus.ForeColor = 'red'
            $ServiceAccountFormNameStatus.Text = "Failed to fix '$Global:ServiceAccount'. Refer to the ToolKit.log for more details"

        }
    }

    # catch [Microsoft.ActiveDirectory.Management.ADException] {

    #     $ServiceAccountFormNameStatus.ForeColor = 'red'
    #     $ServiceAccountFormNameStatus.Text = "Could not set '$Global:CepServerSPN' as the SPN on '$Global:ServiceAccount' because another account is already assigned to $($ExistingSPNAccount)"

    #     WriteLog ERROR $LogFileToolKit get.service.account $($_.Exception.Message)

    # }
    catch {

        WriteLog ERROR $LogFileToolKit get.service.account $($_.Exception.Message)

    }
}

$Cancel_Click = {


    $ToolKitApp.Close()

}



Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $ScriptRoot '\bin\designs\wizard\service_account_design.ps1')