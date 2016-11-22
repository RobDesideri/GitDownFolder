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

Set-Variable -Name TstUrlPrePrefix -Value 'https://api.github.com/repos/' -Scope script
Set-Variable -Name TstUrlPrePostfix -Value '?ref=' -Scope script
Set-Variable -Name TstUrlPostPrefix -Value 'contents' -Scope script

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

Function New-FakeGdo ()
{
	$fkObj = New-Object -TypeName PSCustomObject
	Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "UrlPrePrefix" -Value $script:TstUrlPrePrefix
	Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "UrlPostPrefix" -Value $script:TstUrlPostPrefix
	Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "UrlPrePostfix" -Value $script:TstUrlPrePostfix 
	Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "Author" -Value "TESTER"
	Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "Repo" -Value "REPO"
	Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "Branch" -Value "BRANCH"
	Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "TempFolder" -Value "A:\TEMP\FOLDER\PATH"
	Add-Member -InputObject $fkObj -MemberType NoteProperty -Name "FirstDirPath" -Value "imfirstdirpath"
	Return $fkObj
}

Function New-FakeUri ()
{
	$url = [System.Uri]::new("https://github.com/RobDesideri/GitDownFolder/tree/develop/test/resources")
	Return $url
}

#Test begin!

Describe "Validate-AbsoluteUriByString" {
	Context "Good Uri" {
		$uri = "https://google.com"
		It "Should return True" {
			Validate-AbsoluteUriByString -Uri $uri |Should Be $True
		}
	}
	Context "Bad Uri" {
		$uri = "httpgooglecom"
		It "Should return False" {
			Validate-AbsoluteUriByString -Uri $uri | Should Be $False
		}
	}
}
Describe "Validate-AbsoluteUriBySystemUri" {
	Context "Good Uri" {
		$uri = New-FakeUri
		It "Should return True" {
			Validate-AbsoluteUriBySystemUri -SysUri $uri |Should Be $True
		}
	}
	Context "Bad Uri" {
		$uri = ""
		It "Should return False" {
			Validate-AbsoluteUriBySystemUri -SysUri $uri | Should Be $False
		}
	}
}
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

