$CategoryList = Get-WlpsCategory
Get-WlpsCategory | where title -eq "nyheter" | Get-WlpsShow
$CategoryList | where title -eq "nyheter" | Get-WlpsShow
$Showlist = Get-WlpsAllShows
$Showlist | Where-Object category_text -eq "Barn" | select title, id
Get-WlpsEpisodes -Name "Jakten på det perfekta livet" 
Get-WlpsShow -Name "Jakten på det perfekta livet"
Get-WlpsShow -Name "Jakten på det perfekta livet" | Get-WlpsEpisodes
Get-WlpsShow -ShowIdNumber "781"
Get-WlpsShow -Shows "/v1/show/781/", "/v1/show/782/" 
Get-WlpsStreams -url http://www.svtplay.se/klipp/918988/hanna-hellquist-traffar-alex-schulman | Sort-Object quality_kbps | Select-Object -last 1 -ExpandProperty url

$stream = Get-WlpsStreams -url http://www.svtplay.se/klipp/918988/hanna-hellquist-traffar-alex-schulman | Sort-Object quality_kbps | Select-Object -last 1 -ExpandProperty url
Start-Process -FilePath  "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe" -ArgumentList $stream

