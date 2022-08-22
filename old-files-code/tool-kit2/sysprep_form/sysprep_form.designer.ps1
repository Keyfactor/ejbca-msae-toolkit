$SystemPrep = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$SysPrepCancel = $null
[System.Windows.Forms.Button]$SysPrepNext = $null
[System.Windows.Forms.Label]$Title = $null
[System.Windows.Forms.Label]$Description = $null
[System.Windows.Forms.Label]$DomainCheck = $null
[System.Windows.Forms.Label]$MemberServerCheck = $null
[System.Windows.Forms.Label]$ComputerCheck = $null
[System.Windows.Forms.Label]$AddsValidation = $null
[System.Windows.Forms.Label]$AdcsValidation = $null
[System.Windows.Forms.Label]$UsernameCheck = $null
[System.Windows.Forms.Label]$LogFileCheck = $null
[System.Windows.Forms.Label]$AdcsInstalled = $null
[System.Windows.Forms.Label]$AddsInstallStatus = $null
[System.Windows.Forms.Label]$MemberServerStatus = $null
[System.Windows.Forms.Label]$Domain = $null
[System.Windows.Forms.Label]$ComputerName = $null
[System.Windows.Forms.Label]$Username = $null
[System.Windows.Forms.Label]$LogFileCreatedSuccess = $null
[System.Windows.Forms.Label]$FailedValidation = $null
[System.Windows.Forms.Button]$ValidateButton = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'sysprep_form.resources.ps1')
$SysPrepCancel = (New-Object -TypeName System.Windows.Forms.Button)
$SysPrepNext = (New-Object -TypeName System.Windows.Forms.Button)
$Title = (New-Object -TypeName System.Windows.Forms.Label)
$Description = (New-Object -TypeName System.Windows.Forms.Label)
$DomainCheck = (New-Object -TypeName System.Windows.Forms.Label)
$MemberServerCheck = (New-Object -TypeName System.Windows.Forms.Label)
$ComputerCheck = (New-Object -TypeName System.Windows.Forms.Label)
$AddsValidation = (New-Object -TypeName System.Windows.Forms.Label)
$AdcsValidation = (New-Object -TypeName System.Windows.Forms.Label)
$UsernameCheck = (New-Object -TypeName System.Windows.Forms.Label)
$LogFileCheck = (New-Object -TypeName System.Windows.Forms.Label)
$AdcsInstalled = (New-Object -TypeName System.Windows.Forms.Label)
$AddsInstallStatus = (New-Object -TypeName System.Windows.Forms.Label)
$MemberServerStatus = (New-Object -TypeName System.Windows.Forms.Label)
$Domain = (New-Object -TypeName System.Windows.Forms.Label)
$ComputerName = (New-Object -TypeName System.Windows.Forms.Label)
$Username = (New-Object -TypeName System.Windows.Forms.Label)
$LogFileCreatedSuccess = (New-Object -TypeName System.Windows.Forms.Label)
$FailedValidation = (New-Object -TypeName System.Windows.Forms.Label)
$ValidateButton = (New-Object -TypeName System.Windows.Forms.Button)
$SystemPrep.SuspendLayout()
#
#SysPrepCancel
#
$SysPrepCancel.BackColor = [System.Drawing.Color]::LightGray
$SysPrepCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$SysPrepCancel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$SysPrepCancel.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$SysPrepCancel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]683,[System.Int32]510))
$SysPrepCancel.Name = [System.String]'SysPrepCancel'
$SysPrepCancel.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$SysPrepCancel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]89,[System.Int32]39))
$SysPrepCancel.TabIndex = [System.Int32]0
$SysPrepCancel.Text = [System.String]'Cancel'
$SysPrepCancel.UseVisualStyleBackColor = $false
$SysPrepCancel.add_Click($Cancel_Click)
#
#SysPrepNext
#
$SysPrepNext.BackColor = [System.Drawing.Color]::LightGray
$SysPrepNext.DialogResult = [System.Windows.Forms.DialogResult]::OK
$SysPrepNext.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$SysPrepNext.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$SysPrepNext.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]577,[System.Int32]510))
$SysPrepNext.Name = [System.String]'SysPrepNext'
$SysPrepNext.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$SysPrepNext.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]89,[System.Int32]39))
$SysPrepNext.TabIndex = [System.Int32]0
$SysPrepNext.Text = [System.String]'Next'
$SysPrepNext.UseVisualStyleBackColor = $false
$SysPrepNext.add_Click($SysPrepNext_Click)
#
#Title
#
$Title.BackColor = [System.Drawing.Color]::White
$Title.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]16,[System.Drawing.FontStyle]::Underline))
$Title.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Title.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]18))
$Title.Name = [System.String]'Title'
$Title.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Title.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]207,[System.Int32]32))
$Title.TabIndex = [System.Int32]1
$Title.Text = [System.String]'System Preperation'
$Title.add_Click($Title_Click)
#
#Description
#
$Description.BackColor = [System.Drawing.Color]::White
$Description.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$Description.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Description.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]64))
$Description.Name = [System.String]'Description'
$Description.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Description.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]760,[System.Int32]63))
$Description.TabIndex = [System.Int32]2
$Description.Text = [System.String]$resources.'Description.Text'
$Description.add_Click($Description_Click)
#
#DomainCheck
#
$DomainCheck.AutoSize = $true
$DomainCheck.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$DomainCheck.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]303))
$DomainCheck.Name = [System.String]'DomainCheck'
$DomainCheck.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]59,[System.Int32]19))
$DomainCheck.TabIndex = [System.Int32]3
$DomainCheck.Text = [System.String]'Domain:'
#
#MemberServerCheck
#
$MemberServerCheck.AutoSize = $true
$MemberServerCheck.BackColor = [System.Drawing.Color]::White
$MemberServerCheck.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$MemberServerCheck.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$MemberServerCheck.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]337))
$MemberServerCheck.Name = [System.String]'MemberServerCheck'
$MemberServerCheck.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$MemberServerCheck.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]108,[System.Int32]19))
$MemberServerCheck.TabIndex = [System.Int32]3
$MemberServerCheck.Text = [System.String]'Member Server:'
#
#ComputerCheck
#
$ComputerCheck.AutoSize = $true
$ComputerCheck.BackColor = [System.Drawing.Color]::White
$ComputerCheck.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$ComputerCheck.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$ComputerCheck.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]270))
$ComputerCheck.Name = [System.String]'ComputerCheck'
$ComputerCheck.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$ComputerCheck.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]73,[System.Int32]19))
$ComputerCheck.TabIndex = [System.Int32]3
$ComputerCheck.Text = [System.String]'Computer:'
#
#AddsValidation
#
$AddsValidation.AutoSize = $true
$AddsValidation.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$AddsValidation.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]373))
$AddsValidation.Name = [System.String]'AddsValidation'
$AddsValidation.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]233,[System.Int32]19))
$AddsValidation.TabIndex = [System.Int32]4
$AddsValidation.Text = [System.String]'Active Directory Powershell Module:'
#
#AdcsValidation
#
$AdcsValidation.AutoSize = $true
$AdcsValidation.BackColor = [System.Drawing.Color]::White
$AdcsValidation.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$AdcsValidation.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$AdcsValidation.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]412))
$AdcsValidation.Name = [System.String]'AdcsValidation'
$AdcsValidation.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$AdcsValidation.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]246,[System.Int32]19))
$AdcsValidation.TabIndex = [System.Int32]4
$AdcsValidation.Text = [System.String]'Certificate Template Management Tool:'
#
#UsernameCheck
#
$UsernameCheck.AutoSize = $true
$UsernameCheck.BackColor = [System.Drawing.Color]::White
$UsernameCheck.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$UsernameCheck.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$UsernameCheck.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]238))
$UsernameCheck.Name = [System.String]'UsernameCheck'
$UsernameCheck.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$UsernameCheck.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]73,[System.Int32]19))
$UsernameCheck.TabIndex = [System.Int32]4
$UsernameCheck.Text = [System.String]'Username:'
#
#LogFileCheck
#
$LogFileCheck.AutoSize = $true
$LogFileCheck.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$LogFileCheck.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]204))
$LogFileCheck.Name = [System.String]'LogFileCheck'
$LogFileCheck.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]115,[System.Int32]19))
$LogFileCheck.TabIndex = [System.Int32]5
$LogFileCheck.Text = [System.String]'Log File Created:'
#
#AdcsInstalled
#
$AdcsInstalled.AutoSize = $true
$AdcsInstalled.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$AdcsInstalled.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]284,[System.Int32]412))
$AdcsInstalled.Name = [System.String]'AdcsInstalled'
$AdcsInstalled.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]0,[System.Int32]19))
$AdcsInstalled.TabIndex = [System.Int32]7
#
#AddsInstallStatus
#
$AddsInstallStatus.AutoSize = $true
$AddsInstallStatus.BackColor = [System.Drawing.Color]::White
$AddsInstallStatus.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$AddsInstallStatus.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$AddsInstallStatus.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]284,[System.Int32]373))
$AddsInstallStatus.Name = [System.String]'AddsInstallStatus'
$AddsInstallStatus.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$AddsInstallStatus.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]0,[System.Int32]19))
$AddsInstallStatus.TabIndex = [System.Int32]7
#
#MemberServerStatus
#
$MemberServerStatus.BackColor = [System.Drawing.Color]::White
$MemberServerStatus.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$MemberServerStatus.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$MemberServerStatus.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]134,[System.Int32]337))
$MemberServerStatus.Name = [System.String]'MemberServerStatus'
$MemberServerStatus.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$MemberServerStatus.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]625,[System.Int32]23))
$MemberServerStatus.TabIndex = [System.Int32]7
#
#Domain
#
$Domain.BackColor = [System.Drawing.Color]::White
$Domain.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$Domain.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Domain.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]73,[System.Int32]303))
$Domain.Name = [System.String]'Domain'
$Domain.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Domain.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]681,[System.Int32]23))
$Domain.TabIndex = [System.Int32]7
#
#ComputerName
#
$ComputerName.BackColor = [System.Drawing.Color]::White
$ComputerName.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$ComputerName.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$ComputerName.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]91,[System.Int32]270))
$ComputerName.Name = [System.String]'ComputerName'
$ComputerName.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$ComputerName.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]663,[System.Int32]23))
$ComputerName.TabIndex = [System.Int32]7
#
#Username
#
$Username.BackColor = [System.Drawing.Color]::White
$Username.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$Username.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Username.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]91,[System.Int32]238))
$Username.Name = [System.String]'Username'
$Username.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Username.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]663,[System.Int32]23))
$Username.TabIndex = [System.Int32]7
#
#LogFileCreatedSuccess
#
$LogFileCreatedSuccess.BackColor = [System.Drawing.Color]::White
$LogFileCreatedSuccess.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$LogFileCreatedSuccess.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$LogFileCreatedSuccess.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]151,[System.Int32]204))
$LogFileCreatedSuccess.Name = [System.String]'LogFileCreatedSuccess'
$LogFileCreatedSuccess.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$LogFileCreatedSuccess.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]589,[System.Int32]23))
$LogFileCreatedSuccess.TabIndex = [System.Int32]7
#
#FailedValidation
#
$FailedValidation.Enabled = $false
$FailedValidation.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$FailedValidation.ForeColor = [System.Drawing.Color]::Red
$FailedValidation.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]20,[System.Int32]447))
$FailedValidation.Name = [System.String]'FailedValidation'
$FailedValidation.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]657,[System.Int32]102))
$FailedValidation.TabIndex = [System.Int32]11
#
#ValidateButton
#
$ValidateButton.BackColor = [System.Drawing.Color]::LightGray
$ValidateButton.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$ValidateButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]150))
$ValidateButton.Name = [System.String]'ValidateButton'
$ValidateButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]98,[System.Int32]33))
$ValidateButton.TabIndex = [System.Int32]10
$ValidateButton.Text = [System.String]'Validate'
$ValidateButton.UseVisualStyleBackColor = $false
$ValidateButton.add_Click($ValidateButton_Click)
#
#SystemPrep
#
$SystemPrep.AcceptButton = $SysPrepNext
$SystemPrep.BackColor = [System.Drawing.Color]::White
$SystemPrep.CancelButton = $SysPrepCancel
$SystemPrep.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]784,[System.Int32]561))
$SystemPrep.Controls.Add($ValidateButton)
$SystemPrep.Controls.Add($FailedValidation)
$SystemPrep.Controls.Add($AdcsInstalled)
$SystemPrep.Controls.Add($LogFileCheck)
$SystemPrep.Controls.Add($AddsValidation)
$SystemPrep.Controls.Add($DomainCheck)
$SystemPrep.Controls.Add($SysPrepCancel)
$SystemPrep.Controls.Add($Title)
$SystemPrep.Controls.Add($Description)
$SystemPrep.Controls.Add($MemberServerCheck)
$SystemPrep.Controls.Add($ComputerCheck)
$SystemPrep.Controls.Add($AdcsValidation)
$SystemPrep.Controls.Add($UsernameCheck)
$SystemPrep.Controls.Add($AddsInstallStatus)
$SystemPrep.Controls.Add($MemberServerStatus)
$SystemPrep.Controls.Add($Domain)
$SystemPrep.Controls.Add($ComputerName)
$SystemPrep.Controls.Add($Username)
$SystemPrep.Controls.Add($LogFileCreatedSuccess)
$SystemPrep.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$SystemPrep.MaximumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]800,[System.Int32]600))
$SystemPrep.MinimumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]800,[System.Int32]600))
$SystemPrep.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$SystemPrep.Text = [System.String]'System Preperation'
$SystemPrep.ResumeLayout($false)
$SystemPrep.PerformLayout()
Add-Member -InputObject $SystemPrep -Name SysPrepCancel -Value $SysPrepCancel -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name SysPrepNext -Value $SysPrepNext -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Title -Value $Title -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Description -Value $Description -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name DomainCheck -Value $DomainCheck -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name MemberServerCheck -Value $MemberServerCheck -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name ComputerCheck -Value $ComputerCheck -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name AddsValidation -Value $AddsValidation -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name AdcsValidation -Value $AdcsValidation -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name UsernameCheck -Value $UsernameCheck -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name LogFileCheck -Value $LogFileCheck -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name AdcsInstalled -Value $AdcsInstalled -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name AddsInstallStatus -Value $AddsInstallStatus -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name MemberServerStatus -Value $MemberServerStatus -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Domain -Value $Domain -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name ComputerName -Value $ComputerName -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Username -Value $Username -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name LogFileCreatedSuccess -Value $LogFileCreatedSuccess -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name FailedValidation -Value $FailedValidation -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name ValidateButton -Value $ValidateButton -MemberType NoteProperty
}
. InitializeComponent
