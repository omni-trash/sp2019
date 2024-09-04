Import-Module SharePointPnPPowerShell2019
$ErrorActionPreference = "Stop"

# Status 0 : ausstehend  (pending)
# Status 1 : genehmigt   (approved)
# Status 2 : angenommen  (accepted)
# Status 3 : abgelehnt   (declined)

function checkAccessRequests {
    param(
    [Parameter(ValueFromPipeline=$true)]
    $webToCheck,
    [string[]]
    $mode
    )

    process {
        Write-Host "---------------------------------------------------------------------------"
        Write-Host "Check Access Requests for Web: " $webToCheck.Title
        $web = Get-PnPWeb -Identity $webToCheck -inc HasUniqueRoleAssignments,RequestAccessEmail,Fields,EffectiveBasePermissions,AvailableFields,AllProperties,AssociatedVisitorGroup
        Write-Host "RequestAccessEmail: "$web.RequestAccessEmail

        if ($web.HasUniqueRoleAssignments -eq $true) {
            $guid   = $web.AllProperties["_VTI_ACCESSREQUESTSLISTID"] -split ',' | select -First 1

            if ([System.String]::IsNullOrWhiteSpace($guid) -eq $false) {
                $list = $web.Lists.GetById($guid)
                $web.Context.Load($list)
                $web.Context.ExecuteQuery()

                Write-Host "AssociatedVisitorGroup: "$web.AssociatedVisitorGroup.Id", "$web.AssociatedVisitorGroup.LoginName

                if ($list -ne $null) {
                    Write-Host $list.ItemCount Zugriffsanforderungen gesamt
                    $fields = Get-PnPField -List $list | select -ExpandProperty InternalName 

                    $list | Get-PnPListItem -Fields $fields -ScriptBlock { Param($items) $items.Context.ExecuteQuery() } | %{
                        $isInFilter = $false;

                        if ($_["Status"] -eq "0" -and $mode.Contains("status0")) {
                            $isInFilter = $true;

                            # ausstehend (pending)
                            Write-Host "For: $($_["RequestedForDisplayName"]), By: $($_["RequestedByDisplayName"]), Date: ""$($_["RequestDate"])"", Conversation: ""$($_["Conversation"])"", Level: $($_["PermissionLevelRequested"]), Status: ausstehend $($_["Status"])"

                            if ($mode.Contains("grant")) {
                                # Visitor Group
                                $_["PermissionLevelRequested"] = $web.AssociatedVisitorGroup.Id
                                $_["Status"] = 1
                                $_.Update()

                                # Add the user to the Visitor Group
                                Add-PnPUserToGroup -Identity $web.AssociatedVisitorGroup -LoginName $_["RequestedFor"]
                            }
                        }

                        if ($_["Status"] -eq "1" -and $mode.Contains("status1")) {
                            $isInFilter = $true;

                            # genehmigt (approved)
                            Write-Host "For: $($_["RequestedForDisplayName"]), By: $($_["RequestedByDisplayName"]), Date: ""$($_["RequestDate"])"", Conversation: ""$($_["Conversation"])"", Level: $($_["PermissionLevelRequested"]), Status: genehmigt $($_["Status"])"
                        }

                        if ($_["Status"] -eq "2" -and $mode.Contains("status2")) {
                            $isInFilter = $true;

                            # angenommen (accepted)
                            Write-Host "For: $($_["RequestedForDisplayName"]), By: $($_["RequestedByDisplayName"]), Date: ""$($_["RequestDate"])"", Conversation: ""$($_["Conversation"])"", Level: $($_["PermissionLevelRequested"]), Status: angenommen $($_["Status"])"
                        }

                        if ($_["Status"] -eq "3" -and $mode.Contains("status3")) {
                            $isInFilter = $true;

                            # abgelehnt (declined)
                            Write-Host "For: $($_["RequestedForDisplayName"]), By: $($_["RequestedByDisplayName"]), Date: ""$($_["RequestDate"])"", Conversation: ""$($_["Conversation"])"", Level: $($_["PermissionLevelRequested"]), Status: abgelehnt $($_["Status"])"
                        }

                        if ($isInFilter -eq $true -and $mode.Contains("delete")) {
                            Write-Host "Say Goodbye to ID $($_.id), ""$($_["Title"])"" "
                            #$_.DeleteObject() # dauerhaft löschen
                            #$_.Recycle()      # in den ersten Papierkorb verschieben
                        }
                    }
                }
            }
        }

        # subwebs
        if ($mode.Contains("subwebs")) {
            $web.Context.Load($web.Webs)
            $web.Context.ExecuteQuery()
            $web.Webs | checkAccessRequests -mode $mode
        }
    }
}

cls
Connect-PnPOnline "https://server/subsite" -CurrentCredentials
Get-PnPWeb | checkAccessRequests -mode $("status0")
#Get-PnPWeb | checkAccessRequests -mode $("status0", "subwebs")
#Get-PnPWeb | checkAccessRequests -mode $("status0", "delete")
#Get-PnPWeb | checkAccessRequests -mode $("status0", "subwebs" "delete")
Disconnect-PnPOnline

