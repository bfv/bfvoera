/** ------------------------------------------------------------------------
    File        : EnumMember
    Purpose     : Abstract class for Enumerations' members.  
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Jan 21 10:07:10 EST 2010
    Notes       : * We could add a temp-table to manage the EnumMembers' values
                    etc. That's not done right now because there's no pressing 
                    need for it.
                 * Value takes precedence over name, when both are specified.
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using openedge.lang.EnumMember.
using Progress.Lang.Class.
using Progress.Lang.AppError.
using Progress.Lang.Object.

class openedge.lang.EnumMember: 
    
  define public property Name  as character no-undo get. private set.
  define public property Value as integer   no-undo get. private set.
    
  define private static temp-table ttValue no-undo
    field EnumType   as character
    field EName      as character
    field EValue     as integer 
    field EnumObject as Progress.Lang.Object
    .  
    
  constructor public EnumMember(piValue as integer, pcName as character):        
    assign 
      this-object:Name  = pcName
      this-object:Value = piValue.
               
    create ttValue.
    assign 
      ttValue.EnumType   = this-object:GetClass():TypeName
      ttValue.EName      = pcName
      ttValue.EValue     = piValue
      ttValue.EnumObject = this-object
      .
          
  end constructor.


  constructor public EnumMember(piValue as integer):
    this-object(piValue, ?).
  end constructor.


  constructor public EnumMember(pcName as character):        
    this-object(?, pcName).
  end constructor.


  method public logical Equals(pcName as character):
    define variable lEquals as logical no-undo.
        
    lEquals = (this-object:Name = pcName). 
        
    return lEquals.
  end method.
    
    
  method public override logical Equals(poEnumMember as Object):
    define variable lEquals as logical no-undo.

    lEquals = super:Equals(poEnumMember).
        
    /* ABL deals with unknown values just fine */
    if not lEquals then
      lEquals = type-of(poEnumMember, EnumMember) and 
        this-object:ToString() eq  cast(poEnumMember, EnumMember):ToString().

    return lEquals.
  end method.


  method public override character ToString():
    define variable cName as character no-undo.
        
    if this-object:Name ne ? then
      cName = substitute('&1', this-object:Name).
    else
      if this-object:Value eq ? then
        cName = substitute('&1_Value_&2', this-object:GetClass():TypeName, this-object:Value).
      else
        cName = substitute('&1_&2', this-object:GetClass():TypeName, this-object).
        
    return cName.
        
  end method.
    
    
  method public static EnumMember GetEnumMember(enumName as character, cls as Progress.Lang.Class):
      
    find ttValue where ttValue.EnumType = cls:TypeName
      and ttValue.EName    = enumName
      no-error.
      
    if (not avail ttValue) then 
      undo, throw new Progress.Lang.AppError( quoter(enumName) + " is not a member of Enum " + quoter(cls:TypeName), 1).
        
    return cast(ttValue.EnumObject, openedge.lang.EnumMember).
          
  end method.
    
    
  method public static EnumMember GetEnumMember(enumValue as integer, cls as Progress.Lang.Class):
      
    find ttValue where ttValue.EnumType = cls:TypeName
      and ttValue.EValue    = enumValue
      no-error.
      
    if (not avail ttValue) then 
      undo, throw new Progress.Lang.AppError(quoter(enumValue) + " is not a value of Enum " + quoter(cls:TypeName), 1).
        
    return cast(ttValue.EnumObject, openedge.lang.EnumMember).
          
  end method.
    
    
  method protected static character GetNameList(enumtypeIn as character):
      
    def var clist as character no-undo.
      
    for each ttValue where ttValue.EnumType = enumtypeIn:
      clist = clist + "," + ttValue.EName.
    end.
      
    return trim(clist, ",").
      
  end method.

end class. 