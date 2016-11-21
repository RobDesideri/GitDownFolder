# Import testing helpers dependencies
& "$PSScriptRoot\InstallTestingDepends.ps1"
Import-Module "$PSScriptRoot\lib\PowerShellTestingHelpers"
# Import all private functions for tests.
$Private  = @( Get-ChildItem -Path $PSScriptRoot\..\src\script\private\*.ps1 -ErrorAction SilentlyContinue )
Foreach($import in @($Private))
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

Function New-CustomObject
{
	$a = New-Object -TypeName PSCustomObject
	Return $a
}

Function New-CustomTypedObject ($TypeName)
{
	$a = New-Object -TypeName $TypeName
	Return $a
}

#Test begin!

Describe "GitDownFolder Private Functions" {
	Context "Function return expected value / type" {
		$co = New-CustomObject
		It "Should Return specific object" {
			Mock -CommandName Get-Singleton -MockWith {Return $co }
			Get-GlobalGitDataObject | Should Be $co
		}
		It "Should return a System.Uri type object"{
			$url = "https://google.com"
			Get-SystemUriFromUrl -Url $url | Should BeOfType System.Uri
		}
		It "" {
			[System.Uri]::new("")
			New-GlobalGitDataObject -UrlToParse
		}
	}
}