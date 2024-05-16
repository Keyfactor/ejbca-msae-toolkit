
# Autoenrollment Security Group
while($true){
    $AutoEnrollComputerSecurityGroup = Register-AutoEnrollComputerSecurityGroup `
        -SecurityGroup $AutoEnrollComputerSecurityGroup `
        -Validate
    if(-not $AutoEnrollComputerSecurityGroup){
        $AutoEnrollComputerSecurityGroup = $null
    } else {
        break
    }
}


# Get existing security groups for current computer
$SecurityGroups = Get-SecurityGroups -Computer

# Get template name and verify it doesnt already exist
while($true){
    $TemplateComputer = Read-HostPrompt `
        -Message "Enter the name for the new Computer context certiticate template." `
        -Default $TemplateComputer

    if(-not (Test-CertificateTemplate $TemplateComputer)){
        break
    } else {
        $TemplateComputer = $null
    }
}

$LoggerMain.Info("Creating computer context certificate template $TemplateComputer...", $True)
$ResultsCreateTemplate = New-CertificateTemplate `
    -DisplayName $TemplateComputer `
    -Group $AutoEnrollComputerSecurityGroup `
    -DomainController (Get-ADDomainController).HostName `
    -ForestDn $ForestDistinguishedName `
    -Computer

if($ResultsCreateTemplate -ne $true){
    $AutoenrollmentPermissionCheck = Test-AutoEnrollmentPermissions `
        -Template $TemplateComputer `
        -Group $AutoEnrollComputerSecurityGroup `
        -ForestDn $ForestDistinguishedName
}
if(-not $AutoenrollmentPermissionCheck -or ($ResultsCreateTemplate -eq $true)){
    $ResultsSetAutoenroll = Set-AutoEnrollmentPermissions `
        -Template $TemplateComputer `
        -Group $AutoEnrollComputerSecurityGroup `
        -ForestDn $ForestDistinguishedName

    if($ResultsSetAutoenroll){
        Write-Host "Successfully granted $AutoEnrollComputerSecurityGroup autoenrollment permissions on $TemplateComputer" -ForegroundColor Green
    }
}
