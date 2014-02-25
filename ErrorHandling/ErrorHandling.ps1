[PSCustomObject]@{
    Session = "Basics of error handling"
    Occation = "G(eekW)eekend by Sweden Powershell UserGroup"
    Presenter = [PSCustomObject]@{
        Name = "Simon Wåhlin"
        Twitter = "@SimonW"
        Blog = "http://blog.simonw.se"
    }
}




# There are two types of errors, Terminating and Non-Terminating.

# Terminating will break the pipeline

# Non-Terminating will tell us that something went wrong but
# the pipeline will continue.




# There are two main methods to control how much errors are
# affecting our scripts:

# The global variable ErrorActionPreference that affects
# both cmdlets and .net methods.

    $ErrorActionPreference = "SilentlyContinue"
    # Errors are only written to $Error

    $ErrorActionPreference = "Continue"
    # Errors are written to $Error and to the screen

    $ErrorActionPreference = "Inquire"
    # Errors are written to $Error and to the screen
    # The user will get prompted if the script should continue.

    $ErrorActionPreference = "Stop"
    # Errors are written to $Error, to the screen and the
    # error will be terminating, meaning the pipeline will break.




# The same settings can be set for a single command by using the
# parameter -ErrorAction.

# If changing the global variable $ErrorActionPreference, it is good
# practice to restore it to its original setting. This can be done
# by fist storing the setting:
   
    $OriginalErrorActionPreference = $ErrorActionPreference
    # Set it to desired value:
    $ErrorActionPreference = "Stop"
    # Run a command:
    Get-Content -Path C:\NoFile
    # And then reset it to the original value:
    $ErrorActionPreference = $OriginalErrorActionPreference




# Another parameter that can be used is -ErrorVariable, this will store
# the error in a custom named variable.

Get-Content -Path C:\nonexistantfile -ErrorVariable MyError

# Note the lack of $ before the variable name.
# To append errors to a custom variable, use a + sign before the name:

Get-Content -Path C:\nonexistingfile -ErrorVariable +MyError

# Worth noting is that the default $Error will always have the most recent
# error in index 0:

$Error[0]

# While the custom $MyError will have the most recent error in the
# highest index. And since powershell is all forgiving we can index
# that with -1 like this:

$MyError[-1]




# A third automatic variable is $? which is a boolean variable that will
# return $true if and only if the last executed command returned
# a returncode of 0
# This is a bit of a trick command which I do not recommend using.
# Let me demonstrate:

Get-Item -Path C:\nofile
$? 
# This will return False as expected since nofile didnt exist.

# But let us try again:
(Get-Item -Path C:\nofile)
$?
# This will actually return True since the last executed command
# is the parantheses which were successful.




# In powershell version 1, the only way to handle a terminating error
# was by using the Trap keyword. For example:

Trap {
    Write-Host -ForegroundColor Green "We got a terminating error!"
}
Get-Content C:\nofile -ErrorAction Stop

# Trap will catch any unhandled terminating error in current scope
# or any child scope meaning that an error can be handled quite
# far away from where it occurred in the code.

# In Powershell Version 2 we got Try/Catch/Finally.
Get-Help about_Try_Catch_Finally

# Works by defining a Try{}-block followed by
# at least one Catch{} or Finally{}

# Any terminating error caused within the Try{}-block
# will be sent to the first matching Catch{}-block
# (if any is found). Then the Finally{}-block will get
# executed. If no erroras are caused, the Finally{}
# block will still get executed.

# A Catch{} block can be limited to only catch certain
# error by defining an error type or (by default)
# catch all terminating errors.

# Example:
Try{
    # A Try-block requires atleast one following 
    # Catch or Finally block.

    # This row will execute:
    Write-Host -ForegroundColor Cyan "Before Error"
    
    # This will generate a terminating error and
    # send us to the default catch:
    Get-Content C:\Filenfinnsinte -ErrorAction Stop

    # This row will never execute:
    Write-Host -ForegroundColor Cyan "After Error"
}
Catch [System.UnauthorizedAccessException] {
    # This block will only execute if the error is of type:
    # [System.UnauthorizedAccessException]
    Write-Host -ForegroundColor Green "Access denied"
}
Catch{
    # This block will catch any error that hasn't allready 
    # got caught by any of the previous blocks.
    Write-Host -ForegroundColor Green "Not access denied error"
    # The error can be accessed with the default variable: $_
    # This will return the error message:
    $_.Exception.Message

    # By calling GetType() on the exception we get the
    # exeption full name that can be used to specify
    # a narrower catch-block:
    $_.Exception.GetType().FullName

}
Finally{
    # Everything in this block will execute:
    Write-Host -ForegroundColor Yellow "Finally"
}

# A nestled Try/Catch can also be used to try opening a CIM-Session
# using WSMAN but failover to DCOM if WSMAN doesn't work.
# This method is a bit timeconsuming since it will try to
# connect to an offline computer twice but it is a good
# way to maximize the chance of success.
Try{
    New-CimSession -ComputerName $Computer -ErrorAction Stop
}
Catch {
    Try{
        $DCOMSession = New-CimSessionOption -Protocol Dcom -ErrorAction Stop
        New-CimSession -ComputerName $Computer -SessionOption $DCOMSession -ErrorAction Stop
    }
    Catch {
        Write-Warning -Message "Failed to initiate session on $Computer"
        Write-Warning -Message $_.exception.message
    }
}


# A good way to iterate through all errors in $error
# caused by your script is storing the last error
# in $Error before starting and then doing a foreach
# on $Error until that last error is found.

$LastError = $Error[0]

1..10 | Foreach{ Get-Content C:\NoFile } # Will cause 10 errors

$Error | Foreach {
    If($_ -eq $LastError){
        Break
    }
    $_.Exception.Message
}


