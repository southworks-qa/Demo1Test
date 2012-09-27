Param()

###################
#    Functions    #
###################

function MoveFileContents ([string] $sourceFilePath, [string] $destinationFilePath )
{
       [byte[]] $bytes = [System.IO.File]::ReadAllBytes( $(resolve-path $sourceFilePath) )
       [System.IO.File]::WriteAllBytes($destinationFilePath, $bytes)
}

function UnblockFile([string] $filePath)
{
    $filePath = Resolve-Path $filePath
    $bakFilePath = $filePath + ".bak"
    Rename-Item $filePath $bakFilePath 
    MoveFileContents $bakFilePath $filePath   
    Remove-Item $bakFilePath
}

function DownloadFile([string] $filePath)
{	
	$url = "http://go.microsoft.com/fwlink/?LinkId=255267"
    
	$webclient = New-Object System.Net.WebClient 
    
    try 
    {       
        if(Test-Path $filePath)
        {
            Remove-Item $filePath
        }

        $webclient.DownloadFile($url, $filePath)
    }        
    catch [System.Net.WebException]
    {
        if(Test-Path $filePath)
        {
            Remove-Item $filePath
        }
        
        write-error "An error has occurred downloading the Demo Toolkit files."
        exit
    }
}

function Unzip([string] $filePath, [string] $outputPath)
{
	$shell_app = new-object -com shell.application 
	$zip_file = $shell_app.namespace($filePath) 
	$destination = $shell_app.namespace($outputPath) 
	$destination.Copyhere($zip_file.items())
}

function UserPSModulesFolder()
{
		[string] $myDocumentsFolder = [Environment]::GetFolderPath(“MyDocuments”)
		if (-NOT (test-path "$myDocumentsFolder"))
		{
			$myDocumentsFolder = "$env:UserProfile\Documents";
		}

		"$myDocumentsFolder\WindowsPowerShell\Modules\DemoToolkit"
}

function ConfirmDownload()
{
		$title = ""
		$message = "This script will download the DPE Demo Toolkit to automate the configuration of the demo.  Do you wish to download it now?"
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
		$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
		$confirmation = $host.ui.PromptForChoice($title, $message, $options, 1)

		if ($confirmation -eq 1) {
			exit 1
		}
		
		$true
}

function ShouldInstallModuleUpdate()
{
	try
	{
		# Check if the DemoToolkit is available
		$module = Get-Module -ListAvailable -Name DemoToolkit
	}
	catch { }

	if(-not $module)
	{
		return $true
	}
	
	# Retrieve version number from blob metadata and compare with installed module
	try
	{
		$request = [System.Net.HttpWebRequest]::Create("http://go.microsoft.com/fwlink/?LinkId=255267&comp=metadata")
		$request.Method = "HEAD"
		$response = $request.GetResponse()
		$version = New-Object System.Version($response.headers["x-ms-meta-version"])
		$response.Close()
		
		($version.CompareTo($module.Version) -gt 0)
	}
	catch
	{
		return $false
	}
}

#####################
#    Main script    #
#####################

if(ShouldInstallModuleUpdate)
{
	if(ConfirmDownload)
	{
		Write-host "Downloading..."
		
        # Download to a file in temp folder
        [string] $tempFolder = [System.IO.Path]::GetTempPath()
	    [string] $zipFilePath = Join-Path $tempFolder "demo-toolkit.zip"

		# Download demo-toolkit.zip File
		DownloadFile $zipFilePath

		
		Write-host "Unlocking downloaded file..."
		# Unblock demo-toolkit.zip File (Zone.Identifier)
		UnblockFile $zipFilePath

	    # Install in %UserProfile%\My Documents\WindowsPowerShell\Modules\DemoToolkit
        [string] $demoToolkitFolderPath = UserPSModulesFolder

        Write-host "Installing DemoToolkit in [$demoToolkitFolderPath]..."
		# Check if the DemoToolkit Folder already exists. Then delete its content or create it if necessary
		if(Test-Path $demoToolkitFolderPath)
		{
			Remove-Item "$demoToolkitFolderPath\*" -Recurse
		}
		else
		{
			New-Item $demoToolkitFolderPath -type directory | Out-Null
		}

		Write-host "Extracting files..."
		Unzip $zipFilePath $demoToolkitFolderPath

        Write-host "DemoToolkit Module successfully!" -ForegroundColor Green
	}
}
else
{
    Write-host "DemoToolkit Module is already installed!" -ForegroundColor Green
}