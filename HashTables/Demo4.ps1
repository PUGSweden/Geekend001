function New-HashTable ($Object, $Key)
{
    $HashTable = @{}
    foreach($item in $Object){
        if(-not $HashTable.ContainsKey($item.$Key)){
            $HashTable.Add($item.$Key.tostring(),$item)
        }
    }
    $HashTable   
}


$Key = "Email"

# =========================================================================

$HashTable1 = New-HashTable -Object $Users500 -Key $Key 

$TestMail = $Users500.GetEnumerator() | Get-Random -Count 3 | Select-Object -ExpandProperty Email
$TestMail

$TimeUsingKey = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $HashTable1[$Mail] | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}


$TimeUsingWhere = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $Users500 | Where-Object Email -EQ $Mail | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}

$TimeUsingKey| Select-Object TotalSeconds,@{Name = "Using";Expression={"Key"}}
$TimeUsingWhere| Select-Object TotalSeconds,@{Name = "Using";Expression={"Where"}}


#=====================================================================================

$HashTable1 = New-HashTable -Object $Users5000 -Key $Key 

$TestMail = $Users5000 | Get-Random -Count 3 | Select-Object -ExpandProperty Email
$TestMail

$TimeUsingKey = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $HashTable1[$Mail] | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}


$TimeUsingWhere = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $Users5000 | Where-Object Email -EQ $Mail | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}

$TimeUsingNewWhere = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $Users5000.Where({$_.Email –eq $Mail}) | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}


$TimeUsingKey| Select-Object TotalSeconds,@{Name = "Using";Expression={"Key"}}
$TimeUsingWhere| Select-Object TotalSeconds,@{Name = "Using";Expression={"Where"}}
$TimeUsingNewWhere| Select-Object TotalSeconds,@{Name = "Using";Expression={"New Where"}}

#=====================================================================================

$HashTable1 = New-HashTable -Object $Users50000 -Key $Key 

$TestMail = $Users50000.GetEnumerator() | Get-Random -Count 3 | Select-Object -ExpandProperty Email
$TestMail

$TimeUsingKey = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $HashTable1[$Mail] | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}


$TimeUsingWhere = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $Users50000 | Where-Object Email -EQ $Mail | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}


$TimeUsingNewWhere = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $Users50000.Where({$_.Email –eq $Mail}) | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}



$TimeUsingKey| Select-Object TotalSeconds,@{Name = "Using";Expression={"Key"}}
$TimeUsingWhere| Select-Object TotalSeconds,@{Name = "Using";Expression={"Where"}}
$TimeUsingNewWhere| Select-Object TotalSeconds,@{Name = "Using";Expression={"New Where"}}


#=====================================================================================

$HashTable3 = New-HashTable -Object $Users350000 -Key $Key 

$TestMail = $Users350000[100001] | Select-Object -ExpandProperty email
$TestMail

$TimeUsingKey = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $HashTable3[$Mail] | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}

#

$TimeUsingWhere = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $Users350000 | Where-Object Email -EQ $Mail | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}

$TimeUsingNewWhere = Measure-Command {
        $result = ForEach($Mail in $TestMail) {
        $Users350000.Where({$_.Email –eq $Mail}) | Select-Object FirstName,lastname,City, State
    }
    $result | Out-Host
}


$TimeUsingKey| Select-Object TotalSeconds,@{Name = "Using";Expression={"Key"}}
$TimeUsingWhere| Select-Object TotalSeconds,@{Name = "Using";Expression={"Where"}}
$TimeUsingNewWhere| Select-Object TotalSeconds,@{Name = "Using";Expression={"New Where"}}



