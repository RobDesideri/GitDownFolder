Function Get-FakeProcessList ([string]$prName)
{
    $p = New-Object -TypeName System.Diagnostics.Process
	$p.ProcessName = $prName
	$p.Id = Get-RandomId
}