# Für eine bestimmte Liste die Begrenzung ausschalten, sonst nur 5000 Einträge und nervige Warnmeldungen

# https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/get-pnpweb?view=sharepoint-ps
# https://blog.kloud.com.au/2018/02/01/quick-start-guide-for-pnp-powershell/
# https://sharepoint.stackexchange.com/questions/264570/batch-update-via-pnp-powershell

# note PNP is for managing artefacts (create list, add list, add columns, add data etc),
# the spo is for managing the sp itself (add, delete user, permissions, webs etc.)
# sp admin shell is only available on sp server! no stand alone installation exist.

# the old way (without pnp, on sp admin shell)
$web = get-spweb "https://server/subsite"
$list = $web.Lists["Meine Liste"] 
$list | gm
write-host $list.IsThrottled
$list.EnableThrottling = $false 
$list.Update() 
write-host $list.IsThrottled

