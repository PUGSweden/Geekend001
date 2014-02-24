#Startar en process för vidare demo
. calc

$processes = Get-Process
#Skapar en hashtable mha Group-Object
$tmp1 = $processes  | Group-Object -AsHashTable -Property "Id"







#Låt oss se hur lång tid detta tar
Measure-Command {
    $tmp1 = $processes  | Group-Object -AsHashTable -Property "Id"
}



#en enkel funktion för att skapa en hashtable med unika nycklar
function New-HashTable ($Object, $Key)
{
    $HashTable = @{}
    foreach($instance in $Object){
        if($HashTable.ContainsKey($instance.$Key)){
            Write-Host "KEY ERROR" -ForegroundColor Red
        } else {
            $HashTable.Add($instance.$Key , $instance)
        }
    }
    $HashTable   
}




#Låt oss se hur lång tid detta tar
Measure-Command {
    $tmp2 = New-HashTable $processes "Id"
}

$processid = $tmp2.GetEnumerator() |
    Where-Object { $_.value.ProcessName -eq "calc"} | 
    Select-Object -First 1 -ExpandProperty Key

$tmp2.$processid | gm
$tmp2.$processid.Kill()


# =========================================================================
#Datafiler med personer hämtade från http://www.briandunning.com/sample-data/
$Users500[0]
$Users500| select -First 1

$Key = "Email"


Measure-Command {
    $HashTable1 = $Users500  | Group-Object -AsHashTable -Property $Key
}

Measure-Command {
    $HashTable2 = New-HashTable -Object $Users500 -Key $Key 
}

