# Import testing resources
& "$PSScriptRoot\SharedSetup.ps1"
$fp = "$PSScriptRoot\..\src\script\private\*.ps1"
$fpCollection = @( Get-ChildItem -Path $fp -ErrorAction SilentlyContinue )
Foreach ($import in $fpCollection)
{
	Try
	{
		. $import.FullName
	}
	Catch
	{
		Write-Error -Message "Failed to import function $($import.fullname): $_"
	}
} 

Set-Variable -Name TstUrlPrePrefix -Value 'https://api.github.com/repos/' -Scope script
Set-Variable -Name TstUrlPrePostfix -Value '?ref=' -Scope script
Set-Variable -Name TstUrlPostPrefix -Value 'contents' -Scope script

Function Invoke-TryCatchTest($PSScriptToExecute) {
	Try
	{
		& $PSScriptToExecute
	}
	Catch [System.Exception]
	{
		$chk = $True
		$er = $Error[0].FullyQualifiedErrorId
		$erMsg = $Error[0]
	}
	Finally
	{
		$resp = @{
			IsThrow = $chk;
			ErrDescription = $er;
			ErrMessage = $erMsg
		}
	}

	Return $resp
}

# Test begin!

# Commons-Validators.ps1
Describe "Validate-AbsoluteUriByString" {
	
	Context "Good Uri" {
		
		#data
		$uri = $global:Tst_Data_GoodUrl
		
		#test
		It "Should return True" {
			Validate-AbsoluteUriByString -Uri $uri |Should Be $True
		}
	}
	
	Context "Bad Uri" {
		
		#data
		$uri = $global:Tst_Data_BadUrl
		
		#test
		It "Should return False" {
			Validate-AbsoluteUriByString -Uri $uri | Should Be $False
		}
	}

	Context "Bad parameter" {
		
		#data
		$uri = $global:Tst_Data_NotUrl
		
		#test
		It "Should throw an error" {
			$r = Invoke-TryCatchTest -PSScriptToExecute {Validate-AbsoluteUriByString -Uri $uri}
			$r.IsThrow | Should Be $True
		}
	}
}
Describe "Validate-AbsoluteUriBySystemUri" {
	
	Context "Good Uri" {

		#data
		$uri = $global:Tst_Data_GoodSystemUrl
		
		#test
		It "Should return True" {
			Validate-AbsoluteUriBySystemUri -SysUri $uri |Should Be $True
		}
	}
	
	Context "Bad Uri" {
		
		#data
		$uri = $global:Tst_Data_BadSystemUrl
		
		#test
		It "Should return False" {
			Validate-AbsoluteUriBySystemUri -SysUri $uri | Should Be $False
		}
	}

	Context "Bad parameter" {

		#data
		$uri = $global:Tst_Data_NotSystemUrl
		
		#test
		It "Should throw an error" {
			$r = Invoke-TryCatchTest -PSScriptToExecute {Validate-AbsoluteUriByString -Uri $uri}
			$r.IsThrow | Should Be $True
		}
	}
}

# Get-SystemUriFromUrl.ps1
Describe "Get-SystemUriFromUrl" {

	Context "Well-formed url" {

		#data
		$url = $global:Tst_Data_GoodUrl
		
		#test
		It "Should return a System.Uri type object"{
			Get-SystemUriFromUrl -Url $url | Should BeOfType System.Uri
		}
	}
	
	Context "Bad-formed url" {

		#data
		$url = $global:Tst_Data_BadUrl
		
		#test
		It "Should throw error in case of bad url"{
			$r = Invoke-TryCatchTest -PSScriptToExecute {Get-SystemUriFromUrl -Url $url}
			$r.IsThrow | Should Be $True
			$r.ErrMessage | Should Be "Bad-formed url error"
		}
	}

	Context "Bad parameter" {

		#data
		$url = $global:Tst_Data_NotUrl
		
		#test
		It "Should throw an error" {
			$r = Invoke-TryCatchTest -PSScriptToExecute {Get-SystemUriFromUrl -Url $url}
			$r.IsThrow | Should Be $True
			$r.ErrDescription | Should Match "ParameterArgumentValidationError"
		}
	}
}