#GitFoldersFilesClasses.ps1 <
Describe "New-GlobalGitDataObject" {
	Context "Good parameters"{
			$tmp = "TEMP-FOLDER"
			$url = New-FakeUri
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
		$fkObj = New-FakeGdo
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
#>

Describe "Move-GitFolder" {
	$fk = New-FakeGdo
	$t = $fk.TempFolder
	$r = $fk.FirstDirPath
	$d = "foo"
	Context "Keep root folder" {
		It "Should move folder and delete temp folder" {
			$t = $fk.TempFolder
			$r = $fk.FirstDirPath
			Mock -CommandName Move-Item -MockWith {} -Verifiable -ParameterFilter {$Path.StartsWith("$t") -and (-not($Path.EndsWith("$r" + '\*'))) -and ($Destination -eq $d)}
			Mock -CommandName Remove-Item -MockWith {} -Verifiable -ParameterFilter {$Path -eq "$t"}
			# security mocking <
			Mock -CommandName Move-Item -MockWith {}
			Mock -CommandName Remove-Item -MockWith {}
			# >
			Mock Get-GlobalGitDataObject -MockWith {Return $fk}
			Move-GitFolder -DestPath $d -KeepRootFolderPath $true | Assert-VerifiableMocks
		}
	}
	Context "Not keep root folder" {
		It "Should move folder and delete temp folder" {
			Mock -CommandName Move-Item -MockWith {} -Verifiable -ParameterFilter {$Path.StartsWith("$t" + '\' + "$r") -and $Destination -eq $d}
			Mock -CommandName Remove-Item -MockWith {} -Verifiable -ParameterFilter {$Path -eq "$t"}
			# security mocking <
			Mock -CommandName Move-Item -MockWith {}
			Mock -CommandName Remove-Item -MockWith {}
			# >
			Mock Get-GlobalGitDataObject -MockWith {Return $fk}
			Move-GitFolder -DestPath $d -KeepRootFolderPath $False | Assert-VerifiableMocks
		}
	}
}
Describe "New-Folder" {
	Context "Empty parameter path" {
		$p = ""
		Mock -CommandName Test-Path -MockWith {Return $False}
		It "Should throw an error" {
			Mock -CommandName Test-Path -MockWith {}
			Mock -CommandName New-Item -MockWith {}
			try
			{
				New-Folder -Path $p
			}
			catch [System.Exception]
			{
				Write-Host $Error[0]
			}
			finally
			{
				Assert-MockCalled -CommandName New-Item -Exactly 0
				Assert-MockCalled -CommandName Test-Path -Exactly 0
			}
		}
	}
	Context "Folder not exists" {
		Mock -CommandName Test-Path -MockWith {Return $False}
		It "Should create new folder" {
			Mock -CommandName New-Item -MockWith {} -Verifiable
			New-Folder -Path "foo" | Assert-VerifiableMocks
		}
	}
	Context "Folder already exists" {
		Mock -CommandName Test-Path -MockWith {Return $True}
		It "Should to do nothing" {
			Mock -CommandName New-Item -MockWith {}
			New-Folder -Path "foo" | Assert-MockCalled -CommandName New-Item -Exactly 0
		}
	}
}
Describe "New-TemporaryFolder" {
	$tmp = $env:TEMP
	It "Should create new temp folder" {
		$r = New-TemporaryFolder
		$r.StartsWith($tmp) | Should Be $True
	}
}
Describe "Set-ScriptVars" {
	$url = New-FakeUri
	$tmp = "foo"
	Mock -CommandName New-TemporaryFolder -MockWith {Return $tmp} -Verifiable
	Mock -CommandName New-GlobalGitDataObject -MockWith {} -ParameterFilter {$UrlAsObject -eq $url -and $tmpFld -eq $tmp} -Verifiable
	Mock -CommandName New-GlobalGitDataObject -MockWith {}
	Context "Bad parameter" {
		Mock -CommandName Validate-AbsoluteUriBySystemUri -MockWith {Return $False}
		It "Should trow the 'Bad Url' error" {
			try
			{
				Set-ScriptVars -UrlAsObject ""
			}
			catch [System.Exception]
			{
				$Error[0].ToString() | Should Be "Bad Url"
			}
			finally
			{
				Assert-MockCalled -CommandName New-TemporaryFolder -Exactly 0
				Assert-MockCalled -CommandName New-GlobalGitDataObject -Exactly 0
			}
		}
	}
	Context "Good parameter" {
		Mock -CommandName Validate-AbsoluteUriBySystemUri -MockWith {Return $True}
		It "Should call proper factories" {
			Set-ScriptVars -UrlAsObject $url | Assert-VerifiableMocks
		}
	}
}

# Singleton-Handler.ps1 <
Describe "Get-SingletonVarName" {
	It "Should return well-formed singleton var name" {
		$scn = "SCN"
		$r = "__" + $scn + "SingletonLive__"
		Get-SingletonVarName -SingletonClassName $scn | Should Be $r
	}
}
Describe "Test-SingletonIsLive" {
	Mock -CommandName Get-SingletonVarName -MockWith {"SCN"}
	Context "Empty parameter" {
		It "Should trow error" {
			Mock -CommandName Get-Variable -MockWith {}
			try
			{
				Test-SingletonIsLive -SingletonClassName "" 
			}
			catch [System.Exception]
			{
				$c = $True
			}
			finally
			{
				Assert-MockCalled Get-SingletonVarName -Exactly 0
				Assert-MockCalled Get-Variable -Exactly 0
				$c | Should Be $True
			}
		}
	}
	Context "Singleton exists" {
		$a = ""
		Mock -CommandName Get-Variable -MockWith {Return $a}
		It "Should return True" {
			Test-SingletonIsLive -SingletonClassName "Class Name" | Should Be $True
		}
	}
	Context "Singleton not exists" {
		Mock -CommandName Get-Variable -MockWith {}
		It "Should return False" {
			Test-SingletonIsLive -SingletonClassName "Class Name" | Should Be $False
		}
	}
}