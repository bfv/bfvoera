subscribe to "timer_begin" anywhere run-procedure "TimerBegin".
subscribe to "timer_end" anywhere run-procedure "TimerEnd".
subscribe to "timer_dumpdata" anywhere run-procedure "DumpData".

define stream dumpstream.

define variable timeBegin as int64   no-undo.
define variable timeEnd   as int64   no-undo.
define variable callnr    as integer no-undo.
define variable lastdump  as date    no-undo.


define temp-table ttcall no-undo
  field callnumber    as integer
  field procedurename as character
  field begintime     as datetime-tz
  field elapsedtime   as integer       /* in milliseconds */
  field closed        as logical
  field comment       as character     /* for future use */
  index callnumber    as primary unique callnumber
  index procedurename procedurename callnumber
  index closed closed
  .
   
lastdump = today.
   
procedure TimerBegin:
  
  assign  
    timeBegin = etime.
    callnr = callnr + 1
    .
  
  create ttcall.
  assign
    ttcall.callnumber = callnr
    ttcall.procedurename = program-name(2)
    ttcall.begintime = now
    .
    
end.


procedure TimerEnd:
  
  timeEnd = etime.
  
  for last ttcall where ttcall.procedurename = program-name(2): 
    assign 
      ttcall.elapsedtime = (timeEnd - timeBegin)
      ttcall.closed = true
      .   
  end. 
  
  if (today <> lastdump and not can-find(first ttcall where ttcall.closed = false)) then
    run DumpData.
    
end.


procedure DumpData:
  
  define variable dumpfile as character no-undo.
  define variable thisday as date no-undo.
  
  thisday  = today.   
  lastdump = thisday.
  
  dumpfile = session:temp-directory + "/" + 
    string(year(thisday), "9999") + "-" + string(month(thisday), "99") + "-" + string(day(thisday), "99") + "-" +
    guid + ".timer.data".
    
  output stream dumpstream to value(dumpfile).
  
  for each ttcall:
    put stream dumpstream unformatted ttcall.procedurename "," iso-date(ttcall.begintime) "," ttcall.elapsedtime skip.
    delete ttcall.
  end.
  
  output stream dumpstream close.
  
end.