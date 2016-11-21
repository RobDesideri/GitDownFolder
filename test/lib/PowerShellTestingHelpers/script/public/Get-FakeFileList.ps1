Function Get-FakeFileList([string[]]$names)
{
	$names | ForEach {
	    [PSCustomObject]@{FullName = "d:\foo\bar\$_"; Name = $_; }
	}
} 