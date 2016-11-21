Function Get-SystemUriFromUrl ([string]$Url)
{
	$uri = ($url -as [System.Uri])
	Return $uri
}