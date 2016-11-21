Function Get-GlobalGitDataObject()
{
	$gdo = Get-Singleton -ObjectClassName "GlobalGitDataObject"
	Return $gdo
}