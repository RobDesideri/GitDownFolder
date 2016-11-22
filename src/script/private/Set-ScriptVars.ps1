Function Set-ScriptVars
{
	param(
		[Parameter(Mandatory=$True)]
		[System.Uri]$UrlAsObject
	)

	$chk = Validate-AbsoluteUriBySystemUri -SysUri $UrlAsObject
	
	If($chk) 
	{
		$tmpFld = New-TemporaryFolder
		New-GlobalGitDataObject -UrlToParse $UrlAsObject -TempFolder $tmpFld
	}
	Else
	{
		Throw "Bad Url"
	}
}