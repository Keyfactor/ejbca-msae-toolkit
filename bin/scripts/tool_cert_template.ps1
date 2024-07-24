

# Autoenrollment Security Group
$AutoEnrollComputerSecurityGroup = Register-AutoenrollSecurityGroup `
    -Group $TemplateComputerGroup `
    -Validate

# Get template name and verify it doesnt already exist
if(($Tool -eq "tempcreate")){

    # Write operating to console when running interactive so user knows what is happening
    if($NonInteractive){Write-Host "Creating certificate template..." -ForegroundColor Yellow}

    $TemplateComputer = Register-CertificateTemplate `
        -Template $TemplateComputer `
        -Existing:$false
    
    $ResultsCreateTemplate = New-CertificateTemplate `
        -DisplayName $TemplateComputer `
        -DomainController (Get-ADDomainController).HostName `
        -ForestDn $ToolBoxConfig.ParentDomain `
        -Computer

} elseif($Tool -eq "tempperms") {

    # Write operating to console when running interactive so user knows what is happening
    if($NonInteractive){Write-Host "Updating certificate template autoenrollment permissions..." -ForegroundColor Yellow}

    $TemplateComputer = Register-CertificateTemplate `
        -Template $TemplateComputer 

    # Test existing autoenrollment permissions
    $AutoenrollmentPermissionCheck = Test-AutoEnrollmentPermissions `
        -Template $TemplateComputer `
        -Group $TemplateComputerGroup `
        -ForestDn $ToolBoxConfig.ParentDomain
}

if(-not $AutoenrollmentPermissionCheck -or ($ResultsCreateTemplate -eq $true)){
    $ResultsSetAutoenroll = Set-AutoEnrollmentPermissions `
        -Template $TemplateComputer `
        -Group $TemplateComputerGroup `
        -ForestDn $ToolBoxConfig.ParentDomain

} elseif($AutoenrollmentPermissionCheck){
    Write-Host "Security group '$TemplateComputerGroup' is already configured with autoenrollment permissions on $TemplateComputer." `
        -ForegroundColor Yellow
}
