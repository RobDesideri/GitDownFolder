$GithubUrlTemplate = @{
	
	UrlPrePrefixForDownload = 'https://api.github.com/repos/'
	UrlPrePostfixForDownload = '?ref='
	UrlPostPrefixForDownload = 'contents'
	
	SchemeAndHostPattern = '$Scheme://$Host'
	AbsoluteStringPattern = '/$Author/$Repo/tree/$Branch/$DirPath'
	FullPattern = '$SchemeAndHostPattern$AbsoluteStringPattern'
}

#Classes Definition

Class GlobalGitData
{
	[String]$Author
	[String]$Repo
	[String]$Branch
	[String]$RootDirPath
	hidden [String]$_fixScheme = 'https'
	hidden [String]$_fixHost = 'github.com'
	hidden [Int]$_fixMinSegments = 6
	hidden [Int]$_fixAuthorSegmentIndex = 2
	hidden [Int]$_fixRepoSegmentIndex = 3
	hidden [Int]$_fixBranchSegmentIndex = 5
	hidden [Int]$_fixDirPathSegmentFirstIndex = 6
	hidden [Int]$_fixDirPathSegmentLastIndexIsLastIndex = $true
	hidden [Int]$_fixDirPathSegmentLastIndex = $null

	GlobalGitData([String]$GithubUrl, [Singleton]$Singleton)
	{
		#validate and get url absolute path
		try
		{
			$chk = $this.validateGithubUrl($GithubUrl)
			If($chk) {
				$seg = $this.getGitSegmentsFromUrl($GithubUrl)
				$this.setPropertyFromSegments($seg)
				$Singleton.NewSingleton($this)
			}
		}
		catch [System.Exception]
		{
			$this.Author = ""
			$this.Repo = ""
			$this.Branch = ""
			$this.RootDirPath = ""
			Throw "GlobalGitData not initializated: $Error[0]"
		}
		finally
		{
		}
	}

	hidden [String]getGitSegmentsFromUrl([System.Uri]$GithubUrl)
	{
		$arr = $GithubUrl.Segments
		Return $arr
	}

	hidden [Bool]validateGithubUrl([System.Uri]$GithubUrl) 
	{
	
		#1) check url
		$chk = [System.Uri]::IsWellFormedUriString($GithubUrl, [System.UriKind]::Absolute)
		If($chk -eq $False)
		{
			Throw "$GithubUrl is not an absolute url"
		}

		#2) check host name
		$H = $this._fixHost
		$h = $GithubUrl.Host

		If($h -ne $H)
		{
			Throw "$GithubUrl is not a github url"
		}

		#3) check url scheme
		$S = $this._fixScheme
		$s = $GithubUrl.Scheme
	
		If($s -ne $S)
		{
			Throw "$GithubUrl is not a secure http url"
		}

		#4) check segments number
		$SN = $this._fixMinSegments
		$sn = $GithubUrl.Segments.Count

		If($s -lt $SN)
		{
			Throw "$GithubUrl not contains all segments in url"
		}

		Return $True
}

	hidden setPropertyFromSegments([Array]$SegmentsArray)
	{
		#Reference:
		#	0: [String]Author
		#	1: [String]Repo
		#	2: [String]Branch
		#	3: [String]FirstDirPath

		#Retrieve global constants
		$ai = $this._fixAuthorSegmentIndex
		$ri = $this._fixRepoSegmentIndex
		$bi = $this._fixBranchSegmentIndex
		$dfi = $this._fixDirPathSegmentFirstIndex
	
		#DirPathSegmentLastIndex Pattern (see $global:GithubUrlTemplate comments)
		#>>
			If($this._fixDirPathSegmentLastIndexIsLastIndex)
			{
				$dli = $SegmentsArray.Count
			}
			Else
			{
				$dli = $this._fixDirPathSegmentLastIndex
			}
		#>>
	
		$this.Author = $SegmentsArray[$ai]
		$this.Repo = $SegmentsArray[$ri]
		$this.Branch = $SegmentsArray[$bi]
		$this.RootDirPath = [System.String]::Join("", $SegmentsArray, $dfi, ($dli - $dfi))
	}
}

