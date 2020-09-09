# Papierkorb leeren

Connect-PnPOnline "https://server/subsite" -CurrentCredentials

$ctx = Get-PnPContext
$recycleBin = $ctx.Web.RecycleBin
$ctx.Load($recycleBin)
$ctx.ExecuteQuery()

Write-Host "$($recycleBin.Count) Elemente im Papierkorb"

while ($True) {
    $items = $recycleBin | Select-Object -First 1

    if ($items.Count -gt 0)
    {
        Write-Host
        Write-Host "$($items.Count) Elemente werden gelöscht"
        Write-Host

        $items | % { 
            Write-Host "Say Goodbye to $($_.Title)"
            #$_.MoveToSecondState()  # in den zweiten Papierkorb verschieben
            $_.DeleteObject();       # dauerhaft löschen
            $_.Context.ExecuteQuery()
        }

        Write-Host
        Write-Host "$($items.Count) Elemente wurden gelöscht"
		continue
    }
	
	break
}

Disconnect-PnPOnline