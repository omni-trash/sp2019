# Alte Workflows entfernen (also die vorherigen inaktiven Versionen)

Connect-PnPOnline "https://server/subsite" -CurrentCredentials

$ctx = Get-PnPContext

$listen = ("Liste1", "Liste2", "Liste3")

foreach ($liste in $listen) 
{
    $list = Get-PnPList -Identity $liste -Includes WorkflowAssociations
    $items = $list.WorkflowAssociations | Select-Object
    $items | ? Enabled -EQ $false | % { 
        Write-Host Remove outdated Workflow $_.Name
        $_.DeleteObject() 
    }

    $ctx.ExecuteQuery()
}

Disconnect-PnPOnline
