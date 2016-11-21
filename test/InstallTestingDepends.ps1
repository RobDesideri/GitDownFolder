$tp = Test-Path -Path "$PSScriptRoot\lib"
if(-not $tp)
{
   New-Item -Path $PSScriptRoot -Name lib -ItemType Directory
}
Import-Module "$PSScriptRoot\..\lib\PSDepend"
Invoke-PSDepend -Path $PSScriptRoot\TestDepends.psd1 -Target $PSScriptRoot\lib -Install