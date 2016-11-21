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
