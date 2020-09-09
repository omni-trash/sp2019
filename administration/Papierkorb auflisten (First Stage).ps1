# Papierkorb auflisten (First Stage)

Connect-PnPOnline "https://server/subsite" -CurrentCredentials

$ctx = Get-PnPContext
$recycleBin = $ctx.Web.RecycleBin
$ctx.Load($recycleBin)
$ctx.ExecuteQuery()

Write-Host "$($recycleBin.Count) Elemente im Papierkorb"

$recycleBin | % { 
    Write-Host "$($_.Title), gelöscht am $($_.DeletedDate) von $($_.DeletedByEmail)"
}

Disconnect-PnPOnline

