Function Validate-AbsoluteUriByString
{
	param(
		[Parameter(Mandatory=$True)]
		[String]$Uri
	)
	$uk = [System.UriKind]::Absolute
	$chk = [System.Uri]::IsWellFormedUriString($Uri, $uk)
	Return $chk
}

Function Validate-AbsoluteUriBySystemUri
{
	param(
		[Parameter(Mandatory=$True)]
		[System.Uri]$SysUri
	)
	
	try
	{
		$Uri = $SysUri.ToString()
	}
	catch [System.Exception]
	{
		Return $False
	}
	finally
	{
	}

	$uk = [System.UriKind]::Absolute
	$chk = [System.Uri]::IsWellFormedUriString($Uri, $uk)
	
	Return $chk
}