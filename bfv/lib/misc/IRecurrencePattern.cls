
interface bfv.lib.misc.IRecurrencePattern:  
  
  method public datetime-tz GetNextOccurrence(recurrencepattern as character, fromtime as datetime-tz).
  method public logical ValidatePattern(recurrencepattern as character).
  
end interface.