# Grundläggande om HashTables

$TimeSharing  = @{
    Introduktion = "Kort"
    Bakgrund = "Lite längre"
    Exempel = "lite mera"
    WebServices = "Tiden som är kvar"
}


$hash = @{Sune=1;Nisse=2}



#Sorterad hashtable
$TimeSharing  = [ordered]@{
    Introduktion = "Kort"
    Bakgrund = "Lite längre"
    Exempel = "lite mera"
    WebServices = "Tiden som är kvar"
}








<#
.Keys ger dig alla keys
.GetEnumerator() ger dig alla objekt
#>
$TimeSharing.Keys
$TimeSharing.Values
$TimeSharing.GetEnumerator()
$TimeSharing.Count





#Lite olika sätt att ropa på din hashtable
$TimeSharing.Bakgrund # Funkar bara så länge du inte har mellanslag
$TimeSharing["Bakgrund"] #Funkar bäst enligt minna erfarenheter
$TimeSharing."Bakgrund"
$TimeSharing.("Bakgrund")

# Det är inga problem att nyttja en enkel variabel heller
$Myvar = "Bakgrund"
$TimeSharing.$Myvar
$TimeSharing[$Myvar]

# Skall du roa dig med att nyttja objekt så gäller det att
# fundera lite, men det funkar kanon
$MyObject = New-Object -TypeName PsObject
Add-Member -InputObject $MyObject -MemberType NoteProperty -Name MyProp -Value $Myvar
$TimeSharing.$MyObject.MyProp #Funkar Inte
$TimeSharing[$MyObject.MyProp]#Funkar
$TimeSharing.($MyObject.MyProp)#Funkar


#Nu kommer vi till nackdelarna med Hashtables
#En del bra Cmdlets ger upp, eller funkar inte som vi vill längre
$TimeSharing | Get-Random -Count 1
$TimeSharing | Where-Object { $_.value -eq "Kort"}
$TimeSharing | Sort-Object -Property name


$TimeSharing | Get-Member 
$TimeSharing.GetEnumerator()| Get-Member 




#GetEnumerator() är lösning på många av dessa problem
$TimeSharing.GetEnumerator() | Get-Random -Count 1
$TimeSharing.GetEnumerator() | Where-Object { $_.value -eq "Kort"}
$TimeSharing.GetEnumerator() | Sort-Object -Property name


<#
Hashtables är även bra för att skapa mer lättlästa
rader (jo jag vet att man kan radbryta, men för att vara tydlig ;) )
Titta på Get-help about_Splatting för mer info
Så jämmför denna rad
#>
New-aduser -AccountExpirationDate $((Get-Date).AddDays(30)) -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd" -Force) -City "Långtbortistan" -Company "Willy Wonka's Chokladfabrik" -Department "Forskning och utveckling" -Description "Dummy Konto" -DisplayName "Karl Bertil" -Division "Kakao" -EmailAddress "nobody@Willy.Wonkas.nu" -GivenName "Ingen" -HomePage "http://www.vecka.nu" -Initials "IA" -Name "Ingen Aning" -Office "Höga Berget" -OfficePhone "123" -SamAccountname "test_user_1"

#Med dessa rader:

$NewUser = @{
    AccountExpirationDate = (Get-Date).AddDays(30)
    AccountPassword = ConvertTo-SecureString -AsPlainText "P@ssw0rd" -Force
    City = "Långtbortistan"
    Company = "Willy Wonka's Chokladfabrik"
    Department = "Forskning och utveckling"
    Description = "Dummy Konto"
    DisplayName = "Karl Bertil"
    Division = "Kakao"
    EmailAddress = "nobody@Willy.Wonkas.nu"
    GivenName = "Ingen"
    HomePage = "http://www.vecka.nu"
    Initials = "IA"
    Name = "Ingen Aning"
    Office = "Höga Berget"
    OfficePhone = "123"
    SamAccountname = "test_user_1"
}

New-ADUser @NewUser #Notera "@" istället för "$"





# Det går även att mixa Hashtables med vanliga input-parametrar
# Notera att om man skriver det som en rad måste man ha ett semi-kolon
# mellan varje par, skriver man ett par per rad kan man strunta i det
$Dark = @{ForegroundColor="White";BackgroundColor="Black"}
$Light = @{
    ForegroundColor="Black"
    BackgroundColor="White"
}

write-host "Jag kan skåda ljuset nu..." @Light
write-host "Säker på det?" @Dark