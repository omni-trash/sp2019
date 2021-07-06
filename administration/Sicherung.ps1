# SP2019 Sicherung (Unterwebseiten und Listen)
# 17.08.2020
# SharePoint Administration Shell
# 05.07.2021
# - Listen aus Root sichern

$ErrorActionPreference = "Stop"

Add-PSSnapin Microsoft.SharePoint.PowerShell

# 14 days
$backupSlot = ((Get-Date).DayOfYear % 14 + 1)
$backupRoot = "\\barodcbuel5\BUEL\EDV\Sharepoint\Backup\$backupSlot";
$backupFull = "$backupRoot\full"
$backupList = "$backupRoot\list"

# remove old backups from slot
if (Test-Path "$backupRoot") { 
    Rename-Item "$backupRoot" "$($backupRoot)_alt"
    Remove-Item "$($backupRoot)_alt" -Recurse 
}

# ensure directories
if (!(Test-Path "$backupRoot")) { mkdir "$backupRoot" }
if (!(Test-Path "$backupFull")) { mkdir "$backupFull" }
if (!(Test-Path "$backupList")) { mkdir "$backupList" }

$root = ((Get-SPWeb "https://server"));
$webs = @($root) + $root.Webs;

# for each web
# 1. full backup (user security included)
# 2. list backup
$webs | Select-Object -Property name, url | % {
    # remember
    $webUrl  = $_.url
    $webName = $_.name

    # web full backup (except root)
    if ($webName -ne $root.name) {
        Write-Host "Backup Full ""$($webUrl)"" to ""$backupFull\$($webName)"""
        Export-SPWeb -Identity "$($webUrl)" -Path "$backupFull\$($webName)" -IncludeUserSecurity
    }

    # for each list "<web>#<list>" or "#<list>" if root web
    (Get-SPWeb -Identity "$webUrl").Lists | % { 
        Write-Host "Backup List ""$url/$($_.title)"" to ""$backupList\$($webName)#$($_.title)"""
        Export-SPWeb -Identity "$webUrl/" -ItemUrl "$($_.parentWebURL.TrimEnd("/"))/$($_.RootFolder)" -Path "$backupList\$($webName)#$($_.title)"
    }
}

# Liste/Web importieren
# Import-SPWeb -Identity "https://server/<website>" -Path "<path to backup>\<your list>.cmp" -IncludeUserSecurity
# Note: IncludeUserSecurity will restore "Created" and "Modified" for each item
# Node: IncludeUserSecurity will restore "Author" and "Editor" for each item only if you have system privileges (example sharepoint service account)
#
# sample export a list and import to another website
# Export-SPWeb -Identity https://server/ -ItemUrl /Lists/Bestellungen -Path \\Backup\202010705\#Bestellungen
# Import-SPWeb -Identity "https://server/website" -Path "\\Backup\202010705\#Bestellungen.cmp" -IncludeUserSecurity
