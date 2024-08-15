. (Join-Path $ToolBoxConfig.ScriptHome $ToolBoxConfig.Variables.Validation -ErrorAction Stop)

Write-Host "`n[Registering Required Variables]"
$PolicyServerObject = Register-PolicyServer -IncludeAlias `
    -Server $PolicyServer `
    -Alias $PolicyServerAlias

$AccountName = Register-ServiceAccount -ValidateExists `
    -Account $AccountName `

$KerberosKeytab = Register-File `
    -Message "Enter the full path to the keytab file" `
    -FilePath $KerberosKeytab `
    -FileType "Kerberos Keytab" `
    -Validate

$KerberosKrb5 = Register-File `
    -Message "Enter the full path to the krb5 file" `
    -FilePath $KerberosKrb5 `
    -FileType "Kerberos Krb5" `
    -Validate

$TemplateContext = Register-CertificateTemplateContext `
    -Context $TemplateContext

Switch ($TemplateContext) {
    "Computer" {
        $TemplateName = Register-CertificateTemplate `
            -Template $TemplateComputer `
            -Context "Computer"

        $TemplateSecurityGroup = Register-AutoenrollSecurityGroup `
            -Group $TemplateComputerGroup `
            -Context "Computer" `
            -Validate
    }
    "User" {
        $TemplateName = Register-CertificateTemplate `
            -Template $TemplateUser `
            -Context "User"

        $TemplateSecurityGroup = Register-AutoenrollSecurityGroup `
            -Group $TemplateUserGroup `
            -Context "User" `
            -Validate
    }
}

Write-Host "`n[Validation]"

Test-ServiceAccount `
    -Account $AccountName `
    -ServicePrincipalName $PolicyServerObject.SPN

Test-Kerberos `
    -Keytab $KerberosKeytab `
    -Krb5 $KerberosKrb5 `
    -Principal $PolicyServerObject.UPN

Test-CepServerEndpoint -Uri $PolicyServerObject.Uri 

Test-CertificateTemplates `
    -Template $TemplateName `
    -Group $TemplateSecurityGroup `
    -ForestDn $ToolBoxConfig.ParentDomain `
    -Context $TemplateContext

# Build
$ValidationResults = @(
foreach($Category in $Validation.GetEnumerator()){
    $FailedTests = $Category.Value.Tests.PSObject.Properties | where {$_.Value.Result -eq $Result.Failed}
    foreach($Test in $FailedTests){
        [PSCustomObject]@{
            Title = $Test.Value.Title
            Category = $Category.Value.Title
            Status = $Test.Value.Status
        }
    }
})

# Write-Host "The following test case(s) failed:" -NoNewLine
# $ValidationResults | Format-List