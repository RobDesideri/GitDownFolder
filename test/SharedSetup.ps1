#Check dependencies
& "$PSScriptRoot\InstallTestingDepends.ps1"

#Import PowerShellTestingHelpers module
Import-Module "$PSScriptRoot\lib\PowerShellTestingHelpers" -Global

function import ($FilePath)
{
    $fpCollection = @( Get-ChildItem -Path $FilePath -ErrorAction SilentlyContinue )
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
}

#Import data files
import -FilePath "$PSScriptRoot\resources\data\*.ps1"
import -FilePath "$PSScriptRoot\resources\mock\*.ps1"
import -FilePath "$PSScriptRoot\resources\constant\*.ps1"