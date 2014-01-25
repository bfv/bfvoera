&if "{&ttfile{&postfix}-defined}" = "" &then
  
  &global-define ttfile-defined  true

  define {&accessor} temp-table ttfile{&postfix} &if "{&no-undo}" <> "false" &then no-undo &endif
    field filename as character
    field isdir    as logical 
    .
  
&endif 