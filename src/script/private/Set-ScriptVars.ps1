Function Set-ScriptVars($UrlAsObject)
{
	$tmpFld = New-TemporaryFolder
	#$pUrl = Get-ParseGitUrl -Url $Url
	New-GlobalGitDataObject -UrlToParse $UrlAsObject -TempFolder $tmpFld
}