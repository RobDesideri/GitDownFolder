param(
    [Switch]$TestPublicScripts,
    [Switch]$TestPrivateScripts
)

$sc = $False

If($TestPublicScripts)
{
    $pp = "public"
    $sc = $True
}

If($TestPrivateScripts)
{
    $pp = "private"
    $sc = $True
}

& "$PSScriptRoot\InstallTestingDepends.ps1"
Import-Module "$PSScriptRoot\lib\PowerShellTestingHelpers"
Import-FilesForTesting -FilesPath "$PSScriptRoot\data"

If ($sc) {
    Import-FilesForTesting -FilesPath "$PSScriptRoot\..\src\script\$pp"
} 