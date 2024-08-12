. (Join-Path $ToolBoxConfig.ScriptHome $ToolBoxConfig.Variables.Validation -ErrorAction Stop)

Write-Host "`n[Registering Required Variables]"
$PolicyServerObject = Register-PolicyServer -IncludeAlias `
    -Server $PolicyServerHostname `
    -Alias $PolicyServerAlias

$ServiceAccountName = Register-ServiceAccount -ValidateExists `
    -Account $ServiceAccountName `

$KerberosKeytab = Register-File `
    -Message "Enter the full path to the keytab file" `
    -FilePath $KerberosKeytab `
    -FileType "Keytab" 

$TemplateContext = Register-CertificateTemplateContext `
    -Context $TemplateContext 

Switch ($TemplateContext) {
    "Computer" {
        $TemplateName = Register-CertificateTemplate -Template $TemplateComputer
        $TemplateSecurityGroup = Register-AutoenrollSecurityGroup `
            -Group $TemplateComputerGroup `
            -Validate
    }
    "User" {
        $TemplateName = Register-CertificateTemplate -Template $TemplateUser 
        $TemplateSecurityGroup = Register-AutoenrollSecurityGroup `
            -Group $TemplateUserGroup `
            -Validate
    }
}

Write-Host "`n[Validation]"

Test-ServiceAccount `
    -Account $ServiceAccountName `
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

Write-Host "The following test case(s) failed:" -NoNewLine
$ValidationResults | Format-List