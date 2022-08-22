$MSAEToolKit = New-Object -TypeName System.Windows.Forms.Form
function InitializeComponent
{
$MSAEToolKit.SuspendLayout()
#
#MSAEToolKit
#
$MSAEToolKit.AutoValidate = [System.Windows.Forms.AutoValidate]::EnablePreventFocusChange
$MSAEToolKit.CausesValidation = $false
$MSAEToolKit.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]784,[System.Int32]561))
$MSAEToolKit.Name = [System.String]'MSAEToolKit'
$MSAEToolKit.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$MSAEToolKit.Text = [System.String]'Keyfactor - MS Auto-Enrollment Tool Kit'
$MSAEToolKit.ResumeLayout($false)
}
. InitializeComponent
