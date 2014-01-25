 
using bfv.lib.misc.IRecurrencePattern.
using bfv.lib.util.DatetimeUtil.
using bfv.lib.misc.CronRecurrencePattern.


class bfv.lib.misc.CronRecurrencePattern implements IRecurrencePattern: 
  
  define public property Minutes    as character no-undo get. set.
  define public property Hours      as character no-undo get. set.
  define public property DayOfMonth as character no-undo get. set.
  define public property Month      as character no-undo get. set.
  define public property DayOfWeek  as character no-undo get. set.
  
  define private property Year      as integer   no-undo get. set.
  
  
  constructor public CronRecurrencePattern():
    
  end.  
  
  
  constructor public CronRecurrencePattern(crontime as datetime-tz):
    DecomposeTime(crontime).
  end.  
  
  
  constructor public CronRecurrencePattern(pattern as character):
    DecomposePattern(pattern).
  end.  
  
  
  method public logical ValidatePattern(recurrencepattern as character):
    return true.
  end method.
  
  
	method public datetime-tz GetNextOccurrence(recurrencepattern as character, fromtime as datetime-tz):
		
    define variable nextocc  as datetime-tz no-undo.
    define variable cronnext as CronRecurrencePattern no-undo.
    
    DecomposePattern(recurrencepattern).
    
		cronnext = new CronRecurrencePattern(add-interval(fromtime, 1, "minutes")).
		this-object:CheckExpressions(fromtime).
    
		do while (true):
      
      if (this-object:Month <> "*" and cronnext:Month <> this-object:Month) then do:
        cronnext:AddMonths(1).
        cronnext:DayOfMonth = "1".
        cronnext:Hours = "0".
        cronnext:Minutes = "0".
        cronnext:DayOfWeek = string(RecalcWeekDay(fromtime, cronnext)).
        next. 
      end.
      
      if (this-object:DayOfMonth <> "*" and cronnext:DayOfMonth <> this-object:DayOfMonth) then do:
        cronnext:AddDays(1).
        cronnext:Hours = "0".
        cronnext:Minutes = "0".
        next.
      end.
      
      if (this-object:DayOfWeek <> "*" and cronnext:DayOfWeek <> this-object:DayOfWeek) then do:
        cronnext:AddDays(1).
        cronnext:Hours = "0".
        cronnext:Minutes = "0".
        next.
      end.
      
      if (this-object:Hours <> "*" and cronnext:Hours <> this-object:Hours) then do:
        cronnext:AddHours(1).
        cronnext:Minutes = "0".
        next.
      end.
      
      if (this-object:Minutes <> "*" and cronnext:Minutes <> this-object:Minutes) then do:
        cronnext:AddMinutes(1).
        next.
      end.
      
      leave.
      
    end.
    
    nextocc = cronnext:CalculateTime().
    
    if (nextocc < fromtime) then 
      nextocc = add-interval(nextocc, 1, "year").
      
    return nextocc.
		
	end method.
	
	
	method public static datetime-tz GetNext(recurrencepattern as character, fromtime as datetime-tz):
    return (new CronRecurrencePattern()):GetNextOccurrence(recurrencepattern, fromtime).    
	end method.
	
	
	method public datetime-tz CalculateTime():
	 
   return datetime-tz(integer(this-object:Month),
                      integer(DayOfMonth),
                      this-object:Year,
                      integer(Hours),
                      integer(Minutes)).
	end method.
	
	
	method private void DecomposePattern(pattern as character):
	  
    Minutes    = entry(1, pattern, " ").
    Hours      = entry(2, pattern, " ").
    DayOfMonth = entry(3, pattern, " ").
    Month      = entry(4, pattern, " ").
    DayOfWeek  = entry(5, pattern, " ").
	  
	end method.
	
	
	method private void DecomposeTime(crontime as datetime-tz):
    Minutes    = string(DatetimeUtil:GetMinutesFromDatetime(crontime)).
    Hours      = string(DatetimeUtil:GetHoursFromDatetime(crontime)).
    DayOfMonth = string(day(crontime)).
    Month      = string(month(crontime)).
    DayOfWeek  = string(IsoWeekDay(crontime)).
    Year       = year(crontime).	  
	end method.
  
  
  method public void AddMonths(number as integer):
    
    if (this-object:Month <> "*") then do:
      this-object:Month = string(integer(this-object:Month) + number).  
      if (integer(this-object:Month) > 12) then do:
        this-object:Month = "1".
        this-object:Year  = this-object:Year + 1.
      end.
    end.
  end method.
  

  method public void AddDays(number as integer):
    
    define variable newdate as date no-undo.
     
    if (DayOfMonth <> "*") then do:
      newdate = date(integer(this-object:Month), integer(DayOfMonth), year(today)) + number.
      this-object:DayOfMonth = string(day(newdate)).
      this-object:Month = string(month(newdate)).        
    end.
    
    if (DayOfWeek <> "*") then do:
      DayOfWeek = string(integer(DayOfWeek) + number).
      if (integer(DayOfWeek) > 7) then 
        DayOfWeek = string(integer(DayOfWeek) mod 7).
      
      if (integer(DayOfWeek) = 0) then
        DayOfWeek = "7".   
    end.
    
  end method.
  

  method public void AddHours(number as integer):
    
    if (this-object:Hours = "*") then
      this-object:Hours = "0".
    else
      this-object:Hours = string(integer(this-object:Hours) + number).  
    
    if (integer(Hours) > 23) then do:
      Hours = "0".
      AddDays(1).
    end.
        
  end method.


  method public void AddMinutes(number as integer):
        
    if (this-object:Minutes = "*") then
      Minutes = "0".
    else
      Minutes = string(integer(this-object:Minutes) + number).  
    
    if (integer(Minutes) > 59) then do:
      Minutes = "0".
      if (Hours <> "*") then
         AddHours(1).  
    end.
    
  end method.
  
  
  method public void CheckExpressions(fromtime as datetime-tz):
    
    define variable divider as integer no-undo.
    define variable remainder as integer no-undo.
    

    if (Minutes begins "*/") then do:
      
      divider = GetDivider(Minutes).
      Minutes = string(DatetimeUtil:GetMinutesFromDatetime(fromtime)).
      
      AddMinutes(divider - (integer(Minutes) mod divider)).
                    
    end.
    
    if (Hours begins "*/") then do:
      divider = GetDivider(Hours).
      Hours = string(DatetimeUtil:GetHoursFromDatetime(fromtime)).
      if (integer(Minutes) < DatetimeUtil:GetMinutesFromDatetime(fromtime)) then
        AddHours(1).
      
      remainder = (integer(Hours) mod divider).
      if (remainder > 0) then
        AddHours(divider - remainder).
        
    end.
    
  end.
  
  
  method private logical SpecialChars(expr as character): 
    return (index(expr, "/") > 0).
  end method.
  
  
  method private integer GetDivider(expr as character):  
    return integer(replace(expr, "*/", "")).
  end method.
  
  
  method private integer IsoWeekDay(fromtime as datetime-tz):
    def var wkday as integer no-undo.
    wkday = weekday(fromtime) - 1.
    if (wkday = 0) then
      wkday = 7.
    return wkday.
  end method.
  
  
  method private integer RecalcWeekday(fromtime as datetime-tz, cron as CronRecurrencePattern):
    
    def var newtime as datetime-tz no-undo.
    
    newtime = datetime-tz(integer(cron:Month), integer(cron:DayOfMonth), year(fromtime), 0, 0).
    if (newtime < fromtime) then 
      add-interval(newtime, 1, "year").
    
    return IsoWeekDay(newtime).  
    
  end method.
  
  
  method public override character ToString():
    return "recurrencepattern: " + Minutes + " " + Hours + " " + DayOfMonth + " " + this-object:Month + " " + DayOfWeek.
  end.
  
end class.
