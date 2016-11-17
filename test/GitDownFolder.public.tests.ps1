# Import testing helpers dependencies
& "$PSScriptRoot\InstallTestingDepends.ps1"
Import-Module "$PSScriptRoot\lib\PowerShellTestingHelpers"
#Import all public functions for tests.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\..\src\script\public\*.ps1 -ErrorAction SilentlyContinue )
Foreach($import in @($Public))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

#Test begin!

Describe "GitDownFolder Public Functions" {
	Context "Function Exists" {
		It "Should Return" {
		
		}
	}
}