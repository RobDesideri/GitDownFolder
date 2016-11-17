Class ParsedGitUrl
{
	[String]$Author
	[String]$Repo
	[String]$Branch
	[String]$DirPath
}
Class GitFolder
{
    [String]$Name
	[String]$UrlPrefix
    [String]$UrlPostfix
    [String]$DirPath
	[GitFileList]$GitFileList
}
Class GitFolderList
{
	[System.Collections.ArrayList]$list #to hide
	
	GitFolderList(){
		$this.list = [System.Collections.ArrayList]::new()
	}
	[Void]AddFolder([GitFolder]$GitFolderObject){
		$this.list.Add($GitFolderObject)
	}
	[Void]RemoveFolder([Int]$Item){
		$this.list.Remove($Item)
	}
	[GitFolder]GetFolder([Int]$Item){
		[GitFolder]$im = $this.list[$Item]
		Return $im
	}
	[Int]CountFolders(){
		[Int]$cnt = $this.list.Count
		Return $cnt
	}
}

Class GitFile
{
	[String]$Name
	[Long]$Size
	[String]$Path
	[String]$Url
}
Class GitFileList
{
	[System.Collections.ArrayList]$list #to hide
	
	GitFileList(){
		$this.list = [System.Collections.ArrayList]::new()
	}
	[Void]AddFile([GitFile]$GitFileObject){
		$this.list.Add($GitFileObject)
	}
	[GitFile]GetFile([Long]$Item){
		[GitFile]$im = $this.list[$Item]
		Return $im
	}
	[Int]CountFiles(){
		[Int]$cnt = $this.list.Count
		Return $cnt
	}
}
New-Variable -Name UrlPrePrefix -Value 'https://api.github.com/repos/' -Scope script -Option ReadOnly
New-Variable -Name UrlPrePostfix -Value '?ref=' -Scope script -Option ReadOnly
New-Variable -Name UrlPostPrefix -Value 'contents' -Scope script -Option ReadOnly

Function Get-SystemUriFromUrl ([string]$Url)
{
	$uri = ($url -as [System.Uri])
	Return $uri
}

Function Set-ScriptVars([System.Uri]$Url)
{
	$tmpFld = New-TemporaryFolder
	[string]$abs = $Url.AbsolutePath
	If($abs.StartsWith("/"))
	{
		$abs = $abs.Substring(1)
	}
	If($abs.EndsWith("/"))
	{
		$abs = $abs.Substring(0,($abs.Length - 1))
	}
	$arr = $abs -split "\/"
	$author = $arr[0]
	$repo = $arr[1]
	$branch = $arr[3]
	for ($x = 4; $x -lt ($arr.Count); $x++)
	{
			$dirPath += $arr[$x]
	}
	New-Variable -Name Author -Value $author -Scope script
	New-Variable -Name Repo -Value $repo -Scope script
	New-Variable -Name Branch -Value $branch -Scope script
	New-Variable -Name FirstDirPath -Value $dirPath -Scope script
	New-Variable -Name TempFolder -Value $tmpFld -Scope script

}

Function New-GitFolder ([String]$FolderName, [String]$DirPath)
{
	$fld = New-Object -TypeName GitFolder
	$fld.Name = $FolderName
	$fld.UrlPrefix = $UrlPrePrefix + $script:Author + '/' + $script:Repo + '/' + $UrlPostPrefix + '/'
	$fld.UrlPostfix = $UrlPrePostfix + $script:Branch
	$fld.DirPath = $DirPath
	Return [GitFolder]$fld
}

Function New-GitFile ([String]$FileName, [String]$FilePath, [String]$FileUrl, [String]$FileSize)
{
	$newFile = New-Object -TypeName GitFile
	$newFile.Name = $FileName
	$newFile.Path = $FilePath
	$newFile.Url = $FileUrl
	$newFile.Size = $FileSize
	Return $newFile
}

Function New-TemporaryFolder()
{
	$tmpDir = [System.IO.Path]::GetTempPath()
	$tmpDir = [System.IO.Path]::Combine($tmpDir, [System.IO.Path]::GetRandomFileName())
	[System.IO.Directory]::CreateDirectory($tmpDir) | Out-Null
	Return $tmpDir
}

Function New-Folder([String]$Path)
{
	$chk = Test-Path -Path $Path -PathType Container
	If(-not($chk)){
		New-Item -Path $Path -ItemType Directory
	}
}

