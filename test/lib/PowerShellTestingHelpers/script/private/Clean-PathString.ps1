Function Clean-PathString ([String]$PathString)
{
	$ps = $PathString.ToString()
    
	If($ps.StartsWith("/"))
	{
		$ps = $ps.Substring(1)
	}

	If($ps.EndsWith("/"))
	{
		$ps = $ps.Substring(0,($ps.Length - 1))
	} 
	
	Return $ps
}