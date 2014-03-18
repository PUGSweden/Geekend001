[void][Reflection.Assembly]::LoadWithPartialName(“System.Web”)
import-module activedirectory

Function Get-Settings {
    [pscustomobject]@{
        UserOU = "OU=User Accounts,OU=User Environment,DC=lab6,DC=cosmoskey,DC=net"
        UpnSuffix = "lab6.cosmoskey.net"
        FirstNameCharCount = 3
        LastNameCharCount = 3
        NumericSuffixLength = 2
        HelpDeskUserScopeOU = "OU=User Accounts,OU=User Environment,DC=lab6,DC=cosmoskey,DC=net"
        HelpDeskGroupScopeOU = "OU=Groups,OU=User Environment,DC=lab6,DC=cosmoskey,DC=net"
    }
}
$Settings = Get-Settings

Function Convert-ToLatinCharacters {
    param(
        [string]$inputString
    )
    [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($inputString))
}

Function Get-RandomPassword {
    [System.Web.Security.Membership]::GeneratePassword(8,2)    
}

Function New-PUGSUserOld {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^[\w'-]+$")]
        [string]$FirstName,
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^[\w'-]+$")]
        [string]$LastName,
        [ValidateScript({$_.length -le 100KB})]
        [byte[]]$Picture,
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^[\w ]+$")]
        [string]$Location
    )
    # unik upn
    # unik samAccountName
    # unik CN i context
    $index = 1
    $indexString = ""

    do {
        $formatparams = @(
            (Convert-ToLatinCharacters $FirstName).Substring(0,$settings.FirstNameCharCount),
            (Convert-ToLatinCharacters $LastName).Substring(0,$settings.LastNameCharCount),
            $indexString
        )
        $samAccountName = "{0}{1}{2}" -f $formatparams 
        $samAccountName = $samAccountName.Substring(0,([Math]::Min($samAccountName.length,20))).ToLower() -replace "[&'`"\[\]:;\|=+*?<>\/\\,]",''

        $upn = "{0}@{1}" -f $samAccountName,$Settings.UpnSuffix.ToLower()
        $index++
        $indexString = "{0:D2}" -f $index
        $displayName = "{0} {1}" -f $FirstName,$LastName

        $password = Get-RandomPassword
        $newUser = @{
            Name = $samAccountName
            SamAccountName = $samAccountName
            UserPrincipalName = $upn
            Surname = $LastName
            GivenName = $FirstName
            Enabled = $true
            AccountPassword = (ConvertTo-SecureString -AsPlainText -Force -String $password)
            ChangePasswordAtLogon = $true
            Path = $settings.UserOU
        }
        if($Picture) {
            $newUser["OtherAttributes"] = @{thumbnailphoto = $Picture}
        }
        $newUser
        try {
            New-ADUser @newUser 
            $found = $true
        } catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
            $found = $false
        }
    } while (-not $found -and $index -lt 100)
    [pscustomobject]@{
        sAMAccountName = $samAccountName
        Password = $password
    }
}

Function New-PUGSUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^[\w'-]+$")]
        [string]$FirstName,
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^[\w'-]+$")]
        [string]$LastName,
        [ValidateScript({$_.length -le 100KB})]
        [byte[]]$Picture,
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^[\w ]+$")]
        [string]$Location
    )
    
    $BaseAccountName = @(
        (Convert-ToLatinCharacters $FirstName).Substring(0,$settings.FirstNameCharCount),
        (Convert-ToLatinCharacters $LastName).Substring(0,$settings.LastNameCharCount)
    )
    
    $PossibleIndex = (Get-ADUser -LDAPFilter "(sAMAccountName='$($BaseAccountName -join '')*')" | 
        Sort-Object -Property sAMAccountName | 
        Select-Object -ExpandProperty sAMAccountName -Last 1) -replace $($BaseAccountName -join ''), ''

    Try{
        $index = [Int32]::TryParse($PossibleIndex)
    }
    Catch{
        $index = 1
    }
    
    $indexString = ""

    do {
        $formatparams = @(
            
            $indexString
        )
        $samAccountName = "{0}{1}{2}" -f $formatparams 
        $samAccountName = $samAccountName.Substring(0,([Math]::Min($samAccountName.length,20))).ToLower() -replace "[&'`"\[\]:;\|=+*?<>\/\\,]",''

        $upn = "{0}@{1}" -f $samAccountName,$Settings.UpnSuffix.ToLower()
        $index++
        $indexString = "{0:D2}" -f $index
        $displayName = "{0} {1}" -f $FirstName,$LastName

        $password = Get-RandomPassword
        $newUser = @{
            Name = $samAccountName
            SamAccountName = $samAccountName
            UserPrincipalName = $upn
            Surname = $LastName
            GivenName = $FirstName
            Enabled = $true
            AccountPassword = (ConvertTo-SecureString -AsPlainText -Force -String $password)
            ChangePasswordAtLogon = $true
            Path = $settings.UserOU
        }
        if($Picture) {
            $newUser["OtherAttributes"] = @{thumbnailphoto = $Picture}
        }
        $newUser
        try {
            New-ADUser @newUser 
            $found = $true
        } catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
            $found = $false
        }
    } while (-not $found -and $index -lt 100)
    [pscustomobject]@{
        sAMAccountName = $samAccountName
        Password = $password
    }
}

Function Add-PUGSGroupmember {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='http://go.microsoft.com/fwlink/?LinkId=219287')]
    param(
        ${Members},
        ${Identity}
    )

    begin
    {
        if( -not (Test-ManagementScope -Identity $Identity -Type Group)){
            throw "Out of management scope"
        }
        $PSBoundParameters['Members'] = $PSBoundParameters['Members'] | Where-Object {Test-ManagementScope -Identity $_ -Type User}
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Add-ADGroupMember', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Add-ADGroupMember
    .ForwardHelpCategory Cmdlet

    #>
}

function Remove-PUGSGroupMember {
    [cmdletbinding()]
    param(
        [System.Object]
        $Members,
        [System.Object]
        $Identity,
        [switch]${Confirm}
    )

    begin
    {
        if( -not (Test-ManagementScope -Identity $Identity -Type Group)){
            throw "Out of management scope"
        }
        $PSBoundParameters['Members'] = $PSBoundParameters['Members'] | Where-Object {Test-ManagementScope -Identity $_ -Type User}
        $PSBoundParameters | out-host
        $PSBoundParameters | gm | out-host
        try {
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Remove-ADGroupMember', [System.Management.Automation.CommandTypes]::Function)
            $PSBoundParameters.Add('$args', $args)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($myInvocation.ExpectingInput, $ExecutionContext)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Remove-ADGroupMember
    .ForwardHelpCategory Function

    #>

}

Function Test-ManagementScope {
    param(
        [string]$Identity,
        [validateSet("Group","User")]
        [string]$Type
    )
    if($Type -eq "Group"){
        $object = Get-ADGroup -Identity $Identity
        $object.DistinguishedName.contains($Settings.HelpDeskGroupScopeOU)
    } else {
    $object = Get-ADUser -Identity $Identity
        $object.DistinguishedName.contains($Settings.HelpDeskUserScopeOU)
    }
}


# New-PUGSUser -FirstName "olle" -lastname "johansson" -location "Kungsbacka"
Export-ModuleMember -Function "New-PUGSUser","Add-PUGSGroupMember","Remove-PUGSGroupMember"

