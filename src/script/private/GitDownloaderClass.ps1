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
	[Array]$GitFolderList
	hidden [String]$_fixScheme = 'https'
	hidden [String]$_fixHost = 'github.com'
	hidden [Int]$_fixMinSegments = 6
	hidden [Int]$_fixAuthorSegmentIndex = 1
	hidden [Int]$_fixRepoSegmentIndex = 2
	hidden [Int]$_fixBranchSegmentIndex = 4
	hidden [Int]$_fixDirPathSegmentFirstIndex = 5

	GlobalGitData([String]$GithubUrl)
	{
		try
		{
			#validate and get url absolute path
			$chk = $this.validateGithubUrl($GithubUrl)
			If($chk) {
				$seg = $this.getGitSegmentsFromUrl($GithubUrl)
				$this.setPropertyFromSegments($seg)
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
	}

	hidden [Array]getGitSegmentsFromUrl([String]$GithubUrl)
	{
		$GithubUrlObj = [System.Uri]::new($GithubUrl)
		$arr = $GithubUrlObj.Segments
		
		#trim last slash
		For ($x = 0; $x -lt $arr.Count; $x++)
		{
			$arr[$x] = [PathHelpers]::TrimLastSlash($arr[$x])
		}

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
		$dli = $SegmentsArray.Count
	
		$this.Author = $SegmentsArray[$ai]
		$this.Repo = $SegmentsArray[$ri]
		$this.Branch = $SegmentsArray[$bi]
		$this.RootDirPath = [System.String]::Join("", $SegmentsArray, $dfi, ($dli - $dfi))
	}
}

Class GitFolder
{
    [String]$Name
    [String]$DirPath
	[Array]$GitFileList

	GitFolder([String]$GitFolderUrl) {
		$this.DirPath = $GitFolderUrl
		$this.Name = Split-Path -Path $GitFolderUrl -Leaf
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

Class GitDownloader
{
	hidden[GlobalGitData]$_gdo
	hidden[String]$_tempPath = ""

	GitDownloader([String]$GithubUrl, [String]$TempFolderPath)
	{
		$GlobalGitData =[GlobalGitData]::new($GithubUrl)
		$this._gdo = $GlobalGitData
		$chk = [PathHelpers]::ValidateFolderPath($TempFolderPath)
		If($chk)
		{
			$this._tempPath = [PathHelpers]::TrimLastSlash($TempFolderPath)
			
		}
		Else
		{
			Throw "Bad temp folder path"
		}
	}

	Start()
	{
		#First GitFolder object (gff) by gdo.RootDirPath
		$gff = [GitFolder]::new($this._gdo.RootDirPath)
		
		#gff into array and recursion start
		$gffArray = @($gff)
		$this.recursionStart($gffArray)
	}

	hidden recursionStart([Array]$GitFolderList)
	{
		$c = $GitFolderList.Count
		$jsonFolderMap = $null
		$folderMap = $null

		#iteration through GitFolderList items
		For ($x = 0; $x -lt $c; $x++)
		{
			#Folder Under Scan (FUS)
			[GitFolder]$thisFolder = $GitFolderList[$x]
			
			#retrieve FUS map by github.com via Public API
			$folderMap = $this.getFolderContent($thisFolder)

			#instance new array of GitFolder objects (nfol)
			$newGitFolderList = [Array]::CreateInstance([GitFolder], 0)

			#instance new array of GitFile objects (nfil)
			$newGitFileList = [Array]::CreateInstance([GitFile], 0)
		
			#iterate through FUS items
			Foreach ($item in $folderMap)
			{
				switch ($item.type)
				{
					#if item is folder, add it to the nfol (see >recursion<)
					'dir'
					{
						$newFld = [GitFolder]::new($item.Path)
						$newGitFolderList += $newFld
					}

					#if item is file, add it to the nfil
					'file'
					{
						$newFile = [GitFile]::new($item.name, $item.Path, $item.download_url, $item.size )
						$newGitFileList += $newFile
					}
				}
			}

			#add files list founded to GitFileList property of GitFolder object
			If($($newGitFileList.Count) -gt 0)
			{
				$thisFolder.GitFileList = $newGitFileList
			}
		
			#>recursion< if other folders in this folder
			If($($newGitFolderList.Count) -gt 0)
			{
				$this.recursionStart($newGitFolderList)
			}
		}

		#program come to this statement only all recursions are made
		#download all files in FUS
		If($($thisFolder.GitFileList) -ne $null){
			If($($thisFolder.GitFileList.Count) -gt 0){
				$this.startFilesDownload($thisFolder)
			}
		}
	}

	#This method use public Github API
	hidden[Object]getFolderContent([GitFolder]$GitFolder)
	{
		<#
		Docs:
			"This API has an upper limit of 1,000 files for a directory. If you need to retrieve more files, use the Git Trees API.
			This API supports files up to 1 megabyte in size." - https://developer.github.com/v3/repos/contents/
		Schema:
			/repos/:owner/:repo/contents/:path?ref=:branch
		#>

		$header = @{'responseType' = 'arraybuffer'}
		$sep = '/'
		$pre = 'https://api.github.com/repos/'
		$mid = 'contents'
		$post = '?ref='
		$pre = $pre + $this._gdo.Author + $sep + $this._gdo.Repo + $sep + $mid + $sep
		$post = $post + $this._gdo.Branch
		$url = $pre + $GitFolder.DirPath + $post
		
		$resp = Invoke-Webrequest -Uri $url -Method Get -Headers ($header)
		$out = ConvertFrom-Json -InputObject ($resp.Content)
		Return $out
	}

	hidden startFilesDownload([GitFolder]$GitFolder)
	{
		#retrieve files list
		$gfl = $GitFolder.GitFileList
		
		$c = $gfl.Count
		$gdo = $this._gdo
	
		#iterate through files list
		For ($x = 0; $x -lt $c; $x++)
		{
			#retrieve GitFile
			$f = $gfl[$x]
			
			#retrieve GitFile data
			$fn = $f.Name
			$fp = $f.Path

			#local file path
			$lfp = $this._tempPath + '\' + $fp
			
			#local folder path
			$path = Split-Path -Path $lfp -Parent
			
			#linux to windows slash
			$path -replace '\/', '\'

			[PathHelpers]::NewFolder($path)
					
			Start-BitsTransfer -Source $f.Url -Destination "$path\$fn"
		}
}
}

Class PathHelpers
{
	static[Bool]ValidateFolderPath([String]$TempFolderPath)
	{
		$chk = Test-Path -Path $TempFolderPath -IsValid
		Return $chk
	}

	static[String]TrimLastSlash([String]$Path)
	{
		If($Path.EndsWith('/'))
		{
			$ix = $Path.Length - 1
			$out = $Path.Remove($ix)
		}
		Else
		{
			$out = $Path
		}

		Return $out
	}

	static NewFolder([String]$Path)
	{
		$chk = Test-Path -Path $Path -PathType Container
	
		If(-not($chk))
		{
			New-Item -Path $Path -ItemType Directory
		}
	}
}


$gd = [GitDownloader]::new("https://github.com/RobDesideri/GitDownFolder/tree/develop/src", "d:\tmp\10000")
$gd.Start()