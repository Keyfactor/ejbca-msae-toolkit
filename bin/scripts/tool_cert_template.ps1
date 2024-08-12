
# Get Template context
$TemplateContext = Register-CertificateTemplateContext `
    -Context $TemplateContext 

Switch ($TemplateContext) {
    "Computer" {
        $TemplateName = Register-CertificateTemplate `
            -Template $TemplateComputer `
            -Existing:$false

        $TemplateSecurityGroup = Register-AutoenrollSecurityGroup `
            -Group $TemplateComputerGroup `
            -Validate
    }
    "User" {
        $TemplateName = Register-CertificateTemplate `
            -Template $TemplateUser `
            -Existing:$false

        $TemplateSecurityGroup = Register-AutoenrollSecurityGroup `
            -Group $TemplateUserGroup `
            -Validate
    }
}

# Get template name and verify it doesnt already exist
if(($Tool -eq "tempcreate")){

    # Write operating to console when running interactive so user knows what is happening
    if($NonInteractive){Write-Host "`nCreating certificate template '$TemplateName'..."}
    
    $ResultsCreateTemplate = New-CertificateTemplate `
        -DisplayName $TemplateName `
        -Group $TemplateSecurityGroup `
        -DomainController (Get-ADDomainController).HostName `
        -ForestDn $ToolBoxConfig.ParentDomain `
        -Context "Computer"

} elseif($Tool -eq "tempperms") {
    if($NonInteractive){Write-Host "`nUpdating certificate template '$TemplateName' autoenrollment permissions..."}
}

$ResultsSetAutoenroll = Set-CertificateTemplatePermissions `
    -Template $TemplateName `
    -Group $TemplateSecurityGroup `
    -ForestDn $ToolBoxConfig.ParentDomain `
    -ValidateFirst

# A false result means the permissions were already configured
if($ResultsSetAutoenroll){ $LoggerFunctions.Warn() }