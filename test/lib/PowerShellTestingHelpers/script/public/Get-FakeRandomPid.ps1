Function Get-FakeRandomPid
{
	$r = New-Object -TypeName System.Random
	[int]$i = 100
	Return $r.Next($i)
}