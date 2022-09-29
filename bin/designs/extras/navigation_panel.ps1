# initialize each class
$NavigationConfiguration = New-Object System.Windows.Forms.Label
$NavigationItem1 = New-Object System.Windows.Forms.Label
$NavigationItem2 = New-Object System.Windows.Forms.Label
$NavigationItem3 = New-Object System.Windows.Forms.Label
$NavigationItem4 = New-Object System.Windows.Forms.Label
$NavigationItem5 = New-Object System.Windows.Forms.Label
$NavigationItem6 = New-Object System.Windows.Forms.Label
$NavigationItem7 = New-Object System.Windows.Forms.Label
$NavigationItem8 = New-Object System.Windows.Forms.Label

#region Toolkit types
# configuration
$NavigationConfiguration.Text = 'Configuration'
$NavigationConfiguration.Font = [System.Drawing.Font]::new("Times New Roman", 14)
$NavigationConfiguration.AutoSize = $true
$NavigationConfiguration.Location = '5,60'
#endregion Toolkit types

#region Initial Values
# Configuration
if($ToolKitConfigurationSelected -eq $true){
    # initial items
    $NavigationItem1.Text = 'CEP Server'
    $NavigationItem2.Text = 'Service Account'
    $NavigationItem3.Text = 'Kerberos Authentication'
    $NavigationItem4.Text = 'Certificate Templates'
    }
#endregion Initial Values

#region Items
# Item1
#$NavigationItem1.Text = $Global:NavigationItem1
$NavigationItem1.ForeColor = 'LightGray'
$NavigationItem1.Location = '15,95'
$NavigationItem1.Size = '170,30'

# Item2
#$NavigationItem2.Text = $Global:NavigationItem2
$NavigationItem2.ForeColor = 'LightGray'
$NavigationItem2.Location = '15,125'
$NavigationItem2.Size = '170,30'

# Item3
#$NavigationItem3.Text = $Global:NavigationItem3
$NavigationItem3.ForeColor = 'LightGray'
$NavigationItem3.Location = '15,155'
$NavigationItem3.Size = '170,30'

# Item4
#$NavigationItem4.Text = $Global:NavigationItem4
$NavigationItem4.ForeColor = 'LightGray'
$NavigationItem4.Location = '15,185'
$NavigationItem4.Size = '170,30'

# Item5
#$NavigationItem5.Text = $Global:NavigationItem4
$NavigationItem5.ForeColor = 'LightGray'
$NavigationItem5.Location = '15,215'
$NavigationItem5.Size = '170,30'

# Item6
#$NavigationItem6.Text = $Global:NavigationItem4
$NavigationItem6.ForeColor = 'LightGray'
$NavigationItem6.Location = '15,245'
$NavigationItem6.Size = '170,30'

# Item7
#$NavigationItem7.Text = $Global:NavigationItem4
$NavigationItem7.ForeColor = 'LightGray'
$NavigationItem7.Location = '15,275'
$NavigationItem7.Size = '170,30'

# Item8
#$NavigationItem8.Text = $Global:NavigationItem4
$NavigationItem8.ForeColor = 'LightGray'
$NavigationItem8.Location = '15,305'
$NavigationItem8.Size = '170,30'
#endregion Items

# #region Configuration
# # CEP Server
# $NavigationCepServer.Text = 'Certificate Enrollment Policy (CEP) Server'
# $NavigationCepServer.ForeColor = 'Black'
# $NavigationCepServer.Location = '15,95'
# $NavigationCepServer.Size = '170,40'

# # Service Account
# $NavigationServiceAccount.Text = 'Service Account'
# $NavigationServiceAccount.ForeColor = 'LightGray'
# $NavigationServiceAccount.Location = '15,145'
# $NavigationServiceAccount.Size = '170,30'

# # Kerberos
# $NavigationKerberosAuth.Text = 'Kerberos Authentication'
# $NavigationKerberosAuth.ForeColor = 'LightGray'
# $NavigationKerberosAuth.Location = '15,175'
# $NavigationKerberosAuth.Size = '170,30'

# # Certificate templates
# $NavigationCertTemplates.Text = 'Certificate Templates'
# $NavigationCertTemplates.ForeColor = 'LightGray'
# $NavigationCertTemplates.Location = '15,205'
# $NavigationCertTemplates.Size = '170,30'
# #endregion

#region Add to navigation pane

# default navigation pane
$ToolKitAppNavigationPane.Controls.AddRange(@(
    $NavigationConfiguration,
    $NavigationItem1,
    $NavigationItem2,
    $NavigationItem3,
    $NavigationItem4,
    $NavigationItem5,
    $NavigationItem6,
    $NavigationItem7,
    $NavigationItem8
))