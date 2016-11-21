Function Invoke-GitDownFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$False,Position=0)]
        [String]$GitFolderUrlToDownload,
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$False,Position=1)]
        [String]$DestinationPath,
		[Switch]$KeepRootFolderPath
	)

	$UrlObj = Get-SystemUriFromUrl -Url $GitFolderUrlToDownload
	Set-ScriptVars -UrlAsObject $UrlObj
	$gdo = Get-GlobalGitDataObject
	$rootFolder =  New-GitFolder -FolderName "ROOT" -DirPath $gdo.FirstDirPath
	$rootFolderList = New-GitFolderList
	$rootFolderList.AddFolder($rootFolder)
	Start-FilesFoldersScan -GitFolderList $rootFolderList
	$bol = $False
	If($KeepRootFolderPath){$bol = $True}
	Move-GitFolder -DestPath $DestinationPath -KeepRootFolderPath $bol
}