$ToolOverview = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$Next = $null
[System.Windows.Forms.Label]$Title = $null
[System.Windows.Forms.Label]$Description = $null
[System.Windows.Forms.Button]$Cancel = $null
[System.Windows.Forms.RadioButton]$ConfigOption = $null
[System.Windows.Forms.RadioButton]$Validation = $null
[System.Windows.Forms.Label]$SelectionDescription = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'description_form.resources.ps1')
$Next = (New-Object -TypeName System.Windows.Forms.Button)
$Title = (New-Object -TypeName System.Windows.Forms.Label)
$Description = (New-Object -TypeName System.Windows.Forms.Label)
$Cancel = (New-Object -TypeName System.Windows.Forms.Button)
$ConfigOption = (New-Object -TypeName System.Windows.Forms.RadioButton)
$Validation = (New-Object -TypeName System.Windows.Forms.RadioButton)
$SelectionDescription = (New-Object -TypeName System.Windows.Forms.Label)
$ToolOverview.SuspendLayout()
#
#Next
#
$Next.BackColor = [System.Drawing.Color]::LightGray
$Next.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Next.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]566,[System.Int32]510))
$Next.Name = [System.String]'Next'
$Next.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]39))
$Next.TabIndex = [System.Int32]0
$Next.Text = [System.String]'Next'
$Next.UseVisualStyleBackColor = $false
$Next.add_Click($Next_Click)
#
#Title
#
$Title.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]18,[System.Drawing.FontStyle]::Underline,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Title.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]19))
$Title.Name = [System.String]'Title'
$Title.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]127,[System.Int32]32))
$Title.TabIndex = [System.Int32]1
$Title.Text = [System.String]'Description'
#
#Description
#
$Description.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Description.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]63))
$Description.Name = [System.String]'Description'
$Description.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]760,[System.Int32]63))
$Description.TabIndex = [System.Int32]2
$Description.Text = [System.String]$resources.'Description.Text'
#
#Cancel
#
$Cancel.BackColor = [System.Drawing.Color]::LightGray
$Cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Cancel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Cancel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]683,[System.Int32]510))
$Cancel.Name = [System.String]'Cancel'
$Cancel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]89,[System.Int32]39))
$Cancel.TabIndex = [System.Int32]0
$Cancel.Text = [System.String]'Cancel'
$Cancel.UseVisualStyleBackColor = $false
$Cancel.add_Click($Cancel_Click)
#
#ConfigOption
#
$ConfigOption.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$ConfigOption.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]70,[System.Int32]166))
$ConfigOption.Name = [System.String]'ConfigOption'
$ConfigOption.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]141,[System.Int32]24))
$ConfigOption.TabIndex = [System.Int32]7
$ConfigOption.Text = [System.String]'Configuration'
$ConfigOption.add_Click($Configuration_Click)
#
#Validation
#
$Validation.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]14.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Validation.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]70,[System.Int32]196))
$Validation.Name = [System.String]'Validation'
$Validation.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]211,[System.Int32]24))
$Validation.TabIndex = [System.Int32]6
$Validation.Text = [System.String]'Validation and Testing'
$Validation.add_Click($Validation_Click)
#
#SelectionDescription
#
$SelectionDescription.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Times New Roman',[System.Single]12,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$SelectionDescription.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]298,[System.Int32]126))
$SelectionDescription.Name = [System.String]'SelectionDescription'
$SelectionDescription.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]438,[System.Int32]240))
$SelectionDescription.TabIndex = [System.Int32]5
#
#ToolOverview
#
$ToolOverview.AcceptButton = $Next
$ToolOverview.BackColor = [System.Drawing.Color]::White
$ToolOverview.CancelButton = $Cancel
$ToolOverview.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]784,[System.Int32]561))
$ToolOverview.Controls.Add($SelectionDescription)
$ToolOverview.Controls.Add($Validation)
$ToolOverview.Controls.Add($ConfigOption)
$ToolOverview.Controls.Add($Description)
$ToolOverview.Controls.Add($Title)
$ToolOverview.Controls.Add($Cancel)
$ToolOverview.MaximumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]800,[System.Int32]600))
$ToolOverview.MinimumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]800,[System.Int32]600))
$ToolOverview.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$ToolOverview.Text = [System.String]'Tool Overview'
$ToolOverview.ResumeLayout($false)
Add-Member -InputObject $ToolOverview -Name Next -Value $Next -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name Title -Value $Title -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name Description -Value $Description -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name Cancel -Value $Cancel -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name ConfigOption -Value $ConfigOption -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name Validation -Value $Validation -MemberType NoteProperty
Add-Member -InputObject $ToolOverview -Name SelectionDescription -Value $SelectionDescription -MemberType NoteProperty
}
. InitializeComponent
