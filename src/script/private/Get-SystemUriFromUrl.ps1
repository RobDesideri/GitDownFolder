Function Get-SystemUriFromUrl ([string]$Url)
{
	$chk = Validate-AbsoluteUriByString -Uri $Url
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