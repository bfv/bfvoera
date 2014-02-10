using bfv.lib.io.*.

routine-level on error undo, throw.

class bfv.lib.io.Directory final:
  
  {bfv/lib/io/ttfile.i &accessor="static"}
  
  define private stream filesearch.
  
  /** Return all the subdirectories of 'initdir'
   *  @author B.F.V. Oostermeyer
   *  @param initdir The directory to start the searches
   *  @param searchpattern Mask for searching subdirs, multiple can specified (separated by either ' ', ',' or ';'
   *  @param ttfile output table with results
   */
   
  constructor protected Directory():
  end.
  
  method public static void GetDirectories(initialDirectory as character, searchPattern as character, output table ttfile):
    
    empty temp-table ttfile.
    
    searchPattern = processSearchPattern(searchPattern).
    fetchfiles(initialDirectory, searchPattern, true, false, true).
    
  end method.
  

  method public static void GetDirectories(initialDirectory as character, output table ttfile):
    Directory:GetDirectories(initialDirectory, "*", output table ttfile).
  end method.
    
    
  method public static void GetFiles(initialDirectory as character, searchPattern as character, includeSubdirs as logical, output table ttfile):
    
    empty temp-table ttfile.
    
    searchPattern = processSearchPattern(searchPattern).
    
    fetchfiles(initialDirectory, searchPattern, false, true, includeSubdirs).
    
  end method.
  
  
  method public static void GetFiles (initialDirectory as character, searchPattern as character, output table ttfile):
    GetFiles(initialDirectory, searchPattern, false, output table ttfile).
  end method.
  
  
  method public static void GetFiles (initialDirectory as character, output table ttfile):
    GetFiles(initialDirectory, "*", false, output table ttfile).
  end method.
  
  
  method public static void GetFileSystemEntries(initialDirectory as character, searchPattern as character, includeSubdirs as logical, output table ttfile):
    
    empty temp-table ttfile.
    
    searchPattern = processSearchPattern(searchPattern).
    
    fetchfiles(initialDirectory, searchPattern, true, true, includeSubdirs).
    
  end method.


  method private static character fetchfiles(cdir as character, searchPattern as character, includedirs as logical, includefiles as logical, recurse as logical):
  
    def var cfile as character no-undo.
       
    input from os-dir(cdir).
    
    repeat:
      
      import cfile.
      
      if (cfile <> "." and cfile <> "..") then do:
         
        file-info:file-name = cdir + "/" + cfile.
        
        /* geen hidden files / directories */
        if (index(file-info:file-type, "H") > 0) then 
          next.
          
        if (index(file-info:file-type, "D") > 0) then do:
          
          if (includedirs and checkfilemask(file-info:full-pathname, searchPattern)) then do:
            create ttfile.
            assign 
              ttfile.filename = replace(file-info:full-pathname, "\", "/")
              ttfile.isdir     = true
              .
          end.
          
          if (recurse) then
            fetchfiles(file-info:full-pathname, searchPattern, includedirs, includefiles, recurse).
            
        end.
        else if (includefiles) then do:
          
          if (checkfilemask(file-info:full-pathname, searchPattern)) then do:
            
            create ttfile.
            assign
              ttfile.filename = replace(file-info:full-pathname, "\", "/")
              ttfile.isdir     = false
              .
          
          end.
             
        end.
          
      end.
      
    end.
    
    input close.
    
  end method.
  
  
  method private static logical checkfilemask (cfile as character, filemask as character):
    
    def var i as integer no-undo.
        
    do i = 1 to num-entries(filemask):
      if (cfile matches replace(entry(i, filemask), ".", "~~.")) then 
        return true.
    end.  
    
    return false.
    
  end method.
  
  
  method private static character processSearchPattern(searchpattern as character):
    
    /* allowed mask seperators: ' ', ',' & ';' */
    do while (searchpattern <> replace(searchpattern, "  ", " ")):
      searchpattern = replace(searchpattern, "  ", " ").
    end.
    
    searchpattern = replace(searchpattern, " ", ",").
    searchpattern = replace(searchpattern, ";", ",").
    
    return searchpattern.
    
  end method.
  
end class.