$global:Tst_Data_GoodUrl = "https://google.com"

$global:Tst_Data_BadUrl = "httpgooglecom"

$global:Tst_Data_NotUrl = [PSCustomObject]::new()

$global:Tst_Data_GoodSystemUrl = [System.Uri]::new("https://google.com")

$global:Tst_Data_BadSystemUrl = [System.Uri]::new("/foo/tst", [System.UriKind]::RelativeOrAbsolute)

$global:Tst_Data_NotSystemUrl = [PSCustomObject]::new()