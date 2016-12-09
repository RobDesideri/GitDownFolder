$global:Tst_Mock_GitFileList = {
	
	Class GitFileList : PSCustomObject {}

	$r = [GitFileList]::new()
	
	Return [GitFileList]$r
}

$global:Tst_Mock_GitFolder = {
	
	Class GitFolder : PSCustomObject {}

	$r = [GitFolder]::new()
	
	$r | Add-Member NoteProperty Name ""
	$r | Add-Member NoteProperty UrlPrefix ""
	$r | Add-Member NoteProperty UrlPostfix ""
	$r | Add-Member NoteProperty DirPath ""
	$r | Add-Member NoteProperty "GitFileList" -Value (& $global:Tst_Mock_GitFileList)
	
	Return [GitFolder]$r
}

$global:Tst_Mock_GlobalGitDataObject = {
<#
Use:
	+ the $global:Tst_Data_GoodGithubUrl (meta)data
	+ the $global:Tst_Data_TempFolder data
#>
	
	Class GlobalGitDataObject : PSCustomObject {}
	
	$r = [GlobalGitDataObject]::new()
	$data = $global:Tst_Data_GoodGithubUrl["MetaData"]

	$r | Add-Member NoteProperty UrlPrePrefix $global:GithubUrlTemplate["UrlPrePrefixForDownload"]
	$r | Add-Member NoteProperty UrlPrePostfix $global:GithubUrlTemplate["UrlPrePostfixForDownload"]
	$r | Add-Member NoteProperty UrlPostPrefix $global:GithubUrlTemplate["UrlPostPrefixForDownload"]
	$r | Add-Member NoteProperty Author $data["AuthorInUrl"]
	$r | Add-Member NoteProperty Repo $data["RepoInUrl"]
	$r | Add-Member NoteProperty Branch $data["BranchInUrl"]
	$r | Add-Member NoteProperty FirstDirPath $data["DirPathInUrl"]
	$r | Add-Member NoteProperty TempFolder $global:Tst_Data_TempFolder

	Return [GlobalGitDataObject]$r
}

$global:Tst_Mock_GitSegmentsFromUrl