# GitFoldersFilesClasses.ps1

# -> ValidateGithubUrl
Describe "GlobalGitData: constructor" {

	#data
	$goodData = $Tst_Data_GoodGithubUrl

	Context "Good github url" {

		#dummy
		$url = $goodData["GitUrl"]

		#stub
		$stub = & $Get_SingletonStub

		#test
		It "Should create new GlobalGitData singleton object " {
			$r
			$r = [GlobalGitData]::new($url, $stub)
			$stub.chk | Should Not Be $Null
		}
	}

	#data
	$badDataset = $Tst_Data_Dataset_BadGithubUrl

	Context "Bad Github url: not an absolute url" {
		
		#data
		$data = $badDataset["DataSet1"]

		#dummy
		$url = $data["GitUrl"]

		#mock
		Mock Validate-AbsoluteUriBySystemUri $Tst_Stub_ReturnFalse

  		#test
		It "Should throw specific error" {
			$e = Invoke-TryCatchTest -PSScriptToExecute {Validate-GithubUrl -UrlToParse $url}
			$e.ErrMessage | Should Match "is not an absolute url"
		} 
	}

	Context "Bad Github url:not a github url" {
		
		#data
		$data = $badDataset["DataSet2"]

		#dummy
		$url = $data["GitUrl"]

		#mock
		Mock Validate-AbsoluteUriBySystemUri $Tst_Stub_ReturnTrue

  		#test
		It "Should throw specific error" {
			$e = Invoke-TryCatchTest -PSScriptToExecute {Validate-GithubUrl -UrlToParse $url}
			$e.ErrMessage | Should Match "is not a github url"
		} 
	}

	Context "Bad Github url: not a secure http url" {
		
		#data
		$data = $badDataset["DataSet3"]

		#dummy
		$url = $data["GitUrl"]

		#mock
		Mock Validate-AbsoluteUriBySystemUri $Tst_Stub_ReturnTrue

  		#test
		It "Should throw specific error" {
			$e = Invoke-TryCatchTest -PSScriptToExecute {Validate-GithubUrl -UrlToParse $url}
			$e.ErrMessage | Should Match "not a secure http url"
		} 
	}

	Context "Bad Github url: not contains all segments" {
		
		#data
		$data = $badDataset["DataSet4"]

		#dummy
		$url = $data["GitUrl"]

		#mock
		Mock Validate-AbsoluteUriBySystemUri $Tst_Stub_ReturnTrue

  		#test
		It "Should throw specific error" {
			$e = Invoke-TryCatchTest -PSScriptToExecute {Validate-GithubUrl -UrlToParse $url}
			$e.ErrMessage | Should Match "not contains all segments"
		} 
	}
}
Describe "Functional Test: ValidateGithubUrl" {

<#
Purpose:
	Test the correctness of the ValidateGithubUrl function
Functions implied:
	- ValidateGithubUrl
	- Validate-AbsoluteUriBySystemUri
#>

	Context "Good github url" {

		#data
		$goodData = $Tst_Data_GoodGithubUrl

		It "Should return True" {
			ValidateGithubUrl -GithubUrl $goodData["GitUrl"] | Should Be $True				
		}
	}

	Context "Bad url in parameter" {
	
		#dataset
		$badDataset = $Tst_Data_Dataset_BadGithubUrl

		#scripts
		$testExecutionScript = {Return (Invoke-TryCatchTest {Validate-GithubUrl -UrlToParse $badData["GitUrl"]})}

		It "Should throw specific error 1" {
			$badData = $badDataset["DataSet1"]
			$($testExecutionScript).ErrMessage | Should Match "is not an absolute url"
		}

		It "Should throw specific error 2" {
			$badData = $badDataset["DataSet2"]
			$($testExecutionScript).ErrMessage | Should Match "is not a github url"
		}

		It "Should throw specific error 3" {
			$badData = $badDataset["DataSet3"]
			$($testExecutionScript).ErrMessage | Should Match "not a secure http url"
		}

		It "Should throw specific error 4" {
			$badData = $badDataset["DataSet4"]
			$($testExecutionScript).ErrMessage | Should Match "not contains all segments"
		} 
	}
}

