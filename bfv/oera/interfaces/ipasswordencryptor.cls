
/*------------------------------------------------------------------------
    File        : ipasswordencryptor
    Purpose     : 
    Syntax      : 
    Description : interface voor het encrypten van een password
    Author(s)   : boosterm
    Created     : Thu Dec 23 08:21:47 CET 2010
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE bfv.oera.interfaces.ipasswordencryptor:  
    
    METHOD PUBLIC CHARACTER EncryptPassword(unencryptedpwd AS CHARACTER).
    
END INTERFACE.