Function Get-SystemUriFromUrl ([string]$Url)
{
	$uk = [System.UriKind]::Absolute
	$chk = [System.Uri]::IsWellFormedUriString($Url, $uk)
	If($chk)
	{
		$uri = ($Url -as [System.Uri])
		Return $uri
	}
	Else
	{
		Throw "Bad-formed url error"
	}
}