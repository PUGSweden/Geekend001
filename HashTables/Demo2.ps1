$Person1  = [ordered]@{
    Namn = "Pär"
    Efternamn = "Hultman"
    Mail = "par@någonting.com"
    Kontor = "Plan 3"
    Nummer = 11
}
$Person2  = [ordered]@{
    Namn = "Karl-Bertil"
    Efternamn = "Jonsson"
    Mail = "kb@Jonsson.nu"
    Kontor = "Plan 3"
    Nummer = 12
}

$Anstallda = @{11=$Person1;12=$Person2}
$Anstallda[12].Namn

$Anstallda["12"].Namn # funkar ej




$Person3  = [ordered]@{
    Namn = "Kit"
    Efternamn = "Walker"
    Mail = "kit@walker.com"
    Kontor = "Plan 1"
    Nummer = 13
}

$Anstallda.Add(13,$Person3)
$Anstallda





$hash = [ordered]@{            
    Date             = Get-Date              
    ServerName       = $env:COMPUTERNAME            
}                           

$YeterDay = (Get-Date).AddDays(-1)
$hash.Add("YeterDay",$YeterDay)

                                    
$Object = New-Object PSObject -Property $hash 
$Object
$Object | gm






#Nu kommer vi till nackdelarna med Hashtables, och de minskar inte
#bara för att man populerar en hashtable med en annan
#Återigen så kommer GetEnumerator() till hjälp

$Anstallda.GetEnumerator() | Foreach {$_.Value.Efternamn}

# eller

foreach ($Nummer in $Anstallda.Keys)
{
    $Anstallda.$Nummer.Efternamn
}

$Anstallda.GetEnumerator() | Where-Object { $_.value.Nummer -eq 13}



$Anstallda.GetEnumerator() | 
    Sort-Object -property @{Expression={$_.Value.Nummer}; Ascending=$true}

$Anstallda.Remove(13)