Class GitFolder
{
    [String]$Name
	hidden [String]$_gitFolderUrl
	hidden [String]$_author
	hidden [String]$_repo
	hidden [String]$_branch
	[String]$UrlPrefix
    [String]$UrlPostfix
    [String]$DirPath
	[GitFileList]$GitFileList

	GitFolder([String]$GitFolderUrl, [GlobalGitData]$GlobalGitData) {
		$this.DirPath = $GitFolderUrl
		$this.Name = Split-Path -Path $GitFolderUrl -Leaf
		$this._author = $GlobalGitData.Author
		$this._branch = $GlobalGitData.Branch
		$this._repo = $GlobalGitData.Repo
	}

	hidden [String]getPrefix() {
		$prefix = $this._pre + $this._author + $this._sep + $this._repo + $this._sep + $this._mid + $this._sep
		Return $prefix
	}

	hidden [String]getPostfix() {
		$post = $this._post + $this._branch
		Return $post
	}

	[String]GetScannerUrl() {
		$pre = $this.GetPrefix()
		$post = $this.GetPostfix()
		$url = $pre + $this.DirPath + $post
		Return $url
	}
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

	GitFile([String]$FileName, [String]$FilePath, [String]$FileUrl, [String]$FileSize) 
	{
		$this.Name = $FileName
		$this.Path = $FilePath
		$this.Url = $FileUrl
		$this.Size = $FileSize
	}
}

