# SP2019 Sicherung (Unterwebseiten und Listen)
# 17.08.2020
# SharePoint Administration Shell

$ErrorActionPreference = "Stop"

Add-PSSnapin Microsoft.SharePoint.PowerShell

# 14 days
$backupSlot = ((Get-Date).DayOfYear % 14 + 1)
$backupRoot = "\\Server\Share\Sharepoint\Backup\$backupSlot";
$backupFull = "$backupRoot\full"
$backupList = "$backupRoot\list"

# remove old backups from slot
if (Test-Path "$backupRoot") { 
	#removes the old backup slot folder
    #Rename-Item "$backupRoot" "$($backupRoot)_alt"
    #Remove-Item "$($backupRoot)_alt" -Recurse 
}

# ensure directories
if (!(Test-Path "$backupRoot")) { mkdir "$backupRoot" }
if (!(Test-Path "$backupFull")) { mkdir "$backupFull" }
if (!(Test-Path "$backupList")) { mkdir "$backupList" }

# for each subsite
# 1. full backup (including user security)
# 2. list backup
((Get-SPWeb "https://server")).Webs | Select-Object -Property name, url | % { 
    Write-Host "Backup Full ""$($_.url)"" to ""$backupFull\$($_.name)"""
    Export-SPWeb -Identity "$($_.url)" -Path "$backupFull\$($_.name)" -IncludeUserSecurity

    # remember
    $webUrl  = $_.url
    $webName = $_.name

    # for each list, "<web>#<list>"
    (Get-SPWeb -Identity "$webUrl").Lists | % { 
        Write-Host "Backup List ""$url/$($_.title)"" to ""$backupList\$($webName)#$($_.title)"""
        Export-SPWeb -Identity "$webUrl/" -ItemUrl "$($_.parentWebURL)/$($_.RootFolder)" -Path "$backupList\$($webName)#$($_.title)"
    }
}

# Wiederherstellen via Import-SPWeb
