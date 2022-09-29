$Entry.Clear()

$Search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$Search.filter = "(servicePrincipalName=*)"
$SearchResults = $Search.Findall()

foreach($Result in $SearchResults){
    $Entry = $Item.GetDirectoryEntry()
    if($($Entry.servicePrincipalName) -eq $Global:CepServerSPN){

        Write-Host "Error: $Global:CepServerSPN is already assigned to '$($Entry.Name)'" -ForegroundColor Yellow
        Write-Host "Click the 'Fix' button to remove it from '$($Entry.Name)' and add it to '$Global:ServiceAccount'." -ForegroundColor Yellow
        
    }

    
}



$Search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$Search.filter = "(servicePrincipalName=*)"
$Result = $Search.Findall()
$ExistingSPNAccount = $Result.GetDirectoryEntry()

if([string]::IsNullOrEmpty($ExistingSPNAccount) -ne $true){

    if($($ExistingSPNAccount.Name) -eq $Global:ServiceAccount){

    Write-Host "Error: $Global:CepServerSPN is already assigned to '$($ExistingSPNAccount.Name)'" -ForegroundColor Yellow
    Write-Host "Click the 'Fix' button to remove it from '$($ExistingSPNAccount.Name)' and add it to '$Global:ServiceAccount'." -ForegroundColor Yellow

    }

}

else {

    Write-Host 'The SPN doesnt exist' -ForegroundColor Yellow
    
}
