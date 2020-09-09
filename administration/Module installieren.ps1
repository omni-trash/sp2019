# PowerShell Module installieren
Install-Module -Name SharePointPnPPowerShell2019
Update-Module SharePointPnPPowerShell*
Get-Module SharePointPnPPowerShell* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending

#Beispiele
#Install-Module -Name SharePointPnPPowerShell2013
#Install-Module -Name SharePointPnPPowerShell2016
#Install-Module -Name SharePointPnPPowerShell2019
#Install-Module -Name SharePointPnPPowerShellOnline
#Install-Module -Name Microsoft.Online.SharePoint.PowerShell
