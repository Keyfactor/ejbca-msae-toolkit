$Name = 'Service'

Get-ADOrganizationalUnit -Filter "Name -like '*$Name*'" | Select-Object Name,DistinguishedName