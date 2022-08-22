$ToolOverview = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$OverviewNextButton = $null
[System.Windows.Forms.Label]$Description = $null
[System.Windows.Forms.Button]$OverviewCancelButton = $null
[System.Windows.Forms.RadioButton]$ConfigOption = $null
[System.Windows.Forms.RadioButton]$Validation = $null
[System.Windows.Forms.Label]$SelectionDescription = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'description_form.resources.ps1')
$OverviewNextButton = (New-Object -TypeName System.Windows.Forms.Button)
$Description = (New-Object -TypeName System.Windows.Forms.Label)
$OverviewCancelButton = (New-Object -TypeName System.Windows.Forms.Button)
$ConfigOption = (New-Object -TypeName System.Windows.Forms.RadioButton)
$Validation = (New-Object -TypeName System.Windows.Forms.RadioButton)
$SelectionDescription = (New-Object -TypeName System.Windows.Forms.Label)
$ToolOverview.SuspendLayout()
#
#Next
#
$OverviewNextButton.BackColor = [System.Drawing.Color]::LightGray
$OverviewNextButton.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$OverviewNextButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]566,[System.Int32]510))
$OverviewNextButton.Name = [System.String]'Next'
$OverviewNextButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]39))
$OverviewNextButton.TabIndex = [System.Int32]0
$OverviewNextButton.Text = [System.String]'Next'
$OverviewNextButton.UseVisualStyleBackColor = $false
$OverviewNextButton.add_Click($OverviewNextButton_Click)
#
#Description
#
$Description.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$Description.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]27))
$Description.Name = [System.String]'Description'
$Description.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]760,[System.Int32]63))
$Description.TabIndex = [System.Int32]2
$Description.Text = [System.String]$resources.'Description.Text'
$Description.add_Click($Description_Click)
#
#OverviewCancelButton
#
$OverviewCancelButton.BackColor = [System.Drawing.Color]::LightGray
$OverviewCancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$OverviewCancelButton.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$OverviewCancelButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]683,[System.Int32]510))
$OverviewCancelButton.Name = [System.String]'OverviewCancelButton'
$OverviewCancelButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]89,[System.Int32]39))
$OverviewCancelButton.TabIndex = [System.Int32]0
$OverviewCancelButton.Text = [System.String]'Cancel'
$OverviewCancelButton.UseVisualStyleBackColor = $false
$OverviewCancelButton.add_Click($OverviewCancelButton_Click)
#
#ConfigOption
#
$ConfigOption.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$ConfigOption.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]38,[System.Int32]93))
$ConfigOption.Name = [System.String]'ConfigOption'
$ConfigOption.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]141,[System.Int32]24))
$ConfigOption.TabIndex = [System.Int32]7
$ConfigOption.Text = [System.String]'Configuration'
$ConfigOption.add_Click($Configuration_Click)
#
#Validation
#
$Validation.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12))
$Validation.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]38,[System.Int32]138))
$Validation.Name = [System.String]'Validation'
$Validation.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]211,[System.Int32]24))
$Validation.TabIndex = [System.Int32]6
$Validation.Text = [System.String]'Validation and Testing'
$Validation.add_Click($Validation_Click)
#
#SelectionDescription
#
$SelectionDescription.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$SelectionDescription.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]281,[System.Int32]123))
$SelectionDescription.Name = [System.String]'SelectionDescription'
$SelectionDescription.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]457,[System.Int32]361))
$SelectionDescription.TabIndex = [System.Int32]5
#
#ToolOverview
#
$ToolOverview.AcceptButton = $Next
$ToolOverview.BackColor = [System.Drawing.Color]::White
$ToolOverview.CancelButton = $OverviewCancelButton
$ToolOverview.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]784,[System.Int32]561))
$ToolOverview.Controls.Add($SelectionDescription)
$ToolOverview.Controls.Add($Validation)
$ToolOverview.Controls.Add($ConfigOption)
$ToolOverview.Controls.Add($Description)
$ToolOverview.Controls.Add($OverviewCancelButton)
$ToolOverview.MaximumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]800,[System.Int32]600))
$ToolOverview.MinimumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]800,[System.Int32]600))
$ToolOverview.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$ToolOverview.Text = [System.String]'Tool Overview'
$ToolOverview.add_Load($ToolOverview_Load)
$ToolOverview.ResumeLayout($false)
Add-Member -InputObject $ToolOverview -Name Next -Value $Next -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name Description -Value $Description -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name OverviewCancelButton -Value $OverviewCancelButton -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name ConfigOption -Value $ConfigOption -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name Validation -Value $Validation -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name SelectionDescription -Value $SelectionDescription -MemberType NoteProperty
}
. InitializeComponent
