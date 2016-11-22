Function New-Folder {
	param(
		[Parameter(Mandatory=$True)]
		[String]$Path
	)

	$chk = Test-Path -Path $Path -PathType Container
	If(-not($chk)){
		New-Item -Path $Path -ItemType Directory
	}
}