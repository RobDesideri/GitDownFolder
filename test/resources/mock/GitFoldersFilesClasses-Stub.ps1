$global:Tst_Stub_ValidateGithubUrl = @{
	Stub = {
		$arr = [System.Array]::CreateInstance([String], 8)
		$arr[0] = "author"
		$arr[1] = "repo"
		$arr[2]= ""
		$arr[3] = "branch"
		$arr[4] = "dirpathroot"
		$arr[5] = "dirpath1"
		$arr[6] = "dirpath2"
		$arr[7] = "dirpath3"
		Return $arr
	}

	_data = @{
		url = 'https://github.com/' + 'author' + '/' + 'repo' + '/' + 'tree' + '/' + 'branch' + '/' + 'dirpathroot/dirpath1/dirpath2/dirpath3'
	}

	_return = @{
		0 = "author"
		1 = "repo"
		2 = ""
		3 = "branch"
		4 = "dirpathroot/dirpath1/dirpath2/dirpath3"
	}

	
}

$global:Tst_Stub_GetSingleton = @{
	Stub = {
		$a = "I'm a Signleton"
		Return $a
	}

	_return = "I'm a Signleton"
}

$global:Tst_Stub_NewObjectOfTypeGitFolder = {
	$r = & $global:Tst_Mock_GitFolder
	Return $r
}

$global:Tst_Stub_GetGlobalGitDataObject = {
	$r = & $global:Tst_Mock_GlobalGitDataObject
	Return $r
}

<#
Note: use data from $global:Tst_Data_GoodGithubUrl
#>
$global:Tst_Stub_GetGitSegmentsFromUrl = {

	#data
	$md = $global:Tst_Data_GoodGithubUrl["MetaData"]

	#constants
	$ai = $global:GithubUrlTemplate["AuthorSegmentIndex"]
	$ri = $global:GithubUrlTemplate["RepoSegmentIndex"]
	$bi = $global:GithubUrlTemplate["BranchSegmentIndex"]
	$di = $global:GithubUrlTemplate["DirPathSegmentFirstIndex"]

	$arr = @(0..$di)

	$arr[$ai] = $md["AuthorInUrl"]
	$arr[$ri] = $md["RepoInUrl"]
	$arr[$bi] = $md["BranchInUrl"]
	$arr[$di] = $md["DirPathInUrl"]

	Return $arr
}


$global:Tst_Stub_validateGithubUrlTrue = {
	Return $True
}

$global:Tst_Stub_getGitSegmentsFromUrl = {
	$a = @()
	Return $a
}

$global:Tst_Stub_setProprertyFromSegments = {
	Return $Null
}

Class SingletonStub : Singleton
{
	$chk = $null

	NewSingleton($t){
		$this.chk = $t
	}
}


$global:Get_SingletonStub = {
	$m = [SingletonStub]::new()
	Return $m
}

