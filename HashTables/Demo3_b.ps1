function ConvertTo-HashTable {
  param(
    [parameter(Mandatory=$true, 
        ValueFromPipeline=$true, 
        HelpMessage="Object to convert to hashtable")]
    [ValidateNotNullOrEmpty()]
    [PSObject]$InputObject ,

    [parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$false,
        HelpMessage="Property to use as key for your hashtable")]
    [ValidateNotNullOrEmpty()]
    [string]$Property,

    [parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$false,
        HelpMessage="Allow multiple instances beneath a key")]
    [Switch]$NonUnique=$false
    )
    Begin{
        $HashTable = @{}
    }

    Process{
        If($NonUnique){
            foreach($item in $InputObject){
                $guid = [guid]::NewGuid()
                if($HashTable.ContainsKey($item.$Property)){
                    $HashTable[$item.$Property].add($guid,$item)
                } else {
                    $x = @{}
                    $HashTable.Add($item.$Property,$x)
                    $HashTable[$item.$Property].add($guid,$item)
                }
            }
        }else{
            foreach($item in $InputObject){
                if($HashTable.ContainsKey($item.$Property)){
                    $message = "Key '$($item.$Property.tostring())' allready exist."
                    $exception = New-Object InvalidOperationException $message
                    $errorID = 'KeyExist'
                    $errorCategory = [Management.Automation.ErrorCategory]::ResourceExists
                    $target = $item
                    $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID, $errorCategory, $target
                    $psCmdLet.WriteError($errorRecord)
                } else {
                    $HashTable.Add($item.$Property,$item)
                }
            }
        }
    }
    End{
        If($NonUnique){
            Foreach ($tmpkey in ($HashTable | select -ExpandProperty keys)) {
                $HashTable["$tmpkey"]=($HashTable["$tmpkey"].GetEnumerator() | Select-Object -ExpandProperty value)
            }
        }
        $HashTable
    }
}


$Users5000 | select -First 1
$Key = "Email"
Measure-Command {
    $HashTable1 = $Users5000  | Group-Object -AsHashTable -Property $Key
}

Measure-Command {
    $HashTable2 = ConvertTo-HashTable -InputObject $Users5000 -Property $Key # -NonUnique
}


$Key = "State"

Measure-Command {
    $HashTable1 = $Users50000 | Group-Object -AsHashTable -Property $Key
} 

Measure-Command {
    $HashTable2 = ConvertTo-HashTable -InputObject $Users50000 -Property $Key -NonUnique
}

#Vill man kan man få samma out-put som group-object
$HashTable3 = ConvertTo-HashTable -InputObject (Get-Process) -Property name -NonUnique
$HashTable3.GetEnumerator() | Select-Object @{Name="Count";Expression={$_.value.count}},Name,@{Name="Group";Expression={$_.value}} | Format-Table -AutoSize



<#
#Tar ca 15-18 minuter
Measure-Command {
    $HashTable3 = ConvertTo-HashTable -InputObject $users350000 -Property Email -ErrorAction SilentlyContinue
}
#>

Measure-Command {
    $HashTable3 = ConvertTo-HashTable -InputObject $users350000 -Property Email -ErrorAction SilentlyContinue
}
