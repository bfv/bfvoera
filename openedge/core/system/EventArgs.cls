/** ------------------------------------------------------------------------
    File        : EventArgs
    Purpose     : Generic event arguments class, including static 'Empty'
                  option. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Jul 27 11:45:09 EDT 2009
    Notes       : * Using EventArgs allows us to extend arguments without
                    changing event signatures.
                  * this class is likely to be specialised, but there's no 
                    requirement for that to happen. although outside of 
                    'empty' this is a somewhat useless class :)
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using openedge.core.system.EventArgs.

class openedge.core.system.EventArgs:

  /** A single instance of this class so that we don't have
      to pass nulls around (ie we can depend on there always being
      a value if we so desire).   */
  define static public property Empty as EventArgs 
    get():
      if not valid-object(EventArgs:Empty) then
        EventArgs:Empty = new EventArgs().
             
      return EventArgs:Empty.
    end.
    private set.
    
end class.