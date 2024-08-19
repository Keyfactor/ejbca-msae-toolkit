
Write-Host "`n[Registering Required Variables]"
# Check for existing template if 'tempcreate' passed
if(($Tool -eq "tempperms")){ $ExistingTemplateCheck = $true }

# Get Template context
$TemplateContext = Register-CertificateTemplateContext `
    -Context $TemplateContext 

# Get Template and Security Group
Switch ($TemplateContext) {
    "Computer" {
        $TemplateName = Register-CertificateTemplate `
            -Template $TemplateComputer `
            -Context "Computer" `
            -CheckAlreadyExists:$ExistingTemplateCheck

        $TemplateSecurityGroup = Register-AutoenrollSecurityGroup `
            -Group $TemplateComputerGroup `
            -Context "Computer" `
            -Validate
    }
    "User" {
        $TemplateName = Register-CertificateTemplate `
            -Template $TemplateUser `
            -Context "User" `
            -CheckAlreadyExists:$ExistingTemplateCheck

        $TemplateSecurityGroup = Register-AutoenrollSecurityGroup `
            -Group $TemplateUserGroup `
            -Context "User" `
            -Validate
    }
}

# Get template name and verify it doesnt already exist
if(($Tool -eq "tempcreate")){

    # Write operating to console when running interactive so user knows what is happening
    Write-Host "`n[Create Certificate Template]"
    
    $ResultsCreateTemplate = New-CertificateTemplate `
        -DisplayName $TemplateName `
        -Group $TemplateSecurityGroup `
        -DomainController (Get-ADDomainController).HostName `
        -ForestDn $ToolBoxConfig.ParentDomain `
        -Context "Computer"

} elseif($Tool -eq "tempperms") {
    Write-Host "`n[Update Certificate Template Permissions]"
}

$ResultsSetAutoenroll = Set-CertificateTemplatePermissions `
    -Template $TemplateName `
    -Group $TemplateSecurityGroup `
    -ForestDn $ToolBoxConfig.ParentDomain `
    -ValidateFirst

# A false result means the permissions were already configured
if($ResultsSetAutoenroll){ $LoggerFunctions.Warn() }