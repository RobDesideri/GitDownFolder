try
{
	Save-Module -Name PSDepend -Path "$PSScriptRoot\lib" -Force
    
}
catch [System.Management.Automation.CommandNotFoundException]
{
    Write-Host "PowerShellGet (https://blogs.msdn.microsoft.com/mvpawardprogram/2014/10/06/package-management-for-powershell-modules-with-powershellget/) must be installed on your system first"
}
finally
{
}