# -> GetGitSegmentsFromUrl
Describe "Unit Test: GetGitSegmentsFromUrl" {

	#data
	$goodData = $Tst_Data_GoodGithubUrl

	#constants
	$authorIndex = $global:GithubUrlTemplate["AuthorSegmentIndex"]
	$repoIndex = $global:GithubUrlTemplate["RepoSegmentIndex"]
	$branchIndex = $global:GithubUrlTemplate["BranchSegmentIndex"]
	$dirPathFirstIndex = $global:GithubUrlTemplate["DirPathSegmentFirstIndex"]

	#mock
	Mock ValidateGithubUrl $Tst_Stub_ReturnTrue -Verifiable

	It "Should return an array" {
		GetGitSegmentsFromUrl -GithubUrl $goodData["GitUrl"] | Should BeOfType System.Array
		Assert-VerifiableMocks
	}

	It "Should return an array of segments of passed url" {
		$arr = GetGitSegmentsFromUrl -GithubUrl $goodData["GitUrl"]
		$arr[$authorIndex] | Should Be $goodData["AuthorInUrl"]
		$arr[$repoIndex] | Should Be $goodData["RepoInUrl"]
		$arr[$branchIndex] | Should Be $goodData["BranchInUrl"]
		$arr[$dirPathFirstIndex] | Should Be $goodData["DirPath1"]
		$arr[$dirPathFirstIndex + 1] | Should Be $goodData["DirPath2"]
		$arr[$dirPathFirstIndex + 2] | Should Be $goodData["DirPath3"]
		$arr[$dirPathFirstIndex + 3] | Should Be $goodData["DirPath4"]
		Assert-VerifiableMocks
	}

}
Describe "Functional Test: GetGitSegmentsFromUrl" {
<#
Purpose:
	Test the correctness of the GetGitSegmentsFromUrl function
Functions implied:
	- GetGitSegmentsFromUrl
	- ValidateGithubUrl
	- Validate-AbsoluteUriBySystemUri
#>

	#data
	$goodData = $Tst_Data_GoodGithubUrl

	#constants
	$authorIndex = $global:GithubUrlTemplate["AuthorSegmentIndex"]
	$repoIndex = $global:GithubUrlTemplate["RepoSegmentIndex"]
	$branchIndex = $global:GithubUrlTemplate["BranchSegmentIndex"]
	$dirPathFirstIndex = $global:GithubUrlTemplate["DirPathSegmentFirstIndex"]

	It "Should return an array" {
		GetGitSegmentsFromUrl -GithubUrl $goodData["GitUrl"] | Should BeOfType System.Array
	}

	It "Should return an array of segments of passed url" {
		$arr = GetGitSegmentsFromUrl -GithubUrl $goodData["GitUrl"]
		$arr[$authorIndex] | Should Be $goodData["AuthorInUrl"]
		$arr[$repoIndex] | Should Be $goodData["RepoInUrl"]
		$arr[$branchIndex] | Should Be $goodData["BranchInUrl"]
		$arr[$dirPathFirstIndex] | Should Be $goodData["DirPath1"]
		$arr[$dirPathFirstIndex + 1] | Should Be $goodData["DirPath2"]
		$arr[$dirPathFirstIndex + 2] | Should Be $goodData["DirPath3"]
		$arr[$dirPathFirstIndex + 3] | Should Be $goodData["DirPath4"]
	}

}

