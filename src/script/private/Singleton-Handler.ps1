#Singleton Pattern
Function Get-SingletonVarName ($SingletonClassName)
{
    $sn = "__" + $SingletonClassName + "SingletonLive__"
	Return $sn
}
Function Test-SingletonIsLive
{
	param(
		[Parameter(Mandatory=$True)]
		[String]$SingletonClassName
	)
	$sl = $null
	$sn = Get-SingletonVarName -SingletonClassName $SingletonClassName
    $sl = Get-Variable -Name $sn -Scope global -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

	if($sl -eq $null)
	{
		Return $false
	} Else {
		Return $true
	}
}
Function Get-Singleton ($ObjectClassName)
{
	$chk = Test-SingletonIsLive -SingletonClassName $ObjectClassName
	If($chk)
	{
		$svn = Get-SingletonVarName -SingletonClassName $ObjectClassName
		$sg = Get-Variable -Name $svn -ValueOnly -Scope global
		Return $sg
	} Else {
		Return $null
	}
}
Function New-Singleton ($SingletonClass, $ParamArray)
{
	$className = $SingletonClass.Name
	$chk = Test-SingletonIsLive -SingletonClassName $className
	If(-not($chk)){
		[Array]$ob = @()
		$i = 0
		Foreach ($item in $ParamArray)
		{
			$ob += $ParamArray[$i]
			$i++
		}
		$tmpOb = New-Object -TypeName $className -ArgumentList $ob
		$sn = Get-SingletonVarName -SingletonClassName $className
		New-Variable -Name $sn -Scope global -Visibility Private -Value $tmpOb
		Return $sn
	} 
}

Function Remove-Singleton ($ObjectClassName)
{
	$chk = Test-SingletonIsLive -SingletonClassName $ObjectClassName
	If($chk)
	{
		$svn = Get-SingletonVarName -SingletonClassName $ObjectClassName
		Remove-Variable -Name $svn -Force -Scope global
	} Else {
		Throw "Singleton not found"
	}
}