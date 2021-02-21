<# 
    Legt Kalendereinträge für folgende Tage an:

    Arbeitsfreie Tage
        - bewegliche Feiertage
        - feste Feiertage
        - Wochenenden

    Für die festen Feiertage (Neujahr, Weihnachten etc.) und für die Wochenenden
    werden keine Serien erstellt (Recurrence Events), da diese immer schwer abzufragen
    sind (DateRangesOverlap). 
    
    Vorteil (ohne Serie):
        im Gebrauch einfacher abzufragen

    Nachteil (ohne Serie):
        Erstellung dauert länger
#>

using namespace System

$ErrorActionPreference = "Stop"

cls

# für die nächsten drei Jahre
$yearFirst = (Get-Date).Year
$yearLast  = $yearFirst + 2

# welcher Kalender (bitte erstmal einen frischen neuen Kalender erstellen und testen!)
$website   = "http://sp2019"
$calendar  = "Feiertage"

# Osterformel von Carl Friedrich Gauß
function feiertageBeweglich {
    param (
        [int]
        $jahr
    )

    # Festlegungen: 
    # - Allgemein geht es um den 1. Sonntag nach 1. Vollmond nach Frühlingsanfang
    # - Frühlingsanfang ist 21. März
    # - Ostern ist spätestens am 25. April

    $M = 24
    $N = 5

    $a = $jahr % 19;
    $b = $jahr % 4;
    $c = $jahr % 7;
    $d = ($a * 19 + $M) % 30;
    $e = (($b * 2) + ($c * 4) + ($d * 6) + $N) % 7;
    $offset = $d + $e + 22
    $error1 = ((11 * $M + 11) % 30 -lt 19)

    # offset gleich Tage ab März (kann auch bis in den April gehen!)
    # wir brauchen quasi 1. März minus 1 (Schaltjahr wird automatisch berechnet)
    # und dann den offset oben drauf, dann haben wir Ostersonntag.
    # Hinweis: nehmen hier UTC für den SP Kalender, weil dann keine Timezone drin ist
    $ostern = (New-Object DateTime $jahr, 3, 1, 0, 0, 0, ([DateTimeKind]::Utc)).Date.AddDays(-1).AddDays($offset)

    # > 25. April Regel
    while ($ostern.Month -ge 4 -and $ostern.Day -gt 25) {
        $ostern = $ostern.AddDays(-7)
    }

    # = 25. April Korrektur
    if ($error1 -eq $true -and $ostern.Month -eq 4 -and $ostern.Day -eq 25 -and $d -eq 28 -and $e -eq 6) {
        $ostern = $ostern.AddDays(-7)
    }

    # Array mit Hashtable (nicht [PSCustomObject])
    return @(
        @{
            Titel = "Karfreitag";
            Datum = $ostern.AddDays(-2)
        },
        @{
            Titel = "Ostermontag";
            Datum = $ostern.AddDays(1)
        },
        @{
            Titel = "Himmelfahrt";
            Datum = $ostern.AddDays(39)
        },
        @{
            Titel = "Pfingstmontag";
            Datum = $ostern.AddDays(50)
        }
    );
}

# feste Feiertage, kann sich von Bundesland zu Bundesland unterscheiden
function feiertageFest {
    param (
        [int]
        $jahr
    )

    return @(
        @{
            Titel = "Neujahr";
            Datum = (New-Object DateTime $jahr, 1, 1, 0, 0, 0, ([DateTimeKind]::Utc))
        },
        @{
            Titel = "Heilige Drei Könige";
            Datum = (New-Object DateTime $jahr, 1, 6, 0, 0, 0, ([DateTimeKind]::Utc))
        },
        @{
            Titel = "Tag der Arbeit";
            Datum = (New-Object DateTime $jahr, 5, 1, 0, 0, 0, ([DateTimeKind]::Utc))
        },
        @{
            Titel = "Tag der Deutschen Einheit";
            Datum = (New-Object DateTime $jahr, 10, 3, 0, 0, 0, ([DateTimeKind]::Utc))
        },
        @{
            Titel = "Reformationstag";
            Datum = (New-Object DateTime $jahr, 10, 31, 0, 0, 0, ([DateTimeKind]::Utc))
        },
        @{
            Titel = "1. Weihnachtstag";
            Datum = (New-Object DateTime $jahr, 12, 25, 0, 0, 0, ([DateTimeKind]::Utc))
        },
        @{
            Titel = "2. Weihnachtstag";
            Datum = (New-Object DateTime $jahr, 12, 26, 0, 0, 0, ([DateTimeKind]::Utc));
        }
    );
}

# Samstag/Sonntag (alle Tage für das Jahr)
function wochenende {
    param (
        [int]
        $jahr
    )

    $day  = [DateTime](New-Object DateTime $jahr, 1, 1, 0, 0, 0, ([DateTimeKind]::Utc));
    $days = @()

    while ($day.Year -eq $jahr) {
        # https://docs.microsoft.com/de-de/dotnet/api/system.dayofweek?view=net-5.0
        switch ($day.DayOfWeek.value__) {
            0 { 
                $days = $days + @{
                    Titel = "Sonntag";
                    Datum = $day;
                }
            }
            6 { 
                $days = $days + @{
                    Titel = "Samstag";
                    Datum = $day;
                }
            }
        }

        $day = $day.AddDays(1)
    }

    return $days
}

# Array mit Feiertag-Kalendereintrag
$events = @();

# bewegliche Feiertage, feste Feiertage und Wochenenden
for ($jahr = $yearFirst; $jahr -le $yearLast; $jahr++) {

    $arbeitsfrei = (feiertageBeweglich -jahr $jahr) + (feiertageFest -jahr $jahr ) + (wochenende -jahr $jahr)

    $arbeitsfrei | % {
        # shortcut
        $feiertag = $_

        #Write-Host --------------------------------------
        #Write-Host $feiertag["Titel"]
        #Write-Host $feiertag["Datum"]

        # Einen Kalender-Eintrag konsturieren und merken.
        # Wir nutzen nur den Tag (.Date), weil mit Urhzeit kanne es Probleme
        # geben, wenn SP nicht korrekt eingestellt ist (Timezone)
        # bzw man müsste noch mehr Sachen mit angeben damit das ganze korrekt hinhaut.
        # Benötigen auch nur den Tag, denn es ist ein ganztägiges Ereignis.
        $event = @{
            "Title"        = $feiertag["Titel"];
            "Category"     = "arbeitsfrei";
            "fAllDayEvent" = $true; 
            "EventDate"    = $feiertag["Datum"].Date;
            "EndDate"      = $feiertag["Datum"].Date
        }

        $events = $events + $event
    }
}


###############################################################################################    
# soweit so gut, jetzt den Kalender mit den Events befüllen
# TODO: neuen Kalender auf SP erstellen!

# Erstellt zuerst einen neuen Kalender zum Testen und kontrolliert
# nochmal die Ergebnisse, ob das alles so passt, und der Karfreitag
# bsplw. auch auf Freitag im Kalender steht.
###############################################################################################

Connect-PnPOnline $website -CurrentCredentials

$list = Get-PnPList -Identity $calendar

$events | % {
    $event = $_
    $date  = $event["EventDate"].ToString("yyyy-MM-ddTHH:mm:ssZ")

    Write-Host --------------------------------------
    Write-Host Prüfe $event["Title"] $event["EventDate"]

    # Ergebnisse reduzieren, wir fragen die Einträge für diesen einen Tag ab
    $query = "
    <View>
        <Query>
            <Where>
                <Eq>
                    <FieldRef Name='EventDate' />
                    <Value Type='DateTime' IncludeTimeValue='FALSE'>$date</Value>
                </Eq>
            </Where>
        </Query>
    </View>"

    # check event exist or not
    $items = Get-PnPListItem -List $list -Query $query | ? { $_["Title"] -EQ $event["Title"] }

    if ($items.Count -eq 0) {
        Add-PnPListItem -List $list -Values $event | % {
            Write-Host $_["Title"] $_["EventDate"]
            Write-Host Eintrag wurde hinzefügt -ForegroundColor Green
        }
    } else {
        Write-Host Eintrag bereits vorhanden -ForegroundColor Cyan
    }
}

Disconnect-PnPOnline
