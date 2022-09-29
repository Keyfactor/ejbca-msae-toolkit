# form focus events
$CreateServiceAccountForm_Shown = {

    # spn search
    # $Global:ForestSpnStatus = SearchForestSpn -Spn $Global:CepServerSPN

    # update navigation pane
    $NavigationItem3.ForeColor = 'Black'
    $NavigationItem2.ForeColor = 'LightGray'

}

#region Create account events
$Create_Click = {

    # check for empty textbox
    if([string]::IsNullOrEmpty($CreateServiceAccountFormNameTextBox.Text) -ne $true){

        # check if user account exists
        if((TestADUser -SamAccountName $($CreateServiceAccountFormNameTextBox.Text)) -eq $false){

            $Global:ServiceAccount = $CreateServiceAccountFormNameTextBox.Text

        }

        else {

            # return error back to user
            $CreateServiceAccountFormNameStatus.ForeColor = 'red'
            $CreateServiceAccountFormNameStatus.Text = "An account with this name already exists. Enter a new name."

        }
    }

    # if name field is empty
    else {

        # change color to orange, INFO $logFilerm user validation is occuring, and write to log
        $CreateServiceAccountFormNameStatus.ForeColor = 'red'
        $CreateServiceAccountFormNameStatus.Text = "Name field cannot be empty"

    }
                     
    # if password textbox is not empty
    if([string]::IsNullOrEmpty($CreateServiceAccountFormPasswordTextBox.Text) -ne $true){


        # convert text to secure string and store in global veriable
        $Global:ServiceAccountPassword = $CreateServiceAccountFormPasswordTextBox.Text | ConvertTo-SecureString -AsPlainText -Force

    }
    
    # if password textbox is empty
    else {

        # change color to orange, INFO $logFilerm user validation is occuring, and write to log
        $CreateServiceAccountFormPasswordStatus.ForeColor = 'red'
        $CreateServiceAccountFormPasswordStatus.Text = "Password field cannot be empty"

    }

    # if ldap textbox is not empty
    if($CreateServiceAccountFormLdapDnTextBox.Text -ne $LdapDnTextDefault){

            $Global:ServiceAccountOrgUnitSearchString = $CreateServiceAccountFormLdapDnTextBox.Text

    }
    
    # if ldap textbox is empty
    else {

        # change color to orange, INFO $logFilerm user validation is occuring, and write to log
        $CreateServiceAccountFormLdapDnStatus.ForeColor = 'red'
        $CreateServiceAccountFormLdapDnStatus.Text = "Organization Unit field cannot be empty"

    }

    # if all three fields are populated, create service account
    if(([string]::IsNullOrEmpty($Global:ServiceAccount) -ne $true) -and `
    ([string]::IsNullOrEmpty($Global:ServiceAccountPassword) -ne $true)  -and `
    ([string]::IsNullOrEmpty($Global:ServiceAccountOrgUnitDN) -ne $true)){

        $CreateServiceAccountFormCreateStatus.ForeColor = 'Orange'
        $CreateServiceAccountFormCreateStatus.Text = 'Creating service account...'

        Start-Sleep -s 1

        # store current state of the checkboxes in global variables
        $Global:ServiceAccountCertPublisher = $CreateServiceAccountFormCertPublishersBox.CheckState
        $Global:ServiceAccountPasswordExpiry = $CreateServiceAccountFormExpirePasswordBox.CheckState

        WriteLog INFO $LogFileToolKit create.service.account "The provided 'Name' for the service account is: $Global:ServiceAccount"
        WriteLog INFO $LogFileToolKit create.service.account "The provided provided a 'Password' the service account: True"
        WriteLog INFO $LogFileToolKit create.service.account "The provided 'LDAP DN' for the service account is: $Global:ServiceAccountOrgUnitDN"
        WriteLog INFO $LogFileToolKit create.service.account "The service account will be used to publish certificates to Active Directory: $Global:ServiceAccountCertPublisher"
        WriteLog INFO $LogFileToolKit create.service.account "The service account is set to never expire: $Global:ServiceAccountPasswordExpiry"

        try {

            $Global:ForestSpnStatus = SearchForestSpn -Spn $Global:CepServerSPN

            # remove spn from previous account if exists
            if($Global:ForestSpnStatus.Exists -eq $true){

                # remove spn
                Set-ADUser $($Global:ForestSpnStatus.Account) -ServicePrincipalNames @{Remove=$Global:CepServerSPN} -ErrorAction Stop
                WriteLog INFO $LogFileToolKit fix.service.account "Removed SPN '$Global:CepServerSPN' from '$($Global:ForestSpnStatus.Account)'"

            }

            # create service account
            New-ADUser `
            -Name $Global:ServiceAccount `
            -AccountPassword $Global:ServiceAccountPassword `
            -AccountExpirationDate $((Get-Date).AddDays(365))`
            -ChangePasswordAtLogon $false `
            -Enabled $true `
            -KerberosEncryptionType 'AES256' `
            -PasswordNeverExpires $Global:ServiceAccountPasswordExpiry `
            -Path $Global:ServiceAccountOrgUnitDN `
            -ServicePrincipalNames $Global:CepServerSPN `
            -UserPrincipalName $Global:CepServerUPN `
            -ErrorAction 'Stop'

            WriteLog INFO $LogFileToolKit create.service.account "Successfully created service account $Global:ServiceAccount"

            # set status of create succcess to true
            $Global:SeviceAccountCreateSuccess = $true

            # disable 'Create' button
            $CreateServiceAccountFormCreateButton.Enabled = $false

            # enable 'Next' button
            $CreateServiceAccountFormNextButton.Enabled = $true

            # inform user of successfull creation
            $CreateServiceAccountFormCreateStatus.ForeColor = 'Green'
            $CreateServiceAccountFormCreateStatus.Text = "'$Global:ServiceAccount' successfully created. Click 'Next' to continue to Kerberos Authentication"

            # add service account to cert publishers check box is checked
            if(($Global:SeviceAccountCreateSuccess -eq $true) -and ($Global:ServiceAccountCertPublisher -eq $true)){

                Add-ADGroupMember -Identity 'CertPublishers' -Members $Global:ServiceAccount -ErrorAction SilentlyContinue
                WriteLog INFO $LogFileToolKit create.service.account "Successfully added $Global:ServiceAccount to the Cert Publishers group"
            
            }
        }
            
        catch [Microsoft.ActiveDirectory.Management.ADPasswordComplexityException]{

            $CreateServiceAccountFormCreateStatus.ForeColor = 'Red'
            $CreateServiceAccountFormCreateStatus.Text = 'The provided password does not meet your organizations complexity requirements enforced on this doamin. Enter a new password and try again'
            WriteLog ERROR $LogFileToolKit create.service.account $($CreateServiceAccountFormCreateStatus.Text)

            # remove user that was created due to failure
            Remove-AdUser $Global:ServiceAccount -Force

        }

        catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException]{

            $CreateServiceAccountFormCreateStatus.ForeColor = 'Red'
            $CreateServiceAccountFormCreateStatus.Text = 'The provided account name already exists. Enter a new name try again.'
            WriteLog ERROR $LogFileToolKit create.service.account $($CreateServiceAccountFormCreateStatus.Text)

            # remove user that was created due to failure
            Remove-AdUser $Global:ServiceAccount -Force
            
        }

        catch {

            $CreateServiceAccountFormCreateStatus.ForeColor = 'Red'
            $CreateServiceAccountFormCreateStatus.Text = $Error[0]
            WriteLog ERROR $LogFileToolKit create.service.account $Error[0]
            if($LogLevel -eq 'DEBUG'){WriteLog DEBUG $LogFileToolKit create.service.account $Error[0].ScriptStackTrace}

            # remove user that was created due to failure
            Remove-AdUser $Global:ServiceAccount -Force

        }

        Write-Host "Succcess = $Global:SeviceAccountCreateSuccess" -ForegroundColor Yellow
    }
}

# search button
$Search_Click = {

    # if ldap textbox is not empty
    if($CreateServiceAccountFormLdapDnTextBox.Text -ne $LdapDnTextDefault){

        $OUResults = Get-ADOrganizationalUnit -Filter "Name -like '*$($CreateServiceAccountFormLdapDnTextBox.Text)*'" | Select-Object Name,DistinguishedName

        Write-Host $OUResults

        if([string]::IsNullOrEmpty($OUResults)){

            $CreateServiceAccountFormLdapDnStatus.ForeColor = 'red'
            $CreateServiceAccountFormLdapDnStatus.Text = "No results found for this OU"

        }

        else {

            #region OU Search box
            $OrgUnitSearchForm = New-Object System.Windows.Forms.Form
            $OrgUnitSearchForm.Text = 'Orginization Unit(OU) Search'
            $OrgUnitSearchForm.Size = '400,415'
            $OrgUnitSearchForm.StartPosition = 'CenterScreen'

            $OrgUnitSearchFormOk = New-Object System.Windows.Forms.Button
            $OrgUnitSearchFormOk.Location = '100,340'
            $OrgUnitSearchFormOk.Size = '60,23'
            $OrgUnitSearchFormOk.Text = 'Select'
            $OrgUnitSearchFormOk.Font = [System.Drawing.Font]::new("Times New Roman", 12)
            $OrgUnitSearchFormOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $OrgUnitSearchForm.AcceptButton = $OrgUnitSearchFormOk
            $OrgUnitSearchForm.Controls.Add($OrgUnitSearchFormOk)
            
            $OrgUnitSearchFormCancel = New-Object System.Windows.Forms.Button
            $OrgUnitSearchFormCancel.Location = '200,340'
            $OrgUnitSearchFormCancel.Size = '75,23'
            $OrgUnitSearchFormCancel.Text = 'Cancel'
            $OrgUnitSearchFormCancel.Font = [System.Drawing.Font]::new("Times New Roman", 12)
            $OrgUnitSearchFormCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $OrgUnitSearchForm.CancelButton = $OrgUnitSearchFormCancel
            $OrgUnitSearchForm.Controls.Add($OrgUnitSearchFormCancel)
        
            $OrgUnitSearchFormTitle = New-Object System.Windows.Forms.Label
            $OrgUnitSearchFormTitle.Location = '10,20'
            $OrgUnitSearchFormTitle.Size = '350,20'
            $OrgUnitSearchFormTitle.Text = 'Select an Org Unit:'
            $OrgUnitSearchFormTitle.Font = [System.Drawing.Font]::new("Times New Roman", 12)
            $OrgUnitSearchForm.Controls.Add($OrgUnitSearchFormTitle)

            $OrgUnitSearchFormSelectList = New-Object System.Windows.Forms.Listbox
            $OrgUnitSearchFormSelectList.Location = '10,40'
            $OrgUnitSearchFormSelectList.Size = '360,20'

            foreach($Ou in $OUResults){

                [void] $OrgUnitSearchFormSelectList.Items.Add($Ou.DistinguishedName)

            }

            $OrgUnitSearchFormSelectList.Height = 275
            $OrgUnitSearchForm.Controls.Add($OrgUnitSearchFormSelectList)
            $OrgUnitSearchForm.Topmost = $true

            $Result = $OrgUnitSearchForm.ShowDialog()
            #endregion OU Search box

        }

        if ($Result -eq [System.Windows.Forms.DialogResult]::OK){

            # populate text box
            $CreateServiceAccountFormLdapDnStatus.Text = ''
            $CreateServiceAccountFormLdapDnTextBox.Text = $OrgUnitSearchFormSelectList.SelectedItems
            $Global:ServiceAccountOrgUnitDN = $CreateServiceAccountFormLdapDnTextBox.Text

        }
        
        #Exit script if cancelled or dialog box was closed was selected in the MSAE Mapped Certificate Templates
        if ($Result -eq [System.Windows.Forms.DialogResult]::Cancel){
        
            $CreateServiceAccountFormLdapDnStatus.ForeColor = 'red'
            $CreateServiceAccountFormLdapDnStatus.Text = "No OU selected"

        }
    }
    
    # if ldap textbox is empty
    else {

        # change color to orange, INFO $logFilerm user validation is occuring, and write to log
        $CreateServiceAccountFormLdapDnStatus.ForeColor = 'red'
        $CreateServiceAccountFormLdapDnStatus.Text = "A string needs to be provided before performing the search"

    }

}

$Next_Click = {


    $ToolKitApp.Close()

}

$Cancel_Click = {


    $ToolKitApp.Close()

}

#region Extra events
# clear default text
$CreateServiceAccountLdapDnTextBox_Entered = {

    if($CreateServiceAccountFormLdapDnTextBox.Text = $LdapDnTextDefault){

        # clear the text when use enters
        $CreateServiceAccountFormLdapDnTextBox.Text = ""
        $CreateServiceAccountFormLdapDnTextBox.ForeColor = 'WindowText'
    }
}

# add key down event for enter key to press search button
$CreateServiceAccountLdapDnTextBox_KeyDown = {
    if($_.KeyCode -eq 'Enter'){

    }
}
#endregion Extras events

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $ScriptRoot '\bin\designs\wizard\create_service_account_design.ps1')