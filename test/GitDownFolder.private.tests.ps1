# Import testing helpers dependencies
& "$PSScriptRoot\InstallTestingDepends.ps1"
Import-Module "$PSScriptRoot\lib\PowerShellTestingHelpers"
# Import all private functions for tests.
$Private  = @( Get-ChildItem -Path $PSScriptRoot\..\src\script\private\*.ps1 -ErrorAction SilentlyContinue )
Foreach($import in @($Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Function New-CustomObject
{
	$a = New-Object -TypeName PSCustomObject
	Return $a
}

Function New-CustomTypedObject ($TypeName)
{
	$a = New-Object -TypeName $TypeName
	Return $a
}

Set-Variable -Name TstUrlPrePrefix -Value 'https://api.github.com/repos/' -Scope script
Set-Variable -Name TstUrlPrePostfix -Value '?ref=' -Scope script
Set-Variable -Name TstUrlPostPrefix -Value 'contents' -Scope script

#Test begin!

Describe "Get-GlobalGitDataObject" {
	Context "Return expected type" {
		$co = "I'm a Singleton"
		It "Get-GlobalGitDataObject should Return specific object" {
			Mock -CommandName Get-Singleton -MockWith {Return $co}
			Get-GlobalGitDataObject | Should Be "I'm a Singleton"
		}
	}
}
Describe "Get-SystemUriFromUrl" {
	Context "Well-formed url" {
		$url = "https://google.com"
		It "Should return a System.Uri type object"{
			Get-SystemUriFromUrl -Url $url | Should BeOfType System.Uri
		}
	}
	Context "Bad-formed url" {
		$url = "ht"
		It "Should throw error in case of bad url"{
			try
			{
				Get-SystemUriFromUrl -Url $url
			}
			catch [System.Exception]
			{
				$m = $error[0]
			}
			finally
			{
				$m | Should Be "Bad-formed url error" 
			}
		}
	}
}
Describe "New-GlobalGitDataObject" {
	Context "Good parameters"{
			$tmp = "TEMP-FOLDER"
			$url = [System.Uri]::new("https://github.com/RobDesideri/GitDownFolder/tree/develop/test/resources")
			$gdo = New-GlobalGitDataObject -UrlToParse $url -TempFolder $tmp
		It "Should return a GlobalGitDataObject type object" {
			$gdo.GetType() | Should Be GlobalGitDataObject
		}
		It "return UrlPrePrefix" {
			$gdo.UrlPrePrefix | Should Be $script:TstUrlPrePrefix
		}
		It "return UrlPrePostfix" {
			$gdo.UrlPrePostfix | Should Be $script:TstUrlPrePostfix
		}
		It "return UrlPostPrefix" {
			$gdo.UrlPostPrefix | Should Be $script:TstUrlPostPrefix
		}
		It "return Author" {
			$gdo.Author | Should Be 'RobDesideri'
		}
		It "return Repo" {
			$gdo.Repo | Should Be 'GitDownFolder'
		}
		It "return Branch" {
			$gdo.Branch | Should Be 'develop'
		}
		It "return FirstDirPath" {
			$gdo.FirstDirPath | Should Be 'test/resources'
		}
		It "return TempFolder" {
			$gdo.TempFolder | Should Be $tmp
		}
	}
}
Describe "New-GitFolder" {
	Context "Good parameters" {
		$fn = "a random name"
		$dp = "directory"
		$fkObj = New-Object -TypeName PSCustomObject
		Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "UrlPrePrefix" -Value $script:TstUrlPrePrefix
		Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "UrlPostPrefix" -Value $script:TstUrlPostPrefix
		Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "UrlPrePostfix" -Value $script:TstUrlPrePostfix 
		Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "Author" -Value "TESTER"
		Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "Repo" -Value "REPO"
		Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "Branch" -Value "BRANCH"
		Mock -CommandName Get-GlobalGitDataObject -MockWith {Return $fkObj}
		$a = New-GitFolder -FolderName $fn -DirPath $dp
		It "Should be a GitFolder type" {
			$a.GetType() | Should Be GitFolder
		}
		It "Return the GitFolder Name" {
			$a.Name | Should Be $fn
		}
		It "Return the GitFolder UrlPrefix" {
			$st = $script:TstUrlPrePrefix + $fkObj.Author + '/' + $fkObj.Repo + '/' + $script:TstUrlPostPrefix + '/'
			$a.UrlPrefix | Should Be $st
		}
		It "Return the GitFolder UrlPostfix" {
			$st = $script:TstUrlPrePostfix + $fkObj.Branch
			$a.UrlPostfix | Should Be $st
		}
		It "Return the GitFolder DirPath" {
			$a.DirPath | Should Be $dp
		}
		It "Return the GitFolder GitFileList" {
			$a.GitFileList | Should Be $null
		}
	}
}
Describe "New-GitFile" {
	Context "Good parameters" {
		$FileName = "a name"
		$FilePath = "a path"
		$FileUrl = "a url"
		$FileSize = 1000
		$a = New-GitFile -FileName $FileName -FilePath $FilePath -FileUrl $FileUrl -FileSize $FileSize
		It "Should be a GitFile type" {
			$a.GetType() | Should Be GitFile
		}
		It "Return FileName" {
			$a.Name | Should Be $FileName
		}
		It "Return FilePath" {
			$a.Path | Should Be $FilePath
		}
		It "Return FileUrl" {
			$a.Url | Should Be $FileUrl
		}
		It "Return FileSize" {
			$a.Size | Should Be $FileSize
		}
	}
}
Describe "New-GitFolderList" {
	It "Should return a GitFolderList type" {
		$a = New-GitFolderList
		$a.GetType() | Should Be GitFolderList
	}
}
Describe "New-GitFileList" {
	It "Should return a GitFileList type" {
		$a = New-GitFileList
		$a.GetType() | Should Be GitFileList
	}
}