Function Start-FilesDownload ([GitFolder]$GitFolder)
{
	$gfl = $GitFolder.GitFileList
	$c = $gfl.CountFiles()
	for ($x = 0; $x -lt $c; $x++)
	{
		$fl = $gfl.GetFile($x)
		$p = $script:TempFolder + "\" + $fl.Path
		$p = $p -replace '\/', '\'
		$p = Split-Path -Path $p -Parent
		$n = $fl.Name
		New-Folder -Path $p
		Start-BitsTransfer -Source $fl.Url -Destination "$p\$n"
	}
	Remove-Variable -Name gfl
}

function Get-RepoMap ([GitFolderList]$GitFolderList)
{
	$rt = @{'responseType' = 'arraybuffer'}
	$c = $GitFolderList.CountFolders()

	$thisFolder = New-Object -TypeName GitFolder
	
	$jsonFolderMap = $null
	$folderMap = $null

	for ($x = 0; $x -lt $c; $x++)
	{
		$thisFolder = $GitFolderList.GetFolder($x)
		[String]$uri = $thisFolder.UrlPrefix + $thisFolder.DirPath + $thisFolder.UrlPostfix
		$resp = Invoke-Webrequest -Uri $uri -Method Get -Headers $rt
		$jsonFolderMap = $resp.Content
		$folderMap = ConvertFrom-Json -InputObject $jsonFolderMap
		#$jsonFolderMap.Dispose()
		$newGitFileList = New-Object -TypeName GitFileList
		$newGitFolderList = New-Object -TypeName GitFolderList
		
		foreach ($item in $folderMap)
		{
			switch ($item.type)
			{
				'dir'
				{
					$newFld = New-GitFolder -FolderName ($item.name) -DirPath ($item.path)
					$newGitFolderList.AddFolder($newFld)
					Remove-Variable -Name newFld -Force
				}
				'file'
				{
					$newFile = New-GitFile -FileName $item.name -FilePath $item.Path -FileUrl $item.download_url -FileSize $item.size
					$newGitFileList.AddFile($newFile)
					Remove-Variable -Name newFile -Force
				}
		}
		}
		If($($newGitFileList.CountFiles()) -gt 0)
		{
			$thisFolder.GitFileList = $newGitFileList
		}
		Remove-Variable -Name newGitFileList -Force
		If($($newGitFolderList.CountFolders()) -gt 0)
		{
			Get-RepoMap -GitFolderList $newGitFolderList
		}
	}
	If($($thisFolder.GitFileList) -ne $null){
		If($($thisFolder.GitFileList.CountFiles()) -gt 0){
			Start-FilesDownload -GitFolder $thisFolder
		}
	}
}

function Get-FileAndDirectoryMap ([GitFolderList]$GitFldLst)
{
	$rt = @{'responseType' = 'arraybuffer'}
	$c = $GitFldLst.CountFolders()
	$gitFl = New-Object -TypeName GitFolder
	$resp = $null
	$jsonObj = $null
	$gitFileList = New-Object -TypeName System.Collections.ArrayList

	for ($x = 0; $x -lt $c; $x++)
	{
		$gitFl = $GitFldLst.GetFolder($x)
		[String]$uri = $gitFl.UrlPrefix + $gitFl.DirPath + $gitFl.UrlPostfix
		$resp = Invoke-Webrequest -Uri $uri -Method Get -Headers $rt
		$jsonObj = ConvertFrom-Json -InputObject $resp.Content
		
		foreach ($item in $jsonObj)
		{
			switch ($item.type)
			{
				'dir'
				{
					$newFld = New-Object -TypeName GitFolder
					$newFld.DirPath = $item.path
					$GitFldLst.AddFolder($newFld)
					Remove-Variable -Name $newFld
				}
				'file'
				{
					$gitOb = New-Object -TypeName GitFile
					$gitOb.Path = $item.path
					$gitOb.Url = $item.download_url
					Set-GitFile -InputObject $gitOb
					$gitFileList.Add($gitOb)
					Remove-Variable -Name $gitOb
				}
		}
		}
	}

	if($GitFldLst.CountFolder -lt 1)
	{
		Import-GitFile -GitFileList $gitFileList -GitFolder $GitRes
	} Else {
		Get-FileAndDirectoryMap $GitFldLst
	}
}
$testUrl = "https://github.com/RobDesideri/PowerShellTestingHelpers/tree/develop/src/"
$thisParsedUrl = New-Object -TypeName ParsedGitUrl
$rootFolder = New-Object -TypeName GitFolder
$folders = New-Object -TypeName GitFolderList

$thisUrl = Get-SystemUriFromUrl -Url $testUrl
Set-ScriptVars -Url $thisUrl
$rootFolder =  New-GitFolder -FolderName "ROOT" -DirPath $script:FirstDirPath
$folders.AddFolder($rootFolder)
$thisMap = Get-RepoMap $folders

#TODO portare poi la cartella nella posizione desiderata e cancellare la cartella temporanea