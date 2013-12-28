/** ------------------------------------------------------------------------
    File        : UpdateActionEnum
    Purpose     : Enumeration listing actions that can be performed on data,
                  that operate/update data.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 26 14:16:16 EST 2009
    Notes       :                   
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using bfv.oera.shared.UpdateActionEnum.
using openedge.lang.EnumMember.

class bfv.oera.shared.UpdateActionEnum final inherits EnumMember:
    
    define public static property Add       as UpdateActionEnum no-undo get. private set.
    define public static property Delete    as UpdateActionEnum no-undo get. private set.
    
    /** A Save action writes data to a data store in the current OERA layer. 
        For instance, in the Model, a Save is to the local dataset. See Commit for more. */
    define public static property Save      as UpdateActionEnum no-undo get. private set.
    
    /** A Commit action writes data to a data store in an OERA layer that is 'further back' (as it were).
        So a Commit in the Presentation Layer will write data to the Business Component layer.  */
    define public static property Commit    as UpdateActionEnum no-undo get. private set.
    define public static property Undo      as UpdateActionEnum no-undo get. private set.
    
    constructor static UpdateActionEnum():
        UpdateActionEnum:Add = new UpdateActionEnum(1, 'Add').
        UpdateActionEnum:Delete  = new UpdateActionEnum(2, 'Delete').
        UpdateActionEnum:Save = new UpdateActionEnum(3, 'Save').
        UpdateActionEnum:Commit = new UpdateActionEnum(4, 'Commit').
        UpdateActionEnum:Undo = new UpdateActionEnum(5, 'Undo').
    end constructor.
    
    constructor public UpdateActionEnum ( input piValue as integer, input pcName as character ):
        super (input piValue, input pcName).
    end constructor.
    
    method static public UpdateActionEnum EnumFromValue(piValue as integer):
        define variable oMember as UpdateActionEnum no-undo.
        
        case piValue:
            when UpdateActionEnum:Add:Value then oMember = UpdateActionEnum:Add.
            when UpdateActionEnum:Delete:Value then oMember = UpdateActionEnum:Delete.
            when UpdateActionEnum:Save:Value then oMember = UpdateActionEnum:Save.
            when UpdateActionEnum:Commit:Value then oMember = UpdateActionEnum:Commit.
            when UpdateActionEnum:Undo:Value then oMember = UpdateActionEnum:Undo.
        end case.
        
        return oMember.
    end method.    
    
end class.