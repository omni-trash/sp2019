# Spalte in DisplayForm ausblenden, Status ist hier eine berechnete Spalte

Connect-PnPOnline "https://server/subsite" -CurrentCredentials

$items = @(
    @{ Liste = "Liste1"; Spalten = @("Aktion") },
    @{ Liste = "Liste2"; Spalten = @("Status") },
    @{ Liste = "Liste3"; Spalten = @("Status") }
)

foreach ($item in $items)
{
    $liste = $item.Liste
    $spalten = $item.Spalten

    foreach ($spalte in $spalten)
    {
        Write-Host "$($liste):$($spalte) wird ausgeblendet";
		
		$field = Get-PnPField -List $liste -Identity $spalte

		$field.SetShowInDisplayForm($False);
		#$field.SetShowInNewForm($False);
		#$field.SetShowInEditForm($False);

		#$field.ReadOnlyField = $True;

		$field.Update()
		$field.Context.ExecuteQuery()
    }
}
	
Disconnect-PnPOnline

