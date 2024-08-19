
$PolicyServerObject = Register-PolicyServer -IncludeAlias `
    -Server $PolicyServer `
    -Alias $PolicyServerAlias

$TemplateContext = Register-CertificateTemplateContext `
    -Context $TemplateContext 

Register-CertificateEnrollmentPolicyServer `
    -AliasUri $PolicyServerObject.AliasUri `
    -Context $TemplateContext 