
class bfv.lib.io.FileSystemInfo:
  
  define public property Attributes     as character   no-undo get. protected set.
  define public property CreationTime   as datetime-tz no-undo get. protected set.
  define public property Exists         as logical     no-undo get. protected set.
  define public property Extension      as character   no-undo get. protected set.
  define public property LastWriteTime  as datetime-tz no-undo get. protected set.
  define public property FullName       as character   no-undo get. protected set.
  define public property Name           as character   no-undo get. protected set.
  
  define private variable originalName  as character no-undo.
  define protected property fileSystemSeparator as character no-undo get. private set. 	


  constructor protected FileSystemInfo(filesystementry as character):
    originalName = (if (opsys begins "win") then replace(filesystementry, "/", "\") else replace(filesystementry, "\", "/")).     
    fileSystemSeparator = (if (opsys begins "win") then "\" else "/").
  end.
  
  
  method protected void fetchFileSystemInfo():
    
    file-info:file-name = originalName.
    
    this-object:Extension = (if (r-index(originalName, ".") > 0) then substring(originalName, r-index(originalName, ".") + 1) else "").
    if (this-object:Extension matches "*" + fileSystemSeparator + "*") then
      this-object:Extension = "".   /* happens in case of //emea.progress.com/capelle */
      
    this-object:FullName       = (if file-info:full-pathname <> ? then file-info:full-pathname else originalName).
    this-object:Name           = substring(originalName, r-index(originalName, "\") + 1).
    
    if (this-object:Exists) then do:
      this-object:Attributes     = file-info:file-type.
      this-object:CreationTime   = datetime(file-info:file-create-date, file-info:file-create-time * 1000). 
      this-object:LastWriteTime  = datetime(file-info:file-mod-date, file-info:file-mod-time * 1000).    
    end.
     
  end.
  
  
  method public override character ToString():
    
    return   
      "~nName: " + subst("&1", this-object:Name) + 
      "~nFullName: " + subst("&1", this-object:FullName) +  
      "~nExists: " + subst("&1", string(this-object:Exists, "true/false")) + 
      "~nExtension: " + subst("&1", this-object:Extension) +  
      "~nAttributes: " + subst("&1", this-object:Attributes) + 
      "~nCreationTime: " + subst("&1", iso-date(this-object:CreationTime)) +  
      "~nLastWriteTime: " + subst("&1", iso-date(this-object:LastWriteTime))
      .
    
  end.
  
  
  method public override logical Equals(otherObject as Progress.Lang.Object):
    
    def var other as bfv.lib.io.FileSystemInfo.
    
    
    if (super:Equals(otherObject)) then 
      return true.
    
    if (not valid-object(otherObject)) then
      return false.
    
    if (this-object:GetClass():TypeName <> otherObject:GetClass():TypeName) then
      return false.
    
    other = cast(otherObject, "bfv.lib.io.FileSystemInfo").
    
    if (this-object:FullName = other:FullName) then 
      return true.
      
    return false.
        
  end method.
    
end class.