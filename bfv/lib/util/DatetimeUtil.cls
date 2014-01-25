
using bfv.lib.util.DatetimeUtil.

routine-level on error undo, throw.

class bfv.lib.util.DatetimeUtil: 
  
  
  define public static property TimeDiffServer as integer get. 
    private set.  /* in s, > 0 betekent dat het op de server vroeger is */
  
  constructor static DateTimeUtil():
    
    define variable serverTime        as datetime-tz no-undo.
    define variable timeSourceSetting as character   no-undo.
    
    assign 
      timeSourceSetting   = session:time-source
      session:time-source = ldbname(1)
      serverTime          = now    
      session:time-source = timeSourceSetting    
      TimeDiffServer      = (now - serverTime) / 1000.
      
  end.
  
  method public static character GetTimeString(dt as decimal):
    return GetTimeString(integer(round(dt,0))).  
  end method.
  
  
  method public static character GetTimeString(it as integer):
    /* it is aantal minuten sinds middernacht */
    define variable hours    as integer   no-undo.
    define variable minutes  as integer   no-undo.
    define variable times    as integer   no-undo.
    define variable str-time as character no-undo.

    assign 
      times    = if it < 0
                        then -(it)
                        else it
      minutes  = times mod 60
      hours    = (times - minutes) / 60
      str-time = string(hours, "zzz9") + ":" + string(minutes, "99").
    
    if it < 0
      then
      assign str-time = str-time + "-".
          
    return str-time.  
  end method.
  
  
  
  method public static character GetTimeString(dt as datetime-tz):
    return GetTimeString(dt, "hh:mm").  
  end method.
  
  
  method public static character GetTimeString(dt as datetime-tz, timeformat as character):
    
    def var ichars as integer no-undo.
      
    case timeformat:  
      when "hh:mm" then 
        ichars = 5.
      when "hh:mm:ss" then 
        ichars = 8.
      otherwise
      ichars = 5.
    end case.
    
    return substring(entry(2, iso-date(dt), "T"), 1, ichars).
    
  end method.
  
  
  /* De method zet expressies zoals 8d13h7m7s om in een aantal seconden */
  method public static integer GetSeconds(expr as character):
    
    def var seconds as integer no-undo.
    
    assign 
      seconds = seconds + GetPart(expr, "d") * 86400
      seconds = seconds + GetPart(expr, "h") * 1440   
      seconds = seconds + GetPart(expr, "m") * 60
      seconds = seconds + GetPart(expr, "s").
    
    return seconds.
       
  end method.
  
  
  method private static integer GetPart(expr as character, part as character):
    
    def var ipos    as integer   no-undo.
    def var i       as integer   no-undo.
    def var cijfers as character no-undo init "1234567890".
    
    ipos = index(expr, part).
    if (ipos > 0) then 
    do:
      
      i = ipos - 1.
      do while (i > 0 and index(cijfers, substring(expr, i, 1)) > 0):
        i = i - 1.
      end.
      i = i + 1.
      
      return integer(substring(expr, i, ipos - i)).
      
    end.
    else 
      return 0.
     
  end method.
  
  
  method public static integer GetHoursFromDatetime(moment as datetime-tz):
    
    def var hours      as integer   no-undo.
    def var timestring as character no-undo.
    
    assign 
      timestring = iso-date(moment)
      timestring = substring(timestring, index(timestring, "T") + 1, 2).   
    
    return integer(timestring). 
      
  end method.
  
  method public static integer GetMinutesFromDatetime(moment as datetime-tz):
    
    def var hours      as integer   no-undo.
    def var timestring as character no-undo.
    
    assign 
      timestring = iso-date(moment)
      timestring = substring(timestring, index(timestring, "T") + 1)
      timestring = entry(2, timestring, ":").   
    
    return integer(timestring). 
  
  end method.


  method public static integer ISOWeekDag( datum as date ):
 
    define variable dagNummer as integer extent 7 no-undo initial [7,1,2,3,4,5,6].
    
    return dagnummer[ weekday( datum ) ].       
    
  end method. /* ISOWeekDag */
    
  /* weeknummer formaat: eejjww */
  method public static integer ISOWeekNummer( datum as date ):
    
        return integer(1 +
                       if (datum - weekday(datum - 1) + 8 > date(1, 4, year(datum) + 1)) 
                       then ((year(datum) + 1) * 100)
                       else if (datum - weekday(datum - 1) + 8 <= date(1, 4, year(datum))) 
                       then (truncate((datum - date(1, 1, year(datum) - 1) + 4 - 
                             weekday(datum - 1)) / 7, 0) + (year(datum) - 1) * 100)
                       else (truncate((datum - date(1, 1, year(datum)) + 4 - 
                             weekday(datum - 1)) / 7, 0) + year(datum) * 100)).

  end method. /* ISOWeekNummer */       
    
    
  method public static integer ConvertHhmmToMillis(tm as character, tijdtot as logical):
      
    if num-entries(tm, ' ') = 2 then 
      tm = entry(2, tm, ' ').
    if tijdtot and tm = '00:00' then return 86400000. /* tijdtot 00:00 wordt opgeslagen als 24:00, display als 00:00 */ 
      
    return 1000 * ((integer(entry(1,tm,':')) * 3600) +
      (integer(entry(2,tm,':')) * 60)
      ).
  end method.   
  
    
  method public static character ConvertMillisToHhmm (mseconds as integer):
    return string(integer((mseconds modulo 86400000) / 1000), "HH:MM").
  end method.   
    
      
  method public static datetime-tz RoundToMinutes(moment as datetime-tz):
    return datetime-tz(date(moment)) + integer(trunc((mtime(moment) / 60000), 0)) * 60000.
  end method.  
    
end class.