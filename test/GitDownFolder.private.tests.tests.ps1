# Test custom helpers functions defined in GitDownFolder.private.tests for tests execution.
. .\GitDownFolder.private.tests.ps1

Describe "New-CustomObject" {
		It "Runs" {
			New-CustomObject | Should BeOfType PSCustomObject
	}
}

Describe "New-CustomTypedObject" {
	Context "Good parameter" {
		$t = "System.String"
		It "Should return an object of specified type" {
			New-CustomTypedObject -TypeName $t | Should BeOfType $t
		}
	}

	Context "Bad parameter" {
		$t = "nonesiste"
		It "Should throw an error" {
			Try
			{
				New-CustomTypedObject -TypeName $t | Should BeOfType $t
			}
			Catch
			{
				$chk = $True
			}
			Finally
			{
			}
			$chk | Should Be $True
		}
	}
}

Describe "New-FakeGdo" {
	It "Should return a PSCustomObject of 8 members" {
		[PSCustomObject]$o = New-FakeGdo
		$o.Members.Where({$_.MemberType -eq "NoteProperty"}).Count() | Should Be 8
		$o.GetType() | Should BeOfType PSCustomObject
	}
}

Describe "Get-UriFromString" {
	Context "Good parameter" {
		$u = "https:\\google.com"
		It "Should return a System.Uri object" {
			$r = Get-UriFromString -UriString $u
			$r | Should BeOfType System.Uri
		}
	}
	Context "Bad parameter" {
		It "Should throw an error" {
			$u = ""
			Try
			{
				$r = Get-UriFromString -UriString $u
			}
			Catch
			{
				$chk = $true
			}
			Finally
			{
			}
			$chk | Should Be $True
		}
	}
}

Describe "New-FakeGitUri" {

}