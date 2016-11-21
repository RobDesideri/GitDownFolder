#Classes Definition
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
Class GitDataObject
{
	[String]$Author
	[String]$Repo
	[String]$Branch
	[String]$FirstDirPath
	[String]$TempFolder
}
Class GlobalGitDataObject
{
	[String]$UrlPrePrefix = 'https://api.github.com/repos/'
	[String]$UrlPrePostfix = '?ref='
	[String]$UrlPostPrefix = 'contents'
	[String]$Author
	[String]$Repo
	[String]$Branch
	[String]$FirstDirPath
	[String]$TempFolder
	
	GlobalGitDataObject(
		[String]$Author,
		[String]$Repo,
		[String]$Branch,
		[String]$FirstDirPath,
		[String]$TempFolder
	)
	{
		$this.Author = $Author
		$this.Repo = $Repo
		$this.Branch = $Branch
		$this.FirstDirPath = $FirstDirPath
		$this.TempFolder = $TempFolder
	}
}

#Factories 
Function New-GlobalGitDataObject{
	param(
		[System.Uri]$UrlToParse,
		[String]$TempFolder
	)

	try
	{
		$abs = $UrlToParse.AbsolutePath
	}
	catch [System.Exception]
	{
		Throw "Bad url parameter"
	}
	finally
	{
	}

	#Clean first and last '/' char
	If($abs.StartsWith("/"))
	{
		$abs = $abs.Substring(1)
	}
	If($abs.EndsWith("/"))
	{
		$abs = $abs.Substring(0,($abs.Length - 1))
	}
	$arr = $abs -split "\/"
	
	#Get dirPath
	for ($x = 4; $x -lt ($arr.Count); $x++)
	{
			$dirPath += $arr[$x] + "/"
	}

	$dirPath = $dirPath.Substring(0,($dirPath.Length - 1))

	$parsed = (0..4) 
	$parsed[0] = $arr[0]
	$parsed[1] = $arr[1]
	$parsed[2] = $arr[3]
	$parsed[3] = $dirPath
	$parsed[4] = $TempFolder
	$t = [GlobalGitDataObject]
	New-Singleton -SingletonClass $t -ParamArray $parsed
	[GlobalGitDataObject]$s = Get-Singleton -ObjectClassName $t.ToString()
	Return ($s -as [GlobalGitDataObject])
}
Function New-GitFolder ($FolderName, $DirPath)
{
	$fld = New-Object -TypeName GitFolder
	$fld.Name = $FolderName
	$gdo = Get-GlobalGitDataObject
	$fld.UrlPrefix = $gdo.UrlPrePrefix + $gdo.Author + '/' + $gdo.Repo + '/' + $gdo.UrlPostPrefix + '/'
	$fld.UrlPostfix = $gdo.UrlPrePostfix + $gdo.Branch
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
Function New-GitFolderList()
{
	Return New-Object -TypeName GitFolderList
}
Function New-GitFileList()
{
	Return New-Object -TypeName GitFileList
}