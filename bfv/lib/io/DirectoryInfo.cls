using bfv.lib.io.FileSystemInfo.

class bfv.lib.io.DirectoryInfo inherits FileSystemInfo final:
  
  define public property ParentDirectory as character no-undo get. private set.
  
  
  constructor public DirectoryInfo(cfilename as character):
    
    super(cfilename).
    
    file-info:file-name = cfilename.
    this-object:Exists = (index(file-info:file-type, "D") > 0) and (file-info:file-type <> ? and file-info:file-type <> "").
    
    fetchFileSystemInfo().
    
    if (this-object:Name = "") then
      this-object:Name = FullName.
    
    if (FullName begins "~\~\" or not this-object:Exists) then
      ParentDirectory = "".
    else do:
      
      ParentDirectory = substring(FullName, 1, r-index(FullName, fileSystemSeparator)).
      if (ParentDirectory = FullName) then 
        ParentDirectory = "".
        
    end.
    
  end.
  
  
  method public override character ToString():
    return 
      super:ToString() + 
      "~nParentDirectory: " + subst("&1", ParentDirectory) 
      /* + 
      "~nIsReadOnly: " + subst("&1", string(IsReadOnly, "true/false")) +
      "~nFileSize: " + subst("&1", string(FileSize)) */
      .
      
  end method. 
  
end class.