# -> New-GlobalGitDataObject
Describe "Unit Test: New-GlobalGitDataObject" {

	#security mock
	Mock New-Singleton {}

	#data
	$goodData = $Tst_Data_GoodGithubUrl
	$tmpFolder = $Tst_Data_TempFolder

	#mock
	Mock Test-Path $Tst_Stub_ReturnTrue
	Mock GetGitSegmentsFromUrl $Tst_Stub_GetGitSegmentsFromUrl
	Mock New-Singleton {}
		
	#mock filter
	$pf = {
		$theType -eq  ("GlobalGitDataObject" -as [Type])
		$parsed[0] -eq $goodData["AuthorInUrl"]
		$parsed[1] -eq $goodData["RepoInUrl"]
		$parsed[2] -eq $goodData["BranchInUrl"]
		$parsed[3] -eq $goodData["DirPathInUrl"]
		$parsed[4] -eq $tmpFolder
	}
		
	#test
	It "Should invoke the New-Singleton function passing a well-formed params array" {

		#mock for verify
		Mock New-Singleton -ParameterFilter $pf -Verifiable

		#execution
		New-GlobalGitDataObject -UrlToParse $goodData["GitUrl"] -TempFolder $tmpFolder

		#assertion
		Assert-VerifiableMocks
	}
}
Describe "Functional Test: New-GlobalGitDataObject" {
<#
Purpose:
	Test the correctness of the New-GlobalGitDataObject function
Functions implied:
	+ Test-Path
	+ GetGitSegmentsFromUrl
	+ ValidateGithubUrl
	+ Validate-AbsoluteUriBySystemUri
	+ New-Singleton
#>

	Context "Good parameters"{

		#data
		$goodData = $Tst_Data_GoodGithubUrl
		$tmpFolder = $Tst_Data_TempFolder

		#mock filter
		$pf = {
			$theType -eq  ("GlobalGitDataObject" -as [Type])
			$parsed[0] -eq $goodData["AuthorInUrl"]
			$parsed[1] -eq $goodData["RepoInUrl"]
			$parsed[2] -eq $goodData["BranchInUrl"]
			$parsed[3] -eq $goodData["DirPathInUrl"]
			$parsed[4] -eq $tmpFolder
		}
		
		#test
		It "Should invoke the New-Singleton function passing a well-formed params array" {

			#mock for verify
			Mock New-Singleton -ParameterFilter $pf -Verifiable

			#execution
			New-GlobalGitDataObject -UrlToParse $goodData["GitUrl"] -TempFolder $tmpFolder

			#assertion
			Assert-VerifiableMocks
		}
	}



	Context "Bad UrlToParse parameter"{

		#dataset
		$badDataset = $Tst_Data_Dataset_BadGithubUrl

		#data
		$goodData = $Tst_Data_GoodGithubUrl
		$goodTmpFolder = $Tst_Data_TempFolder
		$badTmpFolder = $Tst_Data_BadTempFolder

		#scripts
		$testExecutionScript = {Return (Invoke-TryCatchTest {New-GlobalGitDataObject -UrlToParse $url -TempFolder $tmp})}

		#mock for verify
		Mock New-Singleton

		It "Should throw specific error 1" {
			$url = $badDataset["DataSet1"]["GitUrl"]
			$tmp = $goodTmpFolder
			$($testExecutionScript).ErrMessage | Should Match "is not an absolute url"
			Assert-MockCalled New-Singleton -Exactly 0
		}

		It "Should throw specific error 2" {
			$url = $badDataset["DataSet1"]["GitUrl"]
			$tmp = $goodTmpFolder
			$($testExecutionScript).ErrMessage | Should Match "is not a github url"
			Assert-MockCalled New-Singleton -Exactly 0
		}

		It "Should throw specific error 3" {
			$url = $badDataset["DataSet1"]["GitUrl"]
			$tmp = $goodTmpFolder
			$($testExecutionScript).ErrMessage | Should Match "not a secure http url"
			Assert-MockCalled New-Singleton -Exactly 0
		}

		It "Should throw specific error 4" {
			$url = $badDataset["DataSet1"]["GitUrl"]
			$tmp = $goodTmpFolder
			$($testExecutionScript).ErrMessage | Should Match "not contains all segments"
			Assert-MockCalled New-Singleton -Exactly 0
		}

		It "Should throw specific error 5" {
			$url = $goodData["GitUrl"]
			$tmp = $badTmpFolder
			$($testExecutionScript).ErrMessage | Should Match "Bad temp folder path string"
			Assert-MockCalled New-Singleton -Exactly 0
		} 
	}
}

