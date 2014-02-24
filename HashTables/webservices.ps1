$kolliid="89188232038SE"

function Get-PostenPackageTracking ($kolliid)
{
    Invoke-RestMethod -Uri "http://server.logistik.posten.se/servlet/PacTrack?kolliid=$kolliid"
}

$PackageInfo = Get-PostenPackageTracking $kolliid
$PackageInfo.pactrack.body.parcel
$PackageInfo.pactrack.body.parcel.event | ft -AutoSize




















$TextTV  = Invoke-RestMethod http://texttv.nu/api/get/100
$TextTV.content -replace "<.*?>","" | write-Host -BackgroundColor Black -ForegroundColor White

















$Weather = Invoke-RestMethod http://www.yr.no/place/Sweden/Stockholm/Humleg%C3%A5rden/forecast.xml
$forecast = $Weather.weatherdata.forecast.tabular.time | select -First 5

$forecastObject = $forecast | Select-Object @{Name = "Time";Expression={Get-date ($_.from)}},
    @{Name = "Weather";Expression={$_.symbol.name}},
    @{Name = "temperature";Expression={$_.temperature.value}},
    @{Name = "precipitation";Expression={$_.precipitation.value}},
    @{Name = "windSpeed";Expression={"$($_.windSpeed.name) ($($_.windSpeed.mps) m/s)"}},
    @{Name = "windDirection";Expression={$_.windDirection.name}}

$forecastObject  | ft -AutoSize




$Weather = Invoke-RestMethod  http://www.yr.no/place/Sweden/Stockholm/Humlegården/forecast_hour_by_hour.xml

$forecast = $Weather.weatherdata.forecast.tabular.time | select -First 24

$forecastObject = $forecast | Select-Object @{Name = "Time";Expression={Get-date ($_.from)}},
    @{Name = "Weather";Expression={$_.symbol.name}},
    @{Name = "temperature";Expression={$_.temperature.value}},
    @{Name = "precipitation";Expression={$_.precipitation.value}},
    @{Name = "windSpeed";Expression={"$($_.windSpeed.name) ($($_.windSpeed.mps) m/s)"}},
    @{Name = "windDirection";Expression={$_.windDirection.name}}

$forecastObject  | ft -AutoSize





$password = "codemocracy" | ConvertTo-SecureString -asPlainText -Force
$username = "tagtider" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
$tmp = invoke-RestMethod -Uri "http://api.tagtider.net/v1/stations/243/transfers/departures.xml" -Credential $credential -OutFile "$env:TEMP\tag.xml"
[xml]$departures = Get-Content -Path "$env:TEMP\tag.xml" -Encoding UTF8
Remove-Item "$env:TEMP\tag.xml" -Force
$departures.response.station.name
$departures.response.station.transfers.transfer | where-Object {$_.destination -like "*södertälje*"} |
    Select-Object departure, newDeparture, destination,track,type | ft -AutoSize










$password = "codemocracy" | ConvertTo-SecureString -asPlainText -Force
$username = "tagtider" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
$tmp = invoke-RestMethod -Uri "http://api.tagtider.net/v1/stations/267/transfers/departures.xml" -Credential $credential -OutFile "$env:TEMP\tag.xml"
[xml]$departures = Get-Content -Path "$env:TEMP\tag.xml" -Encoding UTF8
Remove-Item "$env:TEMP\tag.xml" -Force
$departures.response.station.name
$departures.response.station.transfers.transfer | where-Object {$_.destination -like "*stockholm*"} | 
    Select-Object departure, newDeparture, destination,track,type | ft -AutoSize
