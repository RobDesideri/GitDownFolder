Function New-Folder([String]$Path)
{
	$chk = Test-Path -Path $Path -PathType Container
	If(-not($chk)){
		New-Item -Path $Path -ItemType Directory
	}
}