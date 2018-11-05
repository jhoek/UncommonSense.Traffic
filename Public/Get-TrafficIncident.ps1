function Get-TrafficIncident
{
    param
    (
        [Parameter(Position = 1)]
        [string[]]$RoadNo
    )

    $Body = @{}
    $Body.apikey = 'QYUEE3fEcFD7SGMJ6E7QBCMzdQGqRkAi'
    $Body.polylines = 'true'
    $Body.polylineBounds = 'true'
    $Body.totals = 'true'
    
    Invoke-RestMethod -Uri https://api.anwb.nl/v1/incidents -Body $Body |
        Select-object -ExpandProperty Roads |
        Where-Object { (-not $RoadNo) -or ($RoadNo -contains $_.road) } |
        Select-Object -ExpandProperty Segments | gm
}

Get-TrafficIncident -RoadNo A58, A13