Class GitFileList
{
	hidden [System.Collections.ArrayList]$list
	
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

Class Singleton
{
	hidden [Object]$_object = $null

	Singleton() {}
	
	NewSingleton ($SingletonClass, $ParamArray)
	{
		$className = $SingletonClass.Name
		
		#Signleton checking
		$chk = testSingletonIsLive($className)
		If($chk)
		{
			Throw "Singleton already exists"
		}
		Else
		{
			$obj = instanceObject($className, $ParamArray)
			createSecretVar($obj)
			$this._object = $obj
		}
	}

	NewSingleton ($Object)
	{
		$className = $Object.GetType().ToString()
		
		#Signleton checking
		$chk = testSingletonIsLive($className)
		If($chk)
		{
			Throw "Singleton already exists"
		}
		Else
		{
			createSecretVar($Object)
			$this._object = $Object
		}
	}

	[Object]GetSingleton ($ObjectClassName)
	{
		$chk = testSingletonIsLive($ObjectClassName)
		If($chk)
		{
			Return $this._object
		} 
		Else 
		{
			Return $null
		}
	}

	Dispose ($Object)
	{
		$className = $Object.GetType().ToString()
		$chk = testSingletonIsLive($className)
		If($chk)
		{
			$v = getSecretVarName($Object)
			Remove-Variable -Name $v -Force -Scope global
		} 
		Else 
		{
			Throw "Singleton not found"
		}
	}

	hidden [String]getSecretVarName ($Object)
	{
		$s = "Singleton__" + $Object.GetType().ToString() + $Object.GetHash().ToString() + "__"
		Return $s
	}

	hidden [Bool]testSingletonIsLive ([String]$SingletonClassName)
	{
		$sl = $null
		$sn = getSingletonSecretVar -SingletonClassName $SingletonClassName
		$sl = Get-Variable -Name $sn -Scope global -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

		if($sl -eq $null)
		{
			Return $false
		} Else {
			Return $true
		}
	}

	hidden [Object]instanceObject([String]$ClassName, [String[]]$ArgumentList)
	{
		$obj = New-Object -TypeName $className -ArgumentList $ArgumentList
		Return $obj
	}

	#create secret variable for singleton pattern check
	hidden createSecretVar([Object]$Object)
	{
		$secretName = getSecretVarName($Object)
		New-Variable -Name $secretName -Scope global -Visibility Private -Value $Null
	}
}

Class GitDownloader
{
	hidden[String]$_header = @{'responseType' = 'arraybuffer'}
	hidden[String]$_gdo = $Null
	hidden[String]$_tempPath = ""

	GitDownloader([GlobalGitData]$GlobalGitData, [String]$TempFolderPath)
	{
		$this._gdo = $GlobalGitData
		$chk = validateFolderPath($TempFolderPath)
		If($chk)
		{
			$this._tempPath = cleanFolderPath($TempFolderPath)
		}
		Else
		{
			Throw "Bad temp folder path"
		}
	}

	Start([GitFolderList]$GitFolderList)
	{
		$c = $GitFolderList.CountFolders()
		$jsonFolderMap = $null
		$folderMap = $null

		#iteration through GitFolderList items
		For ($x = 0; $x -lt $c; $x++)
		{
			#Folder Under Scan (FUS)
			[GitFolder]$thisFolder = $GitFolderList.GetFolder($x)
			
			#retrieve FUS map by github.com
			[String]$url = $thisFolder.GetScannerUrl()
			$folderMap = getFolderMap($url)

			#instance New Folder List (nfol)
			$newGitFolderList = [GitFolderList]::new()

			#instance New File List (nfil)
			$newGitFileList = [GitFileList]::new()
		
			#iterate through FUS items
			Foreach ($item in $folderMap)
			{
				switch ($item.type)
				{
					#if item is folder, add it to the nfol (see >recursion<)
					'dir'
					{
						$newFld = [GitFolder]::new($item.Path, $this._gdo)
						$newGitFolderList.AddFolder($newFld)
					}

					#if item is file, add it to the nfil
					'file'
					{
						$newFile = [GitFile]::new($item.name, $item.Path, $item.download_url, $item.size )
						$newGitFileList.AddFile($newFile)
					}
				}
			}

			#add nfil to FUS
			If($($newGitFileList.CountFiles()) -gt 0)
			{
				$thisFolder.GitFileList = $newGitFileList
			}
		
			#>recursion< if other folders in this folder
			If($($newGitFolderList.CountFolders()) -gt 0)
			{
			StartScan($newGitFolderList)
		}
		}

		#program come to this statement only all recursions are made
		#download all files in FUS
		If($($thisFolder.GitFileList) -ne $null){
			If($($thisFolder.GitFileList.CountFiles()) -gt 0){
				startFilesDownload($thisFolder)
			}
		}
	}

	hidden[Bool]validateFolderPath([String]$TempFolderPath)
	{
		$chk = Test-Path -Path $TempFolderPath -IsValid
		Return $chk
	}

	hidden[String]cleanFolderPath([String]$TempFolderPath)
	{
		If($TempFolderPath.EndsWith('/'))
			{
				$TempFolderPath.Remove(($TempFolderPath.Length - 1), 1)
			}

		Return $TempFolderPath
	}	

	hidden[Object]getFolderMap([String]$Url)
	{
		$resp = Invoke-Webrequest -Uri $Url -Method Get -Headers ($this._header)
		$folderMap = ConvertFrom-Json -InputObject ($resp.Content)
		Return $folderMap
	}

	hidden startFilesDownload([GitFolder]$GitFolder)
	{
		#retrieve files list
		$gfl = $GitFolder.GitFileList
		
		$c = $gfl.CountFiles()
		$gdo = $this._gdo
	
		#iterate through files list
		For ($x = 0; $x -lt $c; $x++)
		{
			#retrieve GitFile
			$f = $gfl.GetFile($x)
			
			#retrieve GitFile data
			$fn = $f.Name
			$fp = $f.Path

			#local file path
			$lfp = $this._tempPath + '\' + $fp
			
			#local folder path
			$path = Split-Path -Path $lfp -Parent
			
			#linux to windows slash
			$path -replace '\/', '\'

			newFolder($path)
		
			Start-BitsTransfer -Source $f.Url -Destination "$path\$fn"
		}
}

	hidden newFolder([String]$Path)
	{
		$chk = Test-Path -Path $Path -PathType Container
	
		If(-not($chk)){
		New-Item -Path $Path -ItemType Directory
	}
}

}