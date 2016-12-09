$global:Tst_Data_GoodGithubUrl = @{
	GitUrl = [System.Uri]::new('https://github.com/Rob/Prova/tree/dev/this/folder/path/foo')
	AuthorInUrl = "Rob"
	RepoInUrl = "Prova"
	BranchInUrl = "dev"
	DirPathInUrl = "this/folder/path/foo"
	DirPath1 = "this"
	DirPath2 = "folder"
	DirPath3 = "path"
	DirPath4 = "foo"
}

$global:Tst_Data_Dataset_BadGithubUrl = @{

	# Not absolute Uri
	DataSet1 = @{
		GitUrl = [System.Uri]::new('Rob/Prova/tree/dev/this/folder/path/foo', [System.UriKind]::Relative)
	}
	
	#Not a github url
	DataSet2 = @{
		GitUrl = [System.Uri]::new('https://google.com/mail/')
	}

	#Not a secure http url
	DataSet3 = @{
		GitUrl = [System.Uri]::new('http://github.com/Rob/Prova/tree/dev/this/folder/path/foo')
	}

	#Not contains all segments
	DataSet4 = @{
		GitUrl = [System.Uri]::new('http://github.com/Rob/tree/dev/this')
	}

}

$global:Tst_Data_DirPath = @{
	Data = "dir/path/folder"
	Metadata = @{
		FolderName = "folder"
	}
}