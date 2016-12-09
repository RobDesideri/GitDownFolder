#define $_author and $_repo before call this pattern!
$global:Tst_Constant_GitFolderUrlPrefixPattern = {
		$global:Tst_Constant_UrlPrePrefix + $_author + '/' + $_repo + '/' + $global:Tst_Constant_UrlPostPrefix + '/'
}

#define $_branch before call this pattern!
$global:Tst_Constant_GitFolderUrlPostfixPattern = {
		$global:Tst_Constant_UrlPrePostfix + $_branch
}