Function Import-FilesForTesting([String]$FilesPath)
{
	$fp = Clean-PathString -PathString $FilesPath
    $fpCollection = @( Get-ChildItem -Path $fp\*.ps1 -ErrorAction SilentlyContinue )
    Import-TestFiles -FilesPathCollection $fpCollection
}