# -> Get-GlobalGitDataObject
Describe "Unit Test: Get-GlobalGitDataObject" {

	Context "Return an object" {

		#stub
		$stub = $Tst_Stub_ReturnPSCustomObject

		#test
		It "Get-GlobalGitDataObject should Return an object" {

			#mock
			Mock -CommandName Get-Singleton -MockWith $stub
			
			#assert
			Get-GlobalGitDataObject | Should Not Be $Null
		}
	}
}

# -> New-GitFolder
Describe "Unit Test: New-GitFolder" {

	Context "Good parameters" {

		# constants
		$urlPrefixTemplate = $global:GithubUrlTemplate["UrlPrefixForDownloadTemplate"]

		#data
		$goodData = $Tst_Data_GoodGithubUrl

		#scripts
		$testExecutionScript = {Return ($a = New-GitFolder -DirPath $goodData["DirPathInUrl"])}

		#mock
		Mock New-Object $Tst_Mock_GitFolder
		Mock Split-Path {Return $goodData["DirPath4"]}
		Mock Get-GlobalGitDataObject $Tst_Mock_GlobalGitDataObject

		It "Should be a GitFolder type" {
			$($testExecutionScript).GetType() | Should Be "GitFolder"
		}

		It "Return the correct Name property in GitFolder object" {
			$($testExecutionScript).Name | Should Be $goodData["DirPath4"]
		}

		It "Return the correct UrlPrefix property in GitFolder object"  {
			$template = $global:GithubUrlTemplate["UrlPrefixForDownloadTemplate"]
			$template["Author"] = $goodData["AuthorInUrl"]
			$template["Repo"] = $goodData["RepoInUrl"]
			$($testExecutionScript).Name | Should BeExactly ([String]::Join("", $template.Values))
		}

		It "Return the correct UrlPostfix property in GitFolder object"  {
			$template = $global:GithubUrlTemplate["UrlPostfixForDownloadTemplate"]
			$template["Branch"] = $goodData["BranchInUrl"]
			$($testExecutionScript).Name | Should BeExactly ([String]::Join("", $template.Values))
		}

		It "Return the correct DirPath property in GitFolder object" {
			$($testExecutionScript).Name | Should Be $goodData["DirPathInUrl"]
		}

		It " Return a Null GitFileList property in GitFolder object" {
			$($testExecutionScript).GitFileList | Should Be $Null
		} 
	}
}




#Describe "New-GitFile" {
#	Context "Good parameters" {
#		$FileName = "a name"
#		$FilePath = "a path"
#		$FileUrl = "a url"
#		$FileSize = 1000
#		$a = New-GitFile -FileName $FileName -FilePath $FilePath -FileUrl $FileUrl -FileSize $FileSize
#		It "Should be a GitFile type" {
#			$a.GetType() | Should Be GitFile
#		}
#		It "Return FileName" {
#			$a.Name | Should Be $FileName
#		}
#		It "Return FilePath" {
#			$a.Path | Should Be $FilePath
#		}
#		It "Return FileUrl" {
#			$a.Url | Should Be $FileUrl
#		}
#		It "Return FileSize" {
#			$a.Size | Should Be $FileSize
#		}
#	}
#}
#Describe "New-GitFolderList" {
#	It "Should return a GitFolderList type" {
#		$a = New-GitFolderList
#		$a.GetType() | Should Be GitFolderList
#	}
#}
#Describe "New-GitFileList" {
#	It "Should return a GitFileList type" {
#		$a = New-GitFileList
#		$a.GetType() | Should Be GitFileList
#	}
#}
##>

