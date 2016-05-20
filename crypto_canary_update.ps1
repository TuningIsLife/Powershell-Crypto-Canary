##############################################
# "Crypto Canary" Powershell update script
# Written 2016-05-20 by P. Gill 
##############################################

#Get date
$date = get-date -format yyyyddMM

#Define variables
$DATFile = "$env:temp\Ransomware.dat$date"

# Import Ransomware DAT file
$list = Import-Csv $DATFile

#Modify DAT file for each OS and convert to string
$anyVar='*'
$08delimChar='|'
$12delimChar=','
$12doubleQuotes='"'

[string]$08DAT = get-content $DATFile | select -Skip 1 | %{$_.split('"')[1]} | % {$anyVar+$_+$08delimChar} | Foreach {$_.Trim()}
[string]$12DAT = get-content $DATFile | select -Skip 1 | %{$_.split('"')[1]} | % {$12doubleQuotes+$anyVar+$_+$12doubleQuotes+$12delimChar} | Foreach {$_.Trim()}

#Drop the last character from each string
$08DAT = $08DAT -replace ".{1}$"
$12DAT = $12DAT -replace ".{1}$"

#Detect OS version
$serverInfo=Get-WmiObject -class Win32_OperatingSystem
$osVersion=$serverInfo.Version.Substring(0,3)

#Determine correct syntax for OS and update patterns
#Server 2012 R2
if ($osVersion -eq "6.3") {	

#Create FSRM File Group
Set-FsrmFileGroup -Name "Cryptoware" –IncludePattern @($12DAT)

#Server 2008 R2
} elseif ($osVersion -eq "6.1") {

#Update FSRM File Group
Filescrn filegroup modify /filegroup:"Cryptoware" /members:"$08DAT"
}
