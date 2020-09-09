# Gruppen auflisten
Connect-PnPOnline "https://server/subsite" -CurrentCredentials

#$web = Get-PnPWeb "subsite"
#Get-PnPProperty -ClientObject $web -Property SiteGroups
#Get-PnPProperty -ClientObject $web -Property AssociatedOwnerGroup
#Get-PnPProperty -ClientObject $web -Property AssociatedMemberGroup
#Get-PnPProperty -ClientObject $web -Property AssociatedVisitorGroup

#Get-PnPGroup -Identity 1003
#Get-PnPGroupMembers -Identity 1003
#
#Get-PnPProperty -ClientObject $web -Property AssociatedOwnerGroup | Get-PnPGroup
#Get-PnPProperty -ClientObject $web -Property AssociatedOwnerGroup | Get-PnPGroupMembers

# gruppe abfragen (was für ein ...)
#$group = Get-PnPProperty -ClientObject $web -Property AssociatedVisitorGroup
#$group

# user in gruppe anzeigen
#$users = Get-PnPProperty -ClientObject $group -Property Users
#$users

# RoleAssignmentCollection.Groups ???

$list = Get-PnPList -Identity "Meine Liste"
$list | gm

#Get-PnPProperty -ClientObject $list -Property Fields
#$list.Fields | select *

#Get-PnPView -List $list
#$view = Get-PnPView -List $list -Identity 9dfb54ba-f933-49e9-842d-2f89f5b6b7ca
#Get-PnPProperty -ClientObject $view -Property ViewQuery
#$view.ViewQuery
#$view | select *

Disconnect-PnPOnline

