<#
.SYNOPSIS
Retrieves information from vananaarbeter.nl about current and future obstructions on Dutch roads.
#>
function Get-RoadObstruction
{
    param
    (
        [Parameter(Position = 1)]
        [string[]]$RoadNo,

        [ValidateNotNullOrEmpty()]
        [DateTime]$FromDate = (Get-Date),

        [ValidateNotNullOrEmpty()]
        [DateTime]$ToDate = (Get-Date)
    )    

    $RoadNo | ForEach-Object {
        $Url = "https://rws01.sharewire.net/obstructions/?road_number={0}&from={1:yyyy-MM-dd}&to={2:yyyy-MM-dd}" -f $_, $FromDate, $ToDate

        Invoke-RestMethod -Uri $Url -Headers @{'RWS-API-KEY' = 'v5jaGACh!2S4JQ4Uehcq-hU6v3J2qpvc'; 'DNT' = '1'} | 
            Select-Object -ExpandProperty data | 
            Select-Object -ExpandProperty obstructions | 
            ForEach-Object {
            $Obstruction = $_

            $Obstruction |
                Select-Object -ExpandProperty periods |
                ForEach-Object {
                $Period = $_

                $Properties = [Ordered]@{}
                $Properties.ID = $Obstruction.obstruction_id
                $Properties.RoadName = $Obstruction.road_name
                $Properties.RoadNo = $Obstruction.road_number
                $Properties.BothWays = $Obstruction.both_ways
                $Properties.FromName = $Obstruction.from_name
                $Properties.ToName = $Obstruction.to_name
                $Properties.StartDate = [DateTime]::ParseExact($Period.start_date, 'yyyy-MM-dd HH:mm:sszz', $null)
                $Properties.EndDate = [DateTime]::ParseExact($Period.end_date, 'yyyy-MM-dd HH:mm:sszz', $null)
                $Properties.What = $Obstruction.what
                $Properties.Why = $Obstruction.why
                $Properties.Description = $Obstruction.obstruction_text
                $Properties.DelayShort = $Obstruction.delay_short
                $Properties.DelayLong = $Obstruction.delay_long
                $Properties.Roads = $Obstruction.roads
                $Properties.UrlPdf = $Obstruction.url_pdf
                $Properties.UrlWww = $Obstruction.url_www

                if ($Obstruction.center_point -match '<Point><coordinates>(?<longitude>.*?),(?<latitude>.*?)</coordinates></Point>')
                {
                    $Properties.Latitude = $Matches['latitude']
                    $Properties.Longitude = $Matches['longitude']
                }

                $Result = [PSCustomObject]$Properties
                $Result.PSObject.TypeNames.Insert(0, 'UncommonSense.Traffic.RoadObstruction')

                $Result
            }

        }   
    }
}