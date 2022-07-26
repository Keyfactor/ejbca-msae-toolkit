$SystemPrep = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$Cancel = $null
[System.Windows.Forms.Button]$Next = $null
[System.Windows.Forms.Label]$Title = $null
[System.Windows.Forms.Label]$Description = $null
[System.Windows.Forms.Label]$Domain = $null
[System.Windows.Forms.Label]$MemberServer = $null
[System.Windows.Forms.Label]$ComputerName = $null
[System.Windows.Forms.Label]$AldsValidation = $null
[System.Windows.Forms.Label]$AdcsValidation = $null
[System.Windows.Forms.Label]$UserName = $null
[System.Windows.Forms.Label]$LogFile = $null
[System.Windows.Forms.Label]$AdcsInstalled = $null
[System.Windows.Forms.Label]$AddsInstallStatus = $null
[System.Windows.Forms.Label]$MemberServerStatus = $null
[System.Windows.Forms.Label]$DomainStatus = $null
[System.Windows.Forms.Label]$ComputerNameCheck = $null
[System.Windows.Forms.Label]$UsernameCheck = $null
[System.Windows.Forms.Label]$LogFileCreatedSuccess = $null
[System.Windows.Forms.Button]$ValidateButton = $null
[System.Windows.Forms.Label]$FailedValidation = $null
[System.Windows.Forms.Label]$User = $null
[System.Windows.Forms.Label]$DomainName = $null
[System.Windows.Forms.Label]$Computer = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'sysprep_form.resources.ps1')
$Cancel = (New-Object -TypeName System.Windows.Forms.Button)
$Next = (New-Object -TypeName System.Windows.Forms.Button)
$Title = (New-Object -TypeName System.Windows.Forms.Label)
$Description = (New-Object -TypeName System.Windows.Forms.Label)
$Domain = (New-Object -TypeName System.Windows.Forms.Label)
$MemberServer = (New-Object -TypeName System.Windows.Forms.Label)
$ComputerName = (New-Object -TypeName System.Windows.Forms.Label)
$AldsValidation = (New-Object -TypeName System.Windows.Forms.Label)
$AdcsValidation = (New-Object -TypeName System.Windows.Forms.Label)
$UserName = (New-Object -TypeName System.Windows.Forms.Label)
$LogFile = (New-Object -TypeName System.Windows.Forms.Label)
$AdcsInstalled = (New-Object -TypeName System.Windows.Forms.Label)
$AddsInstallStatus = (New-Object -TypeName System.Windows.Forms.Label)
$MemberServerStatus = (New-Object -TypeName System.Windows.Forms.Label)
$DomainStatus = (New-Object -TypeName System.Windows.Forms.Label)
$ComputerNameCheck = (New-Object -TypeName System.Windows.Forms.Label)
$UsernameCheck = (New-Object -TypeName System.Windows.Forms.Label)
$LogFileCreatedSuccess = (New-Object -TypeName System.Windows.Forms.Label)
$ValidateButton = (New-Object -TypeName System.Windows.Forms.Button)
$FailedValidation = (New-Object -TypeName System.Windows.Forms.Label)
$User = (New-Object -TypeName System.Windows.Forms.Label)
$DomainName = (New-Object -TypeName System.Windows.Forms.Label)
$Computer = (New-Object -TypeName System.Windows.Forms.Label)
$SystemPrep.SuspendLayout()
#
#Cancel
#
$Cancel.BackColor = [System.Drawing.Color]::LightGray
$Cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Cancel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$Cancel.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Cancel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]683,[System.Int32]510))
$Cancel.Name = [System.String]'Cancel'
$Cancel.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Cancel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]89,[System.Int32]39))
$Cancel.TabIndex = [System.Int32]0
$Cancel.Text = [System.String]'Cancel'
$Cancel.UseVisualStyleBackColor = $false
$Cancel.add_Click($Cancel_Click)
#
#Next
#
$Next.BackColor = [System.Drawing.Color]::LightGray
$Next.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Next.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$Next.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Next.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]577,[System.Int32]510))
$Next.Name = [System.String]'Next'
$Next.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Next.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]89,[System.Int32]39))
$Next.TabIndex = [System.Int32]0
$Next.Text = [System.String]'Next'
$Next.UseVisualStyleBackColor = $false
$Next.add_Click($Next_Click)
#
#Title
#
$Title.BackColor = [System.Drawing.Color]::White
$Title.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]18,[System.Drawing.FontStyle]::Underline))
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
$Description.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Description.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Description.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]64))
$Description.Name = [System.String]'Description'
$Description.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Description.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]760,[System.Int32]63))
$Description.TabIndex = [System.Int32]2
$Description.Text = [System.String]$resources.'Description.Text'
$Description.add_Click($Description_Click)
#
#Domain
#
$Domain.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Domain.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]303))
$Domain.Name = [System.String]'Domain'
$Domain.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]73,[System.Int32]23))
$Domain.TabIndex = [System.Int32]3
$Domain.Text = [System.String]'Domain:'
#
#MemberServer
#
$MemberServer.BackColor = [System.Drawing.Color]::White
$MemberServer.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$MemberServer.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$MemberServer.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]337))
$MemberServer.Name = [System.String]'MemberServer'
$MemberServer.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$MemberServer.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]129,[System.Int32]23))
$MemberServer.TabIndex = [System.Int32]3
$MemberServer.Text = [System.String]'Member Server:'
$MemberServer.add_Click($Label3_Click)
#
#ComputerName
#
$ComputerName.BackColor = [System.Drawing.Color]::White
$ComputerName.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$ComputerName.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$ComputerName.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]270))
$ComputerName.Name = [System.String]'ComputerName'
$ComputerName.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$ComputerName.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]91,[System.Int32]23))
$ComputerName.TabIndex = [System.Int32]3
$ComputerName.Text = [System.String]'Computer:'
$ComputerName.add_Click($Label3_Click)
#
#AldsValidation
#
$AldsValidation.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]373))
$AldsValidation.Name = [System.String]'AldsValidation'
$AldsValidation.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]404,[System.Int32]23))
$AldsValidation.TabIndex = [System.Int32]4
$AldsValidation.Text = [System.String]'Active Directory Powershell Module (ADDS RSAT):'
#
#AdcsValidation
#
$AdcsValidation.BackColor = [System.Drawing.Color]::White
$AdcsValidation.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$AdcsValidation.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$AdcsValidation.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]412))
$AdcsValidation.Name = [System.String]'AdcsValidation'
$AdcsValidation.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$AdcsValidation.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]404,[System.Int32]23))
$AdcsValidation.TabIndex = [System.Int32]4
$AdcsValidation.Text = [System.String]'Certificate Template Management (ADCS RSAT):'
#
#UserName
#
$UserName.BackColor = [System.Drawing.Color]::White
$UserName.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$UserName.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$UserName.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]238))
$UserName.Name = [System.String]'UserName'
$UserName.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$UserName.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]91,[System.Int32]23))
$UserName.TabIndex = [System.Int32]4
$UserName.Text = [System.String]'Username:'
$UserName.add_Click($Label1_Click)
#
#LogFile
#
$LogFile.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$LogFile.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]204))
$LogFile.Name = [System.String]'LogFile'
$LogFile.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]148,[System.Int32]23))
$LogFile.TabIndex = [System.Int32]5
$LogFile.Text = [System.String]'Log File Created:'
#
#AdcsInstalled
#
$AdcsInstalled.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]407,[System.Int32]412))
$AdcsInstalled.Name = [System.String]'AdcsInstalled'
$AdcsInstalled.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]365,[System.Int32]23))
$AdcsInstalled.TabIndex = [System.Int32]7
$AdcsInstalled.add_Click($Label1_Click)
#
#AddsInstallStatus
#
$AddsInstallStatus.BackColor = [System.Drawing.Color]::White
$AddsInstallStatus.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$AddsInstallStatus.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$AddsInstallStatus.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]433,[System.Int32]373))
$AddsInstallStatus.Name = [System.String]'AddsInstallStatus'
$AddsInstallStatus.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$AddsInstallStatus.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]339,[System.Int32]23))
$AddsInstallStatus.TabIndex = [System.Int32]7
#
#MemberServerStatus
#
$MemberServerStatus.BackColor = [System.Drawing.Color]::White
$MemberServerStatus.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$MemberServerStatus.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$MemberServerStatus.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]147,[System.Int32]337))
$MemberServerStatus.Name = [System.String]'MemberServerStatus'
$MemberServerStatus.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$MemberServerStatus.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]248,[System.Int32]23))
$MemberServerStatus.TabIndex = [System.Int32]7
$MemberServerStatus.add_Click($Label1_Click)
#
#DomainStatus
#
$DomainStatus.BackColor = [System.Drawing.Color]::White
$DomainStatus.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$DomainStatus.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$DomainStatus.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]91,[System.Int32]303))
$DomainStatus.Name = [System.String]'DomainStatus'
$DomainStatus.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$DomainStatus.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]304,[System.Int32]23))
$DomainStatus.TabIndex = [System.Int32]7
#
#ComputerNameCheck
#
$ComputerNameCheck.BackColor = [System.Drawing.Color]::White
$ComputerNameCheck.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$ComputerNameCheck.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$ComputerNameCheck.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]109,[System.Int32]270))
$ComputerNameCheck.Name = [System.String]'ComputerNameCheck'
$ComputerNameCheck.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$ComputerNameCheck.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]286,[System.Int32]23))
$ComputerNameCheck.TabIndex = [System.Int32]7
#
#UsernameCheck
#
$UsernameCheck.BackColor = [System.Drawing.Color]::White
$UsernameCheck.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$UsernameCheck.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$UsernameCheck.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]109,[System.Int32]238))
$UsernameCheck.Name = [System.String]'UsernameCheck'
$UsernameCheck.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$UsernameCheck.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]286,[System.Int32]23))
$UsernameCheck.TabIndex = [System.Int32]7
#
#LogFileCreatedSuccess
#
$LogFileCreatedSuccess.BackColor = [System.Drawing.Color]::White
$LogFileCreatedSuccess.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25))
$LogFileCreatedSuccess.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$LogFileCreatedSuccess.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]166,[System.Int32]204))
$LogFileCreatedSuccess.Name = [System.String]'LogFileCreatedSuccess'
$LogFileCreatedSuccess.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$LogFileCreatedSuccess.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]229,[System.Int32]23))
$LogFileCreatedSuccess.TabIndex = [System.Int32]7
#
#ValidateButton
#
$ValidateButton.BackColor = [System.Drawing.Color]::LightGray
$ValidateButton.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$ValidateButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]154))
$ValidateButton.Name = [System.String]'ValidateButton'
$ValidateButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]116,[System.Int32]31))
$ValidateButton.TabIndex = [System.Int32]8
$ValidateButton.Text = [System.String]'Validate'
$ValidateButton.UseVisualStyleBackColor = $false
$ValidateButton.add_Click($Validate_Click)
#
#FailedValidation
#
$FailedValidation.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]46,[System.Int32]451))
$FailedValidation.Name = [System.String]'FailedValidation'
$FailedValidation.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]452,[System.Int32]87))
$FailedValidation.TabIndex = [System.Int32]9
#
#User
#
$User.Enabled = $false
$User.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]526))
$User.Name = [System.String]'User'
$User.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$User.TabIndex = [System.Int32]10
#
#DomainName
#
$DomainName.Enabled = $false
$DomainName.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]526))
$DomainName.Name = [System.String]'DomainName'
$DomainName.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$DomainName.TabIndex = [System.Int32]11
#
#Computer
#
$Computer.Enabled = $false
$Computer.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]526))
$Computer.Name = [System.String]'Computer'
$Computer.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$Computer.TabIndex = [System.Int32]12
$Computer.add_Click($Label1_Click)
#
#SystemPrep
#
$SystemPrep.AcceptButton = $Next
$SystemPrep.BackColor = [System.Drawing.Color]::White
$SystemPrep.CancelButton = $Cancel
$SystemPrep.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]784,[System.Int32]561))
$SystemPrep.Controls.Add($Computer)
$SystemPrep.Controls.Add($DomainName)
$SystemPrep.Controls.Add($User)
$SystemPrep.Controls.Add($FailedValidation)
$SystemPrep.Controls.Add($ValidateButton)
$SystemPrep.Controls.Add($AdcsInstalled)
$SystemPrep.Controls.Add($LogFile)
$SystemPrep.Controls.Add($AldsValidation)
$SystemPrep.Controls.Add($Domain)
$SystemPrep.Controls.Add($Cancel)
$SystemPrep.Controls.Add($Next)
$SystemPrep.Controls.Add($Title)
$SystemPrep.Controls.Add($Description)
$SystemPrep.Controls.Add($MemberServer)
$SystemPrep.Controls.Add($ComputerName)
$SystemPrep.Controls.Add($AdcsValidation)
$SystemPrep.Controls.Add($UserName)
$SystemPrep.Controls.Add($AddsInstallStatus)
$SystemPrep.Controls.Add($MemberServerStatus)
$SystemPrep.Controls.Add($DomainStatus)
$SystemPrep.Controls.Add($ComputerNameCheck)
$SystemPrep.Controls.Add($UsernameCheck)
$SystemPrep.Controls.Add($LogFileCreatedSuccess)
$SystemPrep.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$SystemPrep.MaximumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]800,[System.Int32]600))
$SystemPrep.MinimumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]800,[System.Int32]600))
$SystemPrep.Name = [System.String]'SystemPrep'
$SystemPrep.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$SystemPrep.Text = [System.String]'System Preperation'
$SystemPrep.ResumeLayout($false)
Add-Member -InputObject $SystemPrep -Name Cancel -Value $Cancel -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Next -Value $Next -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Title -Value $Title -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Description -Value $Description -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Domain -Value $Domain -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name MemberServer -Value $MemberServer -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name ComputerName -Value $ComputerName -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name AldsValidation -Value $AldsValidation -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name AdcsValidation -Value $AdcsValidation -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name UserName -Value $UserName -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name LogFile -Value $LogFile -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name AdcsInstalled -Value $AdcsInstalled -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name AddsInstallStatus -Value $AddsInstallStatus -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name MemberServerStatus -Value $MemberServerStatus -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name DomainStatus -Value $DomainStatus -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name ComputerNameCheck -Value $ComputerNameCheck -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name UsernameCheck -Value $UsernameCheck -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name LogFileCreatedSuccess -Value $LogFileCreatedSuccess -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name ValidateButton -Value $ValidateButton -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name FailedValidation -Value $FailedValidation -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name User -Value $User -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name DomainName -Value $DomainName -MemberType NoteProperty
Add-Member -InputObject $SystemPrep -Name Computer -Value $Computer -MemberType NoteProperty
}
. InitializeComponent
