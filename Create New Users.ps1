<#
    EdUsers

    Version: 1.2.5
    Author: Justin Byrne
    URL: http://www.jnm-tech.co.uk
    Reqirements:
        * Remote Server Admin Tools - Windows 7, 8, 8.1
        * Active Directory Module for Windows PowerShell
		* Windows Managment Framework 4.0

#>

# import modules
Import-Module ActiveDirectory

# XML Setup
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
[xml]$ConfigFile = Get-Content "$($MyDir)\Settings.xml"

<#
    
    ALL FUNCTIONS

#>

function write2Log( $message, $type, $component ) {
    
    # creating log file variable
    $logFile = "$($MyDir)\userCreation.log"

    # getting date and time
    $TZbias = (Get-WmiObject -Query "Select Bias from Win32_TimeZone").bias
    $Time = Get-Date -Format "HH:mm:ss.fff"
    $Date = Get-Date -Format "MM-dd-yyyy"

    # creating log line
    $Output = "<![LOG[$($message)]LOG]!><time=`"$($Time)+$($TZBias)`" date=`"$($Date)`" "
    $Output += "component=`"$($component)`" context=`"$($component)`" type=`"$($type)`" "
    $Output += "thread=`"$($logFile)`" file=`"$($logFile)`">"

    # adding line to end of document
    Out-File -InputObject $Output -Append -NoClobber -Encoding UTF8 –FilePath "$($logFile)"

} # end of write2log function

function lvlMembership() {
    
    # do loop to create menu
    Do {
        
        cls

        # creating title
        Write-Host "------------ Membership Selection ------------"
        Write-Host " "
        
        # creating option array
        $array = @()
        
        # count number or items in menu
        $itemCount = 1
        
        # going through each available membership level and adding to the array
        foreach( $level in $ConfigFile.Settings.Membership.level ) {
            
            $array += $level.name

        }

        # going through the array to make the menu
        foreach( $item in $array ) {
            
            # adding menu item
            Write-Host "$($itemCount): $($item)"

            # adding one item to the menu count
            $itemCount++

        }

        Write-Host " " # blank line for looks

        # asking for selection
        $choice = Read-Host "Please select what membership the user has"

    } Until ( $choice -In 1..$itemCount )

    return $array[($choice - 1)]

} # end of lvlmembership function

function usrLayout() {
    
    # do loop until a choice has been selected that is in array
    Do {
        
        cls

        # creating title
        Write-Host "------------ Username Layout Selection ------------"
        Write-Host " "
        
        # creating option array
        $array = @()
        
        # count number or items in menu
        $itemCount = 1
        
        # going through each available username layout
        foreach( $layout in $ConfigFile.Settings.Layouts.layout ) {
            
            # adding entry value to array
            $array += $layout.name

        } # end of foreach loop

        # going through the array to make the menu
        foreach( $item in $array ) {
            
            # adding menu item
            Write-Host "$($itemCount): $($item)"

            # adding one item to the menu count
            $itemCount++

        }

        Write-Host " " # blank line for looks

        # menu entry
        $choice = Read-Host "Please select what username layout to use"

    } Until( $choice -In 1..$itemCount ) # end of do loop
        
    # going through each available username layout
    foreach( $layout in $ConfigFile.Settings.Layouts.layout ) {
        
        # getting layout value from selection
        if( $layout.name -eq $array[($choice - 1)] ) {
            
            return $layout.value

        } # end of if statement

    } # end of foreach loop

} # end of usrLayout function

function profilePath( $level ) {

    # do loop until a choice has been selected from array
    Do {
        
        cls

        # creating title
        Write-Host "------------ Profile Path Selection ------------"
        Write-Host " "
        
        # creating an array to hold the available selections
        $array = @()
        
        # count number or items in menu
        $itemCount = 1
        $totalItems = 0
        
        # going through each available profile path
        foreach( $profile in $ConfigFile.Settings.Profiles.profile ) {
            
            # checking if path level is compatiable
            if( $profile.level -eq $level ) {
                
                $totalItems++

                $array += $profile.path

            } # end of if statement

        } # end of foreach loop

        if( $totalItems -lt 2 ) {
            
            return $array[0]

        } else {
            
            # going through the array to make the menu
            foreach( $item in $array ) {
            
                # adding menu item
                Write-Host "$($itemCount): $($item)"

                # adding one item to the menu count
                $itemCount++

            }

        }

        Write-Host " " # blank line for looks

        # menu entry
        $choice = Read-Host -Prompt "Please select a profile path"

    } Until( $choice -In 1..$itemCount ) # end of do loop

    return $array[($choice - 1)]

} # end of profilepath function

