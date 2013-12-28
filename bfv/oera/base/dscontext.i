/* dsContext.i -- standard context temp-table include file, that allows
   multiple rows, each defining a single context value name and value. */

&if defined(dsContext) = 0 &then 
 
define {&access-mode} temp-table ttContext no-undo {&REFERENCE-ONLY}
  field contextGroup    as character
  field contextName     as character
  field contextValue    as character
  field contextOperator as character
  field contextType     as character
  index ttContext is primary unique
        contextGroup
        contextName
        contextOperator.
           
define {&access-mode} dataset dsContext {&REFERENCE-ONLY} for ttContext.

&global-define dsContext true

&endif
