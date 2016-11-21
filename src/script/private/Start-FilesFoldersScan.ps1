Function Start-FilesFoldersScan ([GitFolderList]$GitFolderList)
{
	$rt = @{'responseType' = 'arraybuffer'}
	$c = $GitFolderList.CountFolders()

	$thisFolder = New-Object -TypeName GitFolder
	
	$jsonFolderMap = $null
	$folderMap = $null

	for ($x = 0; $x -lt $c; $x++)
	{
		$thisFolder = $GitFolderList.GetFolder($x)
		[String]$uri = $thisFolder.UrlPrefix + $thisFolder.DirPath + $thisFolder.UrlPostfix
		$resp = Invoke-Webrequest -Uri $uri -Method Get -Headers $rt
		$jsonFolderMap = $resp.Content
		$folderMap = ConvertFrom-Json -InputObject $jsonFolderMap
		#$jsonFolderMap.Dispose()
		$newGitFileList = New-Object -TypeName GitFileList
		$newGitFolderList = New-Object -TypeName GitFolderList
		
		foreach ($item in $folderMap)
		{
			switch ($item.type)
			{
				'dir'
				{
					$newFld = New-GitFolder -FolderName ($item.name) -DirPath ($item.path)
					$newGitFolderList.AddFolder($newFld)
					Remove-Variable -Name newFld -Force
				}
				'file'
				{
					$newFile = New-GitFile -FileName $item.name -FilePath $item.Path -FileUrl $item.download_url -FileSize $item.size
					$newGitFileList.AddFile($newFile)
					Remove-Variable -Name newFile -Force
				}
		}
		}
		If($($newGitFileList.CountFiles()) -gt 0)
		{
			$thisFolder.GitFileList = $newGitFileList
		}
		Remove-Variable -Name newGitFileList -Force
		If($($newGitFolderList.CountFolders()) -gt 0)
		{
			Start-FilesFoldersScan -GitFolderList $newGitFolderList
		}
	}
	If($($thisFolder.GitFileList) -ne $null){
		If($($thisFolder.GitFileList.CountFiles()) -gt 0){
			Start-FilesDownload -GitFolder $thisFolder
		}
	}
}