#Describe "Move-GitFolder" {
#	$fk = New-FakeGdo
#	$t = $fk.TempFolder
#	$r = $fk.FirstDirPath
#	$d = "foo"
#	Context "Keep root folder" {
#		It "Should move folder and delete temp folder" {
#			$t = $fk.TempFolder
#			$r = $fk.FirstDirPath
#			Mock -CommandName Move-Item -MockWith {} -Verifiable -ParameterFilter {$Path.StartsWith("$t") -and (-not($Path.EndsWith("$r" + '\*'))) -and ($Destination -eq $d)}
#			Mock -CommandName Remove-Item -MockWith {} -Verifiable -ParameterFilter {$Path -eq "$t"}
#			# security mocking <
#			Mock -CommandName Move-Item -MockWith {}
#			Mock -CommandName Remove-Item -MockWith {}
#			# >
#			Mock Get-GlobalGitDataObject -MockWith {Return $fk}
#			Move-GitFolder -DestPath $d -KeepRootFolderPath $true | Assert-VerifiableMocks
#		}
#	}
#	Context "Not keep root folder" {
#		It "Should move folder and delete temp folder" {
#			Mock -CommandName Move-Item -MockWith {} -Verifiable -ParameterFilter {$Path.StartsWith("$t" + '\' + "$r") -and $Destination -eq $d}
#			Mock -CommandName Remove-Item -MockWith {} -Verifiable -ParameterFilter {$Path -eq "$t"}
#			# security mocking <
#			Mock -CommandName Move-Item -MockWith {}
#			Mock -CommandName Remove-Item -MockWith {}
#			# >
#			Mock Get-GlobalGitDataObject -MockWith {Return $fk}
#			Move-GitFolder -DestPath $d -KeepRootFolderPath $False | Assert-VerifiableMocks
#		}
#	}
#}
#Describe "New-Folder" {
#	Context "Empty parameter path" {
#		$p = ""
#		Mock -CommandName Test-Path -MockWith {Return $False}
#		It "Should throw an error" {
#			Mock -CommandName Test-Path -MockWith {}
#			Mock -CommandName New-Item -MockWith {}
#			try
#			{
#				New-Folder -Path $p
#			}
#			catch [System.Exception]
#			{
#				Write-Host $Error[0]
#			}
#			finally
#			{
#				Assert-MockCalled -CommandName New-Item -Exactly 0
#				Assert-MockCalled -CommandName Test-Path -Exactly 0
#			}
#		}
#	}
#	Context "Folder not exists" {
#		Mock -CommandName Test-Path -MockWith {Return $False}
#		It "Should create new folder" {
#			Mock -CommandName New-Item -MockWith {} -Verifiable
#			New-Folder -Path "foo" | Assert-VerifiableMocks
#		}
#	}
#	Context "Folder already exists" {
#		Mock -CommandName Test-Path -MockWith {Return $True}
#		It "Should to do nothing" {
#			Mock -CommandName New-Item -MockWith {}
#			New-Folder -Path "foo" | Assert-MockCalled -CommandName New-Item -Exactly 0
#		}
#	}
#}
#Describe "New-TemporaryFolder" {
#	$tmp = $env:TEMP
#	It "Should create new temp folder" {
#		$r = New-TemporaryFolder
#		$r.StartsWith($tmp) | Should Be $True
#	}
#}
#Describe "Set-ScriptVars" {
#	$url = New-FakeUri
#	$tmp = "foo"
#	Mock -CommandName New-TemporaryFolder -MockWith {Return $tmp} -Verifiable
#	Mock -CommandName New-GlobalGitDataObject -MockWith {} -ParameterFilter {$UrlAsObject -eq $url -and $tmpFld -eq $tmp} -Verifiable
#	Mock -CommandName New-GlobalGitDataObject -MockWith {}
#	Context "Bad parameter" {
#		Mock -CommandName Validate-AbsoluteUriBySystemUri -MockWith {Return $False}
#		It "Should trow the 'Bad Url' error" {
#			try
#			{
#				Set-ScriptVars -UrlAsObject ""
#			}
#			catch [System.Exception]
#			{
#				$Error[0].ToString() | Should Be "Bad Url"
#			}
#			finally
#			{
#				Assert-MockCalled -CommandName New-TemporaryFolder -Exactly 0
#				Assert-MockCalled -CommandName New-GlobalGitDataObject -Exactly 0
#			}
#		}
#	}
#	Context "Good parameter" {
#		Mock -CommandName Validate-AbsoluteUriBySystemUri -MockWith {Return $True}
#		It "Should call proper factories" {
#			Set-ScriptVars -UrlAsObject $url | Assert-VerifiableMocks
#		}
#	}
#}