function ouPath( $level ) {

    # do loop until a choice has been selected that is in array
    Do {
        
        cls

        # creating title
        Write-Host "------------ Ou Path Selection ------------"
        Write-Host " "
        
        # creating an array to hold the available selections
        $array = @()
        
        # count number or items in menu
        $itemCount = 1
        $totalItems = 0

        # going through each ou and checking membership to find total
        # number of ous available
        foreach( $ou in $ConfigFile.Settings.OUs.ou ) {

            if( $ou.level -eq $level ) {
                
                $totalItems++

                $array += $ou.path

            } # end of if statement

        } # end of foreach loop

        if( $totalItems -lt 2 ) {
            
            return $array[0]

        } else {
            
            # going through the array to make the menu
            foreach( $item in $array ) {
            
                # adding menu item
                Write-Host "$($itemCount): $($item)"

                # adding one item to the menu count
                $itemCount++

            }

        }
    
        Write-Host " " # blank line for looks

        # menu entry
        $choice = Read-Host -Prompt "Please Select an OU"

    } Until( $choice -In 1..$itemCount ) # end of do loop

    return $array[($choice - 1)]

} # end of ouPath function

function createUsername( $layout, $cohort, $forename, $surname ) {
    
    cls

    # going through each possible layout and replacing accordingly
    if( $layout -match "%cohort%" ) {
        $layout = $layout -replace "%cohort%", "$cohort"
    }

    if( $layout -match "%forename%" ) {
        $layout = $layout -replace "%forename%", $forename.toLower()
    }

    if( $layout -match "%surname%" ) {
        $layout = $layout -replace "%surname%", $surname.toLower()
    }

    if( $layout -match "%initial%" ) {
        $layout = $layout -replace "%initial%", $forename.toLower().Substring(0,1)
    }

    if( $layout -match "%twoinitial%" ) {
        $layout = $layout -replace "%twoinitial%", $forename.toLower().Substring(0,2)
    }

    return $layout

} # end of directory function

function createDirectory( $username, $dir, $drive ) {
    
    # getting folder full path
    if( $dir -match "%username%" ) {
        
        $folder = $dir -replace "%username%", $username

    }

    # getting domain name
    $ldap = $ConfigFile.Settings.Domains.ldap.value

    # clearing error status
    $error.Clear()

    # creating new folder
    Try { 
        
        New-Item "$($folder)" -ItemType directory

    }
    Catch {
        
        # writing error to log
        write2Log "Failed to create home directory - $($folder), because: $($_.Exception.Message)" "3" "Creating folder"

    }

    # checking if folder was created succefully
    if( !$error ) {
        
        write2Log "Succeeded in creating home directory - $($folder)" "1" "Creating folder"

    }

    # getting curent access control list
    $Acl = Get-Acl "$($folder)"

    # creating permissons
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$($ldap)\$($username)", "FullControl", "ContainerInherit,ObjectInherit”, "None", "Allow")
    $Acl.SetAccessRule($ar)

    # clearing error status
    $error.Clear()

    # setting permissions on the folder
    Try {
        
        Set-Acl "$($folder)" $Acl

    }
    Catch {
        
        # writing error to log file
        write2Log "Failed to add permissions to home directory - $($folder), because: $($_.Exception.Message)" "3" "Setting Permissions" 

    }

    # checking if folder permissions were set successfully
    if( !$error ) {
    
        write2Log "Suceeded in add permissions to home directory - $($folder)" "1" "Setting Permissions"

    }

    # clearing error status
    $error.Clear()

    # setting homefolder for the users
    Try {
        
        Set-ADUser $username -HomeDrive "$($drive)" -HomeDirectory "$($folder)"

    }
    Catch {
        
        # writing error to log file
        write2Log "Failed to set home directory - $($folder), because: $($_.Exception.Message)" "3" "Setting Home Directory"

    }


} # end of createDirectory function

function directoryLocation( $level ) {
    
    # do loop until a choice has been selected that is in array
    Do {
        
        cls

        # creating title
        Write-Host "------------ Directory Location Selection ------------"
        Write-Host " "

        # creating an array to hold the available selections
        $array = @()

        # count number or items in menu
        $itemCount = 1
        $totalItems = 0
    
        # going through each ou and checking membership to find total
        # number of ous available
        foreach( $dir in $ConfigFile.Settings.Directories.directory ) {
            
            # checking level access
            if( $dir.level -eq $level ) {
                
                $totalItems++

                $array += $dir.path

            } # end of if statement

        } # end of foreach loop

        if( $totalItems -lt 2 ) {
            
            return $array[0]

        } else {
            
            # going through the array to make the menu
            foreach( $item in $array ) {
            
                # adding menu item
                Write-Host "$($itemCount): $($item)"

                # adding one item to the menu count
                $itemCount++

            }

        }

        Write-Host " " # blank line for looks

        # menu entry
        $choice = Read-Host -Prompt "Please Select an directory"

    } Until( $choice -In 1..$itemCount ) # end of do loop

    return $array[($choice - 1)]

} # end of directoryLocation function

function addUser( $username, $forename, $surname, $ou, $level, $profile ) {
    
    cls

    # creating variables
    $ldap = $ConfigFile.Settings.Domains.ldap.value
    $email = $ConfigFile.Settings.Domains.email.value
    
    # finding out if password expires
    if( $ConfigFile.Settings.User.PasswordNeverExpires.value -eq "true" ) {
        
        $PasswordNeverExpires = $true

    } else {
        
        $PasswordNeverExpires = $false

    }

    # finding out if user needs to change password at logon
    if( $ConfigFile.Settings.User.ChangePasswordAtLogon.value -eq "true" ) {
        
        $ChangePasswordAtLogon = $true

    } else {
        
        $ChangePasswordAtLogon = $true

    }

    # finding out what the password should be
    if( $ConfigFile.Settings.User.Password.value -eq "%username%" ) {
        
        $password = $username

    } else {
        
        $password = $ConfigFile.Settings.User.Password.value

    }

    # clearing error status
    $error.Clear()

    # create new user
    Try {
        
        New-ADUser "$($username)" -DisplayName "$($forename) $($surname)" -EmailAddress "$($username)@$($email)" -GivenName "$($forename)" -Path "$($ou)" -SamAccountName "$($username)" -Surname "$($surname)" -UserPrincipalName "$($username)@$($ldap)" -ProfilePath "$($profile)" -AccountPassword (ConvertTo-SecureString -AsPlainText "$($password)" -Force) -PassThru | Enable-ADAccount -PassThru | Set-ADUser -ChangePasswordAtLogon $ChangePasswordAtLogon -PasswordNeverExpires $PasswordNeverExpires

    }
    catch {
        
        # writing error to log file
        write2Log "Failed to create user - $($username), because: $($_.Exception.Message)" "3" "Adding User" 

        return $false

    }

    # checking if user has been created
    if( !$error ) {

        # writing success to log file
        write2Log "Succeeded in creating new user - $($username)" "1" "Adding User"

        # foreach loop going through each child of the groups node
        foreach( $xmlGroup in $ConfigFile.Settings.Groups.group ) {
        
            if( $xmlGroup.level -ceq $level ) {
            
                # clearing error status
                $error.Clear()
                
                # adding user to group
                Try {
                    
                    Add-ADGroupMember -Identity $xmlGroup.name -Member $username

                }
                Catch {
                    
                    # writing error to log file
                    write2Log "Failed to add $($username) to $($xmlGroup.name), because: $($_.Exception.Message)" "3" "Adding User to group"

                }

                # adding success message
                if( !$error ) {
                    
                    write2Log "Succeeded in adding user - $($username) to group - $($xmlGroup.name)" "1" "Adding User to group"

                }

            } # end of if statement

        } # end of foreach loop

        return $true

    } # end of error if statement

} # end of addUser function

# function to get users forename
function foreName() {
    
    # getting forename
    $name = Read-Host -Prompt "Please enter Forename"

    if( $name -eq "" ) {

        Do {
        
            Write-Host ">>  Please supply a forename" -ForegroundColor Red
        
            $name = Read-Host -Prompt "Please enter Forename"

        } Until ( $name -ne "" )

    }

    return $name

} # end of foreName function

# function to get users forename
function surName() {
    
    # getting surname
    $name = Read-Host -Prompt "Please enter Surname"

    if( $name -eq "" ) {

        Do {
        
            Write-Host ">>  Please supply a surname" -ForegroundColor Red
        
            $name = Read-Host -Prompt "Please enter Surname"

        } Until ( $name -ne "" )

    }

    return $name

} # end of surName function

# function to get users forename
function driveLetter() {
    
    # getting surname
    $letter = Read-Host -Prompt "Please specify Homedrive Letter (e.g. 'N:' )"

    if( $letter -eq "" ) {

        Do {
        
            Write-Host ">>  Please supply a homedrive letter" -ForegroundColor Red
        
            $letter = Read-Host -Prompt "Please specify Homedrive Letter (e.g. 'N:' )"

        } Until ( $letter -ne "" )

    }

    return $letter

} # end of surName function

function singleUser() {
    
    cls

    # creating title
    Write-Host "------------ Single User Creation ------------"
    Write-Host " "

    # getting forename
    $forename = foreName

    # getting surname
    $surname = surName

    # getting cohort
    $cohort = Read-Host -Prompt "Please enter Cohort - (Leave blank if not needed)"

    # getting level
    $level = lvlMembership

    # getting username layout
    $layout = usrLayout
    
    # getting OU
    $ou = ouPath $level

    # getting directory location
    $dir = directoryLocation $level

    # getting profile path
    # finding out if profile path is available
    if( $ConfigFile.Settings.User.ProfilePath.value -eq "true" ) {
        
        $profile = profilePath $level

    } else {
        
        $profile = ""

    }
    

    # getting drive letter
    $drive = driveLetter

    # getting username
    $username = createUsername $layout $cohort $forename $surname

    # adding details to log file
    write2Log "=================== Single User Creation ===================" "1" "Single User"

    # creating user
    if( addUser $username $forename $surname $ou $level $profile ) {

        # creating home directory
        createDirectory $username $dir $drive

    } # end of if user statement

} # end of singleUser function

function multiUser() {
    
    cls

    # creating title
    Write-Host "------------ Multople User Creation ------------"
    Write-Host " "

    # getting forename
    $csv = Read-Host -Prompt "Please enter csv file location"

    # getting cohort
    $cohort = Read-Host -Prompt "Please enter Cohort - (Leave blank if not needed)"
    
    # getting level
    $level = lvlMembership

    # getting username layout
    $layout = usrLayout

    # getting OU
    $ou = ouPath $level

    # getting directory location
    $dir = directoryLocation $level

    # getting profile path
    # finding out if profile path is available
    if( $ConfigFile.Settings.User.ProfilePath.value -eq "true" ) {
        
        $profile = profilePath $level

    } else {
        
        $profile = ""

    }

    # getting drive letter
    $drive = driveLetter

    # adding details to log file
    write2Log "=================== Multi User Creation ===================" "1" "Multi User"

    # importing the csv file
    $csvFile = Import-Csv $csv

    # running through each user in csv file
    foreach( $line in $csvFile ) {

        # getting username
        $username = createUsername $layout $cohort $line.forename $line.surname

        # creating user
        if( addUser $username $line.forename $line.surname $ou $level $profile ) {
            
            # creating home directory
            createDirectory $username $dir $drive

        } # end of if user statement

    } # end of foreach loop

} # end of singleUser function

<#
    MENU
#>

Do {
cls
    Write-Host "----------- Create New User -----------

1: Create a Single user
2: Create multiple users from .csv
"

    $initialchoice = read-host -prompt "Please select an option from the menu"

} Until ($initialchoice -eq "1" -or $initialchoice -eq "2")

# running function depending on which option was selected
switch( $initialchoice ) {
    "1" { singleUser }
    "2" { multiUser }
}