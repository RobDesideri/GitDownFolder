# Import testing resources
& "$PSScriptRoot\SharedSetup.ps1"
$fp = "$PSScriptRoot\..\src\script\public\*.ps1"
$fpCollection = @( Get-ChildItem -Path $fp -ErrorAction SilentlyContinue )
Foreach($import in @($fpCollection))
{
	Try
	{
		. $import.FullName
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