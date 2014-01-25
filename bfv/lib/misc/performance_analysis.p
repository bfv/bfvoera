using bfv.lib.io.Directory.

{bfv/lib/io/ttfile.i}

function BerekenStandaardDeviatie returns decimal (program as character, gemiddelde as decimal, aantal as integer) forward.


define temp-table tttime no-undo 
  field program as character
  field timestamp as character
  field tijdsduur as int
  index program as primary program
  .

define temp-table ttstat no-undo 
  field program as character
  field aantalcalls as integer
  field gemiddelde as decimal
  field stdev as decimal
  index program as primary program
  .
     
define stream datastream. 
  
define variable dataDirectory as character no-undo.

dataDirectory = substitute("&1timer_data":U, session:temp-directory).
run ProcessDataFiles.
run ProcessData.


procedure ProcessData:
  
  def var som as decimal no-undo.
  def var dev as decimal no-undo.
  def var aantal as integer no-undo.
  
  define buffer tttime for tttime.
  define buffer ttstat for ttstat.
  
  for each tttime break by tttime.program:
    
    if (first-of(tttime.program)) then do:
      som = 0.0.
      dev = 0.0.
      aantal = 0.
      som = 0.
    end.
    
    assign 
      aantal = aantal + 1
      som = som + tttime.tijdsduur
      .
      
    if (last-of(tttime.program)) then do:
      create ttstat.
      assign 
        ttstat.program     = tttime.program
        ttstat.gemiddelde  = truncate((som / aantal) + 0.05, 1)
        ttstat.aantalcalls = aantal
        ttstat.stdev       = BerekenStandaardDeviatie(tttime.program, ttstat.gemiddelde, aantal)
        .       
    end.
    
  end.  /* for each tttime... */
   
end procedure.


procedure ProcessDataFiles:

  Directory:GetFiles(dataDirectory, "*.timer.data", false, output table ttfile).

  for each ttfile:
    run ReadDatalines(ttfile.filename).
  end.

end procedure.

procedure ReadDatalines:
  
  define input parameter datafilename as character no-undo.
  
  def var dataregel as character no-undo.


  input stream datastream from value(ttfile.filename).
  
  do on error undo : 
    
    datalines:
    do while (true) on error undo:
      import stream datastream unformatted dataregel no-error.
      create tttime.
      assign 
        tttime.program = entry(1, dataregel)
        tttime.timestamp = entry(2, dataregel)
        tttime.tijdsduur = integer(entry(3, dataregel))
        .
    end.
    
  end.
    
  input stream datastream close.  
    
end procedure.  


function BerekenStandaardDeviatie returns decimal (programname as character, gemiddelde as decimal, aantal as integer):
  
  define buffer b-tttime for tttime.
  
  def var som as decimal no-undo.
  
  
  for each b-tttime where b-tttime.program = programname:
    som = som + exp((b-tttime.tijdsduur - gemiddelde), 2).
  end.
  
  return truncate(sqrt(som / aantal) + 0.05, 1).
  
end function.

def var i as integer no-undo.

output stream datastream to value(dataDirectory + "\all.data").
for each tttime:
  put stream datastream unformatted tttime.program + "," + tttime.timestamp + "," + string(tttime.tijdsduur) skip. 
end.
output stream datastream close.

temp-table ttstat:write-json("file", dataDirectory + "\stat.data.json", true).

output stream datastream to value(dataDirectory + "\stat.data.csv").
for each ttstat by ttstat.program:
  put stream datastream unformatted 
      ttstat.program + "," + string(ttstat.aantalcalls) + "," +
      string(trunc(ttstat.gemiddelde, 0)) + "," + string(trunc(ttstat.stdev, 0)) skip.
     
end.

message "done".