## Singleton-Handler.ps1 <
#Describe "Get-SingletonVarName" {
#	It "Should return well-formed singleton var name" {
#		$scn = "SCN"
#		$r = "__" + $scn + "SingletonLive__"
#		Get-SingletonVarName -SingletonClassName $scn | Should Be $r
#	}
#}
#Describe "Test-SingletonIsLive" {
#	$ObjectClassName = "ASingletonClass"
#	$SingletonVarName = "TheSingletonVarName"
#	Mock -CommandName Get-SingletonVarName -MockWith {Return $SingletonVarName}
#	Mock -CommandName Get-Variable -MockWith {}
	
#	Context "Singleton exists" {
#		$VarContainingSingletonInstance = "SingletonInstance"
#		Mock -CommandName Get-Variable -ParameterFilter {$sn -eq $SingletonVarName} -MockWith {Return $VarContainingSingletonInstance}
		
#		It "Should return True" {
#			Test-SingletonIsLive -SingletonClassName $ObjectClassName | Should Be $True
#		}
#	}
	
#	Context "Singleton not exists" {
#		$VarContainingSingletonInstance = $null
#		Mock -CommandName Get-Variable -ParameterFilter {$sn = $SingletonVarName} -MockWith {Return $VarContainingSingletonInstance}
#		It "Should return False" {
#			Test-SingletonIsLive -SingletonClassName "Class Name" | Should Be $False
#		}
#	}

#	Context "Bad parameter" {
#		$sct = {Test-SingletonIsLive -SingletonClassName ""}
#		It "Should trow error" {
#			$resp = Invoke-TryCatchTest -PSScriptToExecute $sct
#			$resp.IsThrow | Should Be $True
#			$resp.ErrDescription | Should Match "ParameterArgumentValidationErrorEmptyStringNotAllowed"
#		}
#	}
#}

#Describe "Get-Singleton" {
#	$ObjectClassName = "ASingletonClass"
#	$SingletonVarName = "TheSingletonVarName"
#	Mock -CommandName Get-SingletonVarName -MockWith {Return $SingletonVarName}
#	Mock -CommandName Test-SingletonIsLive -MockWith {}
#	Mock -CommandName Get-Variable -MockWith {}

#	Context "Singleton exists" {
#		$VarContainingSingletonInstance = "SingletonInstance"
#		Mock -CommandName Test-SingletonIsLive -MockWith {Return $True}
#		Mock -CommandName Get-Variable -MockWith {Return $VarContainingSingletonInstance}
#		It "Should return instance of required class" {
#			Get-Singleton | Should Be "SingletonInstance"
#		}
#	}
#	Context "Singleton not exists" {
#		$ObjectClassName = "ASingletonClass"
#		$VarContainingSingletonInstance = $null
#		Mock -CommandName Test-SingletonIsLive -MockWith {Return $False}
#		It "Should return null" {
#			Get-Singleton | Should Be $null
#			Assert-MockCalled -CommandName Get-SingletonVarName -Exactly 0
#			Assert-MockCalled -CommandName Get-Variable -Exactly 0
#		}
#	}
#	Context "Bad parameters" {
#		$ObjectClassName = ""
#		$sct = {Get-Singleton -ObjectClassName $ObjectClassName}
#		It "Should throw an error" {
#			$resp = Invoke-TryCatchTest -PSScriptToExecute $sct
#			$resp.IsThrow | Should Be $True
#		}
#		It "Should not execute other statements" {
#			Invoke-TryCatchTest -PSScriptToExecute $sct
#			Assert-MockCalled -CommandName Test-SingletonIsLive -Exactly 0
#			Assert-MockCalled -CommandName Get-SingletonVarName -Exactly 0
#			Assert-MockCalled -CommandName Get-Variable -Exactly 0
#		}
#	}

#}