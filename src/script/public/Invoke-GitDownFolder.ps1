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

#Singleton Pattern
Function Get-SingletonVarName ($SingletonClassName)
{
    $sn = "__" + $SingletonClassName + "SingletonLive__"
	Return $sn
}
Function Test-SingletonIsLive ($SingletonClassName)
{
	$sl = $null
	$sn = Get-SingletonVarName -SingletonClassName $SingletonClassName
    $sl = Get-Variable -Name $sn -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

	if($sl -eq $null)
	{
		Return $false
	} Else {
		Return $true
	}
}
Function New-Singleton ($SingletonClass, $ParamArray)
{
	$className = $SingletonClass.Name
	$chk = Test-SingletonIsLive -SingletonClassName $className
	If(-not($chk)){
		Format-SingletonParameter -SingletonClass $SingletonClass -ParameterArray $ParamArray #NON utile, solo per prova. Prova OK!
		[Array]$ob = @()
		$i = 0
		Foreach ($item in $ParamArray)
		{
			$ob += $ParamArray[$i]
			$i++
		}
		$tmpOb = New-Object -TypeName $className -ArgumentList $ob
		$sn = Get-SingletonVarName -SingletonClassName $className
		New-Variable -Name $sn -Visibility Private -Scope global -Value $tmpOb
		Return $sn
	} 
}

Function Get-ConstructorByParam([Type]$Type, [Array]$ParamArray)
{
	$n = $ParamArray.Count
	[Array]$typesArray = @()
	Foreach ($item in $ParamArray)
	{
		$typesArray += $item.GetType()
	}
	[Reflection.ConstructorInfo[]]$rcis = Get-ConstructorByParamNumber -Type $Type -ParamNumber $n
	[Reflection.ConstructorInfo]$rci = Get-ConstructorByParamType -ConstructorsArray $rcis -TypesArray $typesArray
	Return $rci
}

Function Get-ConstructorByParamNumber ([Type]$Type, [Int]$ParamNumber)
{
	$arr = [Array]::CreateInstance([Reflection.ConstructorInfo], 0)
	
	Foreach ($item in $Type.GetConstructors())
	{
		$params = $item.GetParameters()
		$count = $params.Count
		If($count -eq $ParamNumber)
		{
			$arr += $item
		}
	}
	Return $arr
}

Function Get-ConstructorByParamType ([Reflection.ConstructorInfo[]]$ConstructorsArray, [Array]$TypesArray)
{
	Foreach ($item in $ConstructorsArray)
	{
		$i = 0
		[Boolean]$chk = $true
		Foreach ($param in $item.GetParameters())
		{
			If($param.ParameterType -eq $TypesArray[$i])
			{
				$chk = $chk -and $true
			}
			Else 
			{
				Break
			}
			$i++
		}
		If(($i -eq $TypesArray.Count) -and ($chk -eq $true)) {Return [Reflection.ConstructorInfo]$item; Exit}
	}
}

Function Format-SingletonParameter ($SingletonClass, $ParameterArray)
{
	$cnt = Get-ConstructorByParam -Type $SingletonClass -ParamArray $ParameterArray
}

Function Get-Singleton ($ObjectClassName)
{
	$chk = Test-SingletonIsLive -SingletonClassName $ObjectClassName
	If($chk)
	{
		$svn = Get-SingletonVarName -SingletonClassName $ObjectClassName
		$sg = Get-Variable -Name $svn -ValueOnly
		Return $sg
	} Else {
		Return $null
	}
}

#Factories 
Function New-GlobalGitDataObject($UrlToParse, $TempFolder)
{
	$abs = $UrlToParse.AbsolutePath

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
			$dirPath += $arr[$x]
	}
	$parsed = (0..4) 
	$parsed[0] = $arr[0]
	$parsed[1] = $arr[1]
	$parsed[2] = $arr[3]
	$parsed[3] = $dirPath
	$parsed[4] = $TempFolder
	$t = [GlobalGitDataObject]
	New-Singleton -SingletonClass $t -ParamArray $parsed
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

#Mediators
Function Get-GlobalGitDataObject()
{
	$gdo = Get-Singleton -ObjectClassName "GlobalGitDataObject"
	Return $gdo
}

#Initializator
Function Set-ScriptVars($UrlAsObject)
{
	$tmpFld = New-TemporaryFolder
	#$pUrl = Get-ParseGitUrl -Url $Url
	New-GlobalGitDataObject -UrlToParse $UrlAsObject -TempFolder $tmpFld
}

#Functions
Function Get-SystemUriFromUrl ([string]$Url)
{
	$uri = ($url -as [System.Uri])
	Return $uri
}
Function Start-FilesDownload ([GitFolder]$GitFolder)
{
	$gfl = $GitFolder.GitFileList
	$c = $gfl.CountFiles()
	$gdo = Get-GlobalGitDataObject
	for ($x = 0; $x -lt $c; $x++)
	{
		$fl = $gfl.GetFile($x)
		$p = $gdo.TempFolder + "\" + $fl.Path
		$p = $p -replace '\/', '\'
		$p = Split-Path -Path $p -Parent
		$n = $fl.Name
		New-Folder -Path $p
		Start-BitsTransfer -Source $fl.Url -Destination "$p\$n"
	}
	Remove-Variable -Name gfl
}
Function Start-FilesFoldersScan ([GitFolderList]$GitFolderList)
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
			Start-FilesFoldersScan -GitFolderList $newGitFolderList
		}
	}
	If($($thisFolder.GitFileList) -ne $null){
		If($($thisFolder.GitFileList.CountFiles()) -gt 0){
			Start-FilesDownload -GitFolder $thisFolder
		}
	}
}

#MAIN
function Invoke-GitDownFolder([String]$GitFolderUrlToDownload)
{
	$UrlObj = Get-SystemUriFromUrl -Url $GitFolderUrlToDownload
	Set-ScriptVars -UrlAsObject $UrlObj
	$gdo = Get-GlobalGitDataObject
	$rootFolder =  New-GitFolder -FolderName "ROOT" -DirPath $gdo.FirstDirPath
	$rootFolderList = New-GitFolderList
	$rootFolderList.AddFolder($rootFolder)
	Start-FilesFoldersScan -GitFolderList $rootFolderList
}

$testUrl = "https://github.com/RobDesideri/PowerShellTestingHelpers/tree/develop/src/"
Invoke-GitDownFolder -GitFolderUrlToDownload $testUrl

#TODO portare poi la cartella nella posizione desiderata e cancellare la cartella temporanea