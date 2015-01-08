# EdUsers
EdUsers is a PowerShell scripts that will allow any network administrator to do day to day user related active directory tasks easier and quicker.

At the moment the script only allows for single and multiple user creation but more features will be coming shortly.

## Contents
* [Requirements](#requirements)
* [Features](#features)
* [Contributors](#contributors)
* [Website](#website)
* [License](#license)

## Requirements
The following are required for this script to work fully
- Windows 7 / 8 / 8.1
- Remote Server Admin Tools
	- Active Directory Module for Windows PowerShell
- Windows Managment Framework 4.0
- Powershell Execution Policy Unrestricted
- Administrative access over the particular OUs required.

### Unrestrict Execution Policy
The powershell execution policy can be changed using the following cmdlet
```powershell
Set-ExecutionPolicy Unrestricted
```
To read more about the set-executionpolicy cmdlets, details can be found on the TechNet website found here. http://technet.microsoft.com/en-gb/library/hh849812.aspx

## Features
- Create Single User
- Create Multiple Users

## Contributors
Justin Byrne A.K.A [TheSk8rJesus](https://github.com/TheSk8rJesus)

## Website
Check out my other projects and any news, reviews and how to's on
http://jnm-tech.co.uk/

## License
The MIT License (MIT)

Copyright (c) 2015 TheSk8rJesus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.