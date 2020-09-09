# Papierkorb leeren (farm admin)

$ErrorActionPreference = "Stop"

Connect-PnPOnline "https://server/subsite" -CurrentCredentials

$ctx = Get-PnPContext

$query = New-Object Microsoft.SharePoint.Client.RecycleBinQueryInformation
$query.RowLimit = 1
$query.ShowOnlyMyItems = $false;
$query.ItemState = "FirstStageRecycleBin" # 0: None, 1: FirstStageRecycleBin, 2: SecondStageRecycleBin

while ($True) {
    $items = $ctx.Web.GetRecycleBinItemsByQueryInfo($query)

    $ctx.Load($items)
    $ctx.ExecuteQuery()

    if ($items.Count -gt 0)
    {
        $items | % { 
            Write-Host $_.Title
            Clear-PnpRecycleBinItem -Identity $_.id.toString() -Force
        }

		continue
    }

	break
}

Disconnect-PnPOnline
