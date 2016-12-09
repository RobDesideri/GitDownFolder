$global:Tst_Stub_ReturnTrue = {
	Return $True
}

$global:Tst_Stub_ReturnFalse = {
	Return $False
}

$global:Tst_Stub_ReturnPSCustomObject = {
	$a = [PSCustomObject]::new()
	Return $a
}

$global:Tst_Stub_ReturnPassedData = {
	param($Data)
	Return $Data
}