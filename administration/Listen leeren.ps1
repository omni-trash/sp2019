# Listen leeren (die Elemente löschen)

Connect-PnPOnline "https://server/subsite" -CurrentCredentials

$listen = ("Liste1", "Liste2", "Liste3")

foreach ($liste in $listen) 
{
   Write-Host "Leere Liste: $liste"

   Get-PnPList -Identity $liste | Get-PnPListItem -Fields "Title" -ScriptBlock { Param($items) $items.Context.ExecuteQuery() } | %{
        Write-Host "Say Goodbye to ID $($_.id), ""$($_["Title"])"""
        #$_.DeleteObject() # dauerhaft löschen
        $_.Recycle()       # in den ersten Papierkorb verschieben
    }
}

Disconnect-PnPOnline
