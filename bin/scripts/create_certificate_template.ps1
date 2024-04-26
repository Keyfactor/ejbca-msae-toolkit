Write-Host $ToolCurrent.Title -ForegroundColor Blue 
Write-Host -ForegroundColor Blue  @("
- $($ToolCurrent.Description)
- The current computer and user will be added with autoenrollment permissions based on the context of the template.") 

Read-HostPrompt "`nHit enter to continue..." -NoInput

try {
    while($true){
        try {
            $AutoEnrollComputerSecurityGroup = Get-ConfigDefault `
                -Prompt "Enter the name for the Security Group to add to the certificate template with autoenrollment permissions" `
                -Config "AutoEnrollComputerSecurityGroup"
    
            if(Get-ADGroupWrapper -Group $AutoEnrollComputerSecurityGroup){
                break
            }
            else {
                $AutoEnrollComputerSecurityGroup=$null
            }
        }
        catch {
            Write-Host $Error[0] -ForegroundColor Red
        }
    }

    $SecurityGroups = Get-SecurityGroups -Computer
    $TemplateComputer = Get-ConfigDefault `
        -Prompt "Enter the name for the new Computer context certiticate template" `
        -Config "TemplateComputer"

    Write-Host "Creating certificate template $TemplateComputer..." -ForegroundColor Yellow
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
            Write-Host "Successfully granted $AutoEnrollComputerSecurityGroup autoenrollment permissions on  $TemplateComputer" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host $Error[0] -ForegroundColor Red
}
