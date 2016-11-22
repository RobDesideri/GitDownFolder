Function Move-GitFolder($DestPath, $KeepRootFolderPath)
{
	$gdo = Get-GlobalGitDataObject
	$tf = $gdo.TempFolder
	If ($KeepRootFolderPath -eq $False)
	{
		$fdp = $gdo.FirstDirPath
		$sp = "$tf\$fdp\*"
	}
	Else
	{
		$sp = "$tf\*"
	}
	
	Move-Item -Path $sp -Destination $DestPath
	Remove-Item -Path $tf -Force -Recurse
}