# Als Laufwerk einbinden (copy files etc. aber achtung, PNP Dateisystem != lokales Filesystem, spezielle Commands benötigt)

Connect-PnPOnline "https://server/subsite" -CurrentCredentials -CreateDrive
Get-PSDrive
cd SPO:\
dir
