Param([string] $userSettingsFile)

$scriptDir = (split-path $myinvocation.mycommand.path -parent)
Set-Location $scriptDir

# "========= Initialization =========" #

# Get settings from user configuration file
if($userSettingsFile -eq $nul -or $userSettingsFile -eq "")
{
	$userSettingsFile = "..\config.local.xml"
}

write-host "========= Opening a web page in IE... ========="

Open-IE -URLs www.microsoft.com

write-host "========= Setup completed successfully =========" -ForegroundColor Green
