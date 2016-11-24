Function Import-TestFiles($FilesPathCollection)
{
    Foreach($import in @($FilesPathCollection))
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
}