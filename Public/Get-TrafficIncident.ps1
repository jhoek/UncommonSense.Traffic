function Get-TrafficIncident
{
    param
    (
        [Parameter(Position = 1)]
        [string[]]$RoadNo
    )

    $Body = @{}
    $Body.apikey = 'QYUEE3fEcFD7SGMJ6E7QBCMzdQGqRkAi'
    $Body.polylines = 'false'
    $Body.polylineBounds = 'false'
    $Body.totals = 'false'
    
    Invoke-RestMethod -Uri https://api.anwb.nl/v1/incidents -Body $Body |
        Select-object -ExpandProperty Roads |
        Where-Object { (-not $RoadNo) -or ($RoadNo -contains $_.road) } |
        Select-Object -ExpandProperty Segments | 
        Where-Object { $_ | Get-Member jams } | 
        ForEach-Object {
        $CurrentSegment = $_

        $CurrentSegment |
            Select-Object -ExpandProperty jams | 
            ForEach-Object {
            $CurrentIncident = $_

            $Properties = @{
                RoadNo      = $CurrentIncident.Road
                SegmentFrom = $CurrentSegment.Start
                SegmentTo   = $CurrentSegment.End
                JamFrom     = $CurrentIncident.From
                JamTo       = $CurrentIncident.To
                Delay       = [timespan]::FromSeconds($CurrentIncident.Delay)
                Distance    = $CurrentIncident.Distance
                PSTypeName  = 'UncommonSense.Traffic.TrafficIncident'
            }
                
            [pscustomobject]$Properties
        }
    }
}