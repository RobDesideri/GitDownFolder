Function New-TemporaryFolder()
{
	$tmpDir = [System.IO.Path]::GetTempPath()
	$tmpDir = [System.IO.Path]::Combine($tmpDir, [System.IO.Path]::GetRandomFileName())
	[System.IO.Directory]::CreateDirectory($tmpDir) | Out-Null
	Return $tmpDir
}