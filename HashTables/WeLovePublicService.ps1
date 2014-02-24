§Function ConvertTo-WlpsUrlEncode {

<#
.SYNOPSIS
    Just a helper function for other functions.
    UrlEncodes a string

.DESCRIPTION
    UrlEncodes a string

.PARAMETER StringtoEncode
    String to encode

.EXAMPLE
    ConvertTo-WlpsUrlEncode -StringtoEncode "Tom's Hardware"
    Tom%27s+Hardware

#>

    Param
    (
        [parameter(Mandatory=$True)]
        [ValidateNotNull()]
        [String]
        $StringtoEncode
    ) 
    [System.Web.HttpUtility]::UrlEncode($StringtoEncode)
}

Function Get-WlpsAllShows {

<#
.SYNOPSIS
    Returns all Shows on SvtPlay

.DESCRIPTION
    This function will return all the Shows on SvtPlay.

.EXAMPLE
    $Showlist = Get-WlpsAllShows
    $Showlist | Where-Object category_text -eq "Barn"

    category      : /v1/category/1/
    title         : Abbys flygande skola för feer
    url           : http://www.svtplay.se/abbys-flygande-skola-for-feer
    thumbnail     : 
    episodes      : {/v1/episode/56084/, /v1/episode/56413/, /v1/episode/50778/, /v1/episode/54030/...}
    thumbnail_url : http://www.svt.se/barnkanalen/cachable_image/1332771701000/incoming/article30703.svt/ALTERNATES/large/Abbys-Flygande-skola-224.jpg
    id            : 401
    resource_uri  : /v1/show/401/
    category_text : Barn
    episode_Count : 10

    category      : /v1/category/1/
    title         : Abi
    url           : http://www.svtplay.se/abi
    thumbnail     : 
    episodes      : {/v1/episode/56205/}
    thumbnail_url : http://www.svt.se/barnkanalen/cachable_image/1332771928000/incoming/article30723.svt/ALTERNATES/large/Abi-barnprogram-barnkanalen-224.jpg
    id            : 402
     ...


.NOTES
    Uses the api from http://api.welovepublicservice.se/v1

.LINK
    http://dev.bergqvi.st/we-love-public-service

#>

    Param
    (
        [parameter(Mandatory=$False)]
        [Switch]$DoNotShowProgress=$false
    ) 

    $CategoryList = Get-WlpsCategory
    $CategoryHash = @{}
    foreach($Category in $CategoryList){
        $CategoryHash.Add($Category.resource_uri, $Category.title)
    }

    $FirstRun = $true
    $result = Do {
        If ($FirstRun) {
            If (!$DoNotShowProgress) {
                write-progress -activity "Getting Shows" -status "0% Complete:" -percentcomplete 0 -Id 1
            }
            $shows = Invoke-RestMethod "http://api.welovepublicservice.se/v1/show/?format=json"
            $FirstRun = $False
        } else {
            $shows = Invoke-RestMethod "http://api.welovepublicservice.se$($shows.meta.next)"
        }
        $CurrentPercent = [Int32](($shows.meta.offset/$shows.meta.total_count)*100)
        If (!$DoNotShowProgress) {
            write-progress -activity "Getting Shows" -status "$CurrentPercent% Complete:" -percentcomplete $CurrentPercent  -Id 1
        }
        $shows.objects | Select-Object *, `                        @{Name="category_text"; Expression = {$CategoryHash."$($_.category)"}}, `                        @{Name="episode_Count"; Expression = {$_.episodes.count}}
    } while($shows.meta.next -ne $null)
    If (!$DoNotShowProgress) {
        write-progress -activity "Getting Shows" -status "100% Complete:" -percentcomplete 100  -Id 1 -Completed
    }

    $result
}

Function Get-WlpsCategory {

<#
.SYNOPSIS
    Returns all Categorys on SvtPlay

.DESCRIPTION
    This function will return all the Categorys from SvtPlay

.EXAMPLE
    Get-WlpsCategory | where title -eq "nyheter" | Get-WlpsShow


    category       : /v1/category/5/
    title          : Oddasat
    url            : http://www.svtplay.se/oddasat
    thumbnail      : 
    episodes       : {/v1/episode/57089/, /v1/episode/57088/, /v1/episode/57091/, /v1/episode/57090/...}
    thumbnail_url  : http://www.svt.se/cachable_image/1360071664000/svts/article1007150.svt/ALTERNATES/large/oddasataffisch_992.jpg
    id             : 690
    resource_uri   : /v1/show/690/
    episodes_Count : 555
    category_text  : Nyheter

    category       : /v1/category/5/
    title          : Aktuellt
    url            : http://www.svtplay.se/aktuellt
    thumbnail      : 
    episodes       : {/v1/episode/56968/, /v1/episode/56252/, /v1/episode/55653/, /v1/episode/56259/...}
    thumbnail_url  : http://www.svt.se/cachable_image/1354719575000/svts/article893234.svt/ALTERNATES/large/aktuellt_affisch_992.jpg
    id             : 685
    resource_uri   : /v1/show/685/
    episodes_Count : 15
    category_text  : Nyheter

    ...
.NOTES
    Uses the api from http://api.welovepublicservice.se/v1

.LINK
    http://dev.bergqvi.st/we-love-public-service

#>

    $category = Invoke-RestMethod "http://api.welovepublicservice.se/v1/category/?format=json"
    $result = $category.objects| Select-Object *, `                        @{Name="shows_Count"; Expression = {$_.shows.count}}
    $result += while($category.meta.next -ne $null){
        $category = Invoke-RestMethod "http://api.welovepublicservice.se$($category.meta.next)"
        $category.objects | Select-Object *, `                        @{Name="shows_Count"; Expression = {$_.shows.count}}
    }
    $result
}

Function Get-WlpsShow {

<#
.SYNOPSIS
    Return info about one or more shows from a SVTplay

.DESCRIPTION
    Return info about one or more shows from a SVTplay

.PARAMETER Name
    The exact name of the show

.PARAMETER Shows
    Mostly for internal use when passing the result from Get-WlpsCategory to Get-WlpsShow

.PARAMETER ShowIdNumber
    Id number/numbers fopr the shows you want info on

.EXAMPLE
    Get-WlpsCategory | where title -eq "nyheter" | Get-WlpsShow


    category       : /v1/category/5/
    title          : Oddasat
    url            : http://www.svtplay.se/oddasat
    thumbnail      : 
    episodes       : {/v1/episode/57089/, /v1/episode/57088/, /v1/episode/57091/, /v1/episode/57090/...}
    thumbnail_url  : http://www.svt.se/cachable_image/1360071664000/svts/article1007150.svt/ALTERNATES/large/oddasataffisch_992.jpg
    id             : 690
    resource_uri   : /v1/show/690/
    episodes_Count : 555
    category_text  : Nyheter

    category       : /v1/category/5/
    title          : Aktuellt
    url            : http://www.svtplay.se/aktuellt
    thumbnail      : 
    episodes       : {/v1/episode/56968/, /v1/episode/56252/, /v1/episode/55653/, /v1/episode/56259/...}
    thumbnail_url  : http://www.svt.se/cachable_image/1354719575000/svts/article893234.svt/ALTERNATES/large/aktuellt_affisch_992.jpg
    id             : 685
    resource_uri   : /v1/show/685/
    episodes_Count : 15
    category_text  : Nyheter

    ...
.EXAMPLE
    Get-WlpsShow -Name "Aktuellt"


    category       : /v1/category/5/
    title          : Aktuellt
    url            : http://www.svtplay.se/aktuellt
    thumbnail      : 
    episodes       : {/v1/episode/56968/, /v1/episode/56252/, /v1/episode/55653/, /v1/episode/56259/...}
    thumbnail_url  : http://www.svt.se/cachable_image/1354719575000/svts/article893234.svt/ALTERNATES/large/aktuellt_affisch_992.jpg
    id             : 685
    resource_uri   : /v1/show/685/
    episodes_Count : 15
    category_text  : Nyheter

.EXAMPLE
    Get-WlpsShow -ShowIdNumber "781" | Get-WlpsEpisodes 


    http_status_checked_date : 2013-08-21T21:09:27.220021+00:00
    description              : Playexklusiv direktsändning från säsongens femte deltävling, som avgörs i Östersund.
    title_slug               : Playexklusivt: STCC Östersund - 10-8 12.50
    show                     : /v1/show/781/
    url                      : http://www.svtplay.se/video/1380829
    title                    : Playexklusivt: STCC Östersund - 10/8 12.50 
    date_broadcasted         : 2013-08-10T10:55:00+00:00
    recommended              : False
    full_url                 : 
    length                   : 3 h 8 min
    thumbnail_url            : http://www.svt.se/cachable_image/1376155800000/svts/article1389050.svt/ALTERNATES/extralarge/default_title
    http_status              : 200
    kind_of                  : 1
    viewable_on_device       : 2
    date_created             : 2013-08-10T18:45:54.041264+00:00
    resource_uri             : /v1/episode/54006/
    viewable_in              : 1
    id                       : 54006
    date_available_until     : 2013-09-10T17:45:53.867286+00:00
    date__broadcasted        : 2013-08-10 12:55:00
    date__created            : 2013-08-10 20:45:54
    date__available_until    : 2013-09-10 19:45:53

    http_status_checked_date : 2013-08-21T21:19:33.680017+00:00
    description              :   23 min
    title_slug               : V8 heat 2
    show                     : /v1/show/781/
    url                      : http://www.svtplay.se/klipp/1200033/v8-heat-2
    title                    : V8 heat 2 
    date_broadcasted         : 2013-05-04T20:28:00+00:00
    recommended              : False
    full_url                 : 
    length                   : 23 min
    thumbnail_url            : http://www.svt.se/cachable_image/1367699340000/svts/article1200032.svt/ALTERNATES/extralarge/default_title
    http_status              : 200
    kind_of                  : 2
    viewable_on_device       : 1
    date_created             : 2013-05-06T08:08:06.845382+00:00
    ...
.NOTES
    Uses the api from http://api.welovepublicservice.se/v1

    The object returned have some properties that begins with date__ (double underscore)
    Those are System.DateTime Types

.LINK
    http://dev.bergqvi.st/we-love-public-service

#>

    Param
    (
        [parameter(Mandatory=$True,ParameterSetName="Name")]
        [ValidateNotNull()]
        [String]
        $Name,
        [parameter(Mandatory=$True,
            ParameterSetName="Shows",
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [String[]]
        $Shows,
        [parameter(Mandatory=$True,
            ParameterSetName="id",
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [String[]]
        $ShowIdNumber
    ) 
    process {
        $CategoryList = Get-WlpsCategory
        $CategoryHash = @{}
        foreach($Category in $CategoryList){
            $CategoryHash.Add($Category.resource_uri, $Category.title)
        }

        $BaseUrl= "http://api.welovepublicservice.se"
        switch ($PsCmdlet.ParameterSetName) 
        {
            "Name"  {
                $Name = ConvertTo-WlpsUrlEncode $Name
                $Show = Invoke-RestMethod "$BaseUrl/v1/show/?format=json&title=$Name"
                $Show.objects | Select-Object *, `                        @{Name="episodes_Count"; Expression = {$_.episodes.count}},
                        @{Name="category_text"; Expression = {$CategoryHash."$($_.category)"}}
                break
            }

            "Shows"  {
                    Foreach ($ShowEntry in $Shows){
                        $Show = Invoke-RestMethod $BaseUrl$ShowEntry"?format=json"
                        $Show | Select-Object *, `                                @{Name="episodes_Count"; Expression = {$_.episodes.count}},
                                @{Name="category_text"; Expression = {$CategoryHash."$($_.category)"}}
                    }
                break
            } 

            "id"  {
                    Foreach ($idEntry in $ShowIdNumber){
                        $Show = Invoke-RestMethod "$BaseUrl/v1/show/$idEntry/?format=json"
                        $Show | Select-Object *, `                                @{Name="episodes_Count"; Expression = {$_.episodes.count}},
                                @{Name="category_text"; Expression = {$CategoryHash."$($_.category)"}}
                    }
                break
            } 
        } 
    }
}

Function Get-WlpsEpisodes {

<#
.SYNOPSIS
    Return info Episodes of one or more shows from a SVTplay

.DESCRIPTION
    Return info about Episodes of one or more shows from a SVTplay

.PARAMETER Name
    The exact name of the show

.PARAMETER Shows
    Mostly for internal use when passing the result from Get-WlpsShow to Get-WlpsEpisodes

.PARAMETER ShowIdNumber
    Id number/numbers fopr the shows you want the list of episodes from

.EXAMPLE
    Get-WlpsEpisodes -ShowIdNumber 412,401

.EXAMPLE
    Get-WlpsEpisodes -Name "Aktuellt"


.NOTES
    Uses the api from http://api.welovepublicservice.se/v1

    The object returned have some properties that begins with date__ (double underscore)
    Those are System.DateTime Types

.LINK
    http://dev.bergqvi.st/we-love-public-service

#>

    Param
    (
        [parameter(Mandatory=$True,ParameterSetName="Name")]
        [ValidateNotNull()]
        [alias("title")]
        [String]
        $Name,
        [parameter(Mandatory=$True,
            ParameterSetName="Shows",
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [alias("resource_uri")]
        [String[]]
        $Shows,
        [parameter(Mandatory=$True,
            ParameterSetName="id",
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [String[]]
        $ShowIdNumber
    ) 
    process {

        $BaseUrl= "http://api.welovepublicservice.se"
        switch ($PsCmdlet.ParameterSetName) 
        {
            "Name"  {
                $Name = ConvertTo-WlpsUrlEncode $Name
                $Show = Invoke-RestMethod "$BaseUrl/v1/show/?format=json&title=$Name" | Select-Object -ExpandProperty objects
                break
            }

            "Shows"  {
                    $Show = Foreach ($ShowEntry in $Shows){
                        Invoke-RestMethod $BaseUrl$ShowEntry"?format=json"
                    }
                break
            } 

            "id"  {
                    $Show = Foreach ($idEntry in $ShowIdNumber){
                        Invoke-RestMethod "$BaseUrl/v1/show/$idEntry/?format=json"
                    }
                break
            } 

        } 
        $episodes = $Show | Select-Object -ExpandProperty episodes
        foreach($episode in $episodes) {
            Invoke-RestMethod $BaseUrl$episode"?format=json" | Select-Object  * ,  `                                @{Name="date__broadcasted"; Expression = {get-date $_.date_broadcasted}}, `
                                @{Name="date__created"; Expression = {get-date $_.date_created}}, `
                                @{Name="date__available_until"; Expression = {get-date $_.date_available_until}}

        }
    }
}

Function Get-WlpsStreams {

<#
.SYNOPSIS
    Return Streams from a SVTplay page

.DESCRIPTION
    This function will return all the streams and if possible also urls for subtitles
    for a SVTplay page

.PARAMETER url
    url of the page you want to get streams for

.EXAMPLE
    To get all streams for a given URL 
    Get-WlpsStreams -url http://www.svtplay.se/video/1276498/del-10-av-10
.EXAMPLE
    To play the stream with the higest bitrate in vlc

    $stream = Get-WlpsStreams -url http://www.svtplay.se/video/1276498/del-10-av-10 | Sort-Object quality_kbps | Select-Object -last 1 -ExpandProperty url
    Start-Process -FilePath  "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe" -ArgumentList $stream

.NOTES
    Uses the api from http://pirateplay.se/

.LINK
    http://pirateplay.se/

#>

    Param
    ([parameter(Mandatory=$True,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [String]
        $url
    ) 
        $BaseUrl= "http://pirateplay.se/api/get_streams.js?url="
        $Name = ConvertTo-WlpsUrlEncode $url
        $streams = Invoke-RestMethod "$BaseUrl$Name"
        foreach($stream in $streams){
            $stream.meta | Select-Object  @{Name="url"; Expression = {$stream.url}}, *,  @{Name="quality_kbps"; Expression = {[Int32]$_.quality.Replace(" kbps","")}}
        }
}


#$CategoryList = Get-WlpsCategory
#Get-WlpsCategory | where title -eq "nyheter" | Get-WlpsShow
#$CategoryList | where title -eq "nyheter" | Get-WlpsShow
#$Showlist = Get-WlpsAllShows
#$Showlist | Where-Object category_text -eq "Barn" | select title, id
#Get-WlpsEpisodes -Name "Jakten på det perfekta livet" 
#Get-WlpsShow -Name "Jakten på det perfekta livet"
#Get-WlpsShow -Name "Jakten på det perfekta livet" | Get-WlpsEpisodes
#Get-WlpsShow -ShowIdNumber "781"
#Get-WlpsShow -Shows "/v1/show/781/", "/v1/show/782/" 
#Get-WlpsStreams -url http://www.svtplay.se/video/1276498/del-10-av-10 | Sort-Object quality_kbps | Select-Object -last 1 -ExpandProperty url

#$stream = Get-WlpsStreams -url http://www.svtplay.se/video/1276498/del-10-av-10 | Sort-Object quality_kbps | Select-Object -last 1 -ExpandProperty url
#Start-Process -FilePath  "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe" -ArgumentList $stream

