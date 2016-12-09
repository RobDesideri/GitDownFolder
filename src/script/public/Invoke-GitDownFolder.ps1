Function Invoke-GitDownFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$False,Position=0)]
        [String]$GitFolderUrlToDownload,
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$False,Position=1)]
        [String]$DestinationPath
	)

	$GithubUrl = Get-SystemUriFromUrl -Url $GitFolderUrlToDownload
	$TempFolder = New-TemporaryFolder
	
	#Instance the GlobalGitDataObject
	$Singleton = [Singleton]::new()
	$GlobalGitDataObject = [GlobalGitData]::new($GithubUrl, $Singleton)
	
	#Instance the root GitFolderList
	$RootGitFolderPath =  $GlobalGitDataObject.RootDirPath
	$RootGitFolder = [GitFolder]::new($RootGitFolderPath, $GlobalGitDataObject)
	$RootGitFolderList = [GitFolderList]::new()
	$RootGitFolderList.AddFolder($RootGitFolder)

	#Pass the root GitFolderList and download all!
	$Downloader = [GitDownloader]::new($GlobalGitDataObject, $TempFolderPath)
	$Downloader.Start($RootGitFolderList)

	#Move temp folder to DesinationPath
	Move-Item -Path $TempFolderPath -Destination $DestPath
	Remove-Item -Path $TempFolderPath -Force -Recurse
}