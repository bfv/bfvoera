using bfv.lib.io.FileSystemInfo.

class bfv.lib.io.FileInfo inherits FileSystemInfo final:
  
  define public property DirectoryName as character no-undo get. 
    private set.
  define public property IsReadOnly    as logical   no-undo get. 
    private set.
  define public property FileSize      as int64     no-undo get. 
    private set.
  define public property MIMEType      as character no-undo get. 
    private set.
  
  
  constructor public FileInfo(cfilename as character):
    
    super(cfilename).
    
    file-info:file-name = cfilename.
    this-object:Exists = (
      index(file-info:file-type, "F") > 0) and (file-info:file-type <> ? and file-info:file-type <> "").
    
    fetchFileSystemInfo().
    
    DirectoryName = substring(this-object:FullName, 1, (r-index(this-object:FullName, fileSystemSeparator))).
    IsReadOnly    = (
      index(file-info:file-type, "W") = 0). 
    FileSize      = file-info:file-size.
    
    case Extension:
      when "bmp" then
        MIMEType = "image/bmp".
      when "doc" or
      when "dot" then
        MIMEType = "application/msword".
      when "htm" or
      when "html" then
        MIMEType = "text/html".
      when "jpg" or
      when "jpeg" then
        MIMEType = "image/jpeg".
      when "ico" then
        MIMEType = "image/x-icon".
      when "pdf" then
        MIMEType = "application/pdf".
      when "rtf" then
        MIMEType = "application/rtf".
      when "tif" or
      when "tiff" then
        MIMEType = "image/tiff".
      when "txt" then
        MIMEType = "text/plain".
      when "xml" then
        MIMEType = "text/xml".
      when "xla" or
      when "xlc" or
      when "xlm" or
      when "xls" or
      when "xlt" or
      when "xlw" then
        MIMEType = "application/vnd.ms-excel".
      when "z" then
        MIMEType = "application/x-compress".
      when "zip" then
        MIMEType = "application/zip".
      otherwise
        MIMEType = "application/octet-stream".
    end case. /* Extension */
       
  end.
  

  method public override character ToString():
    
    return 
      super:ToString() + 
      "~nDirectoryName: " + subst("&1", DirectoryName) + 
      "~nIsReadOnly: " + subst("&1", string(IsReadOnly, "true/false")) +
      "~nFileSize: " + subst("&1", string(FileSize))
      .
      
  end method. 
  
  
  
end class.

