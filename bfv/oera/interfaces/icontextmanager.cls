
interface bfv.oera.interfaces.icontextmanager:
      
  {bfv/oera/service/ttcontextblock.i &REFERENCE-ONLY=REFERENCE-ONLY}
      
  method public void createSession(output pcSessionID as character).
  method public void restoreSession(input pcSessionID as character).
  method public void deleteSession(input pcSessionID as character).
  method public void clearSession(input pcSessionID as character).
  method public void getContextValue(input  pcContextName as character,
    input  pcContextGroup as character,
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character,
    output pcContextValue as character).
  method public void setContextValue(input  pcContextName as character,
    input  pcContextGroup as character,
    input  pcContextValue as character,
    input  pdtzContextTTL as datetime-tz, 
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character).
  method public void deleteContextValue(input  pcContextName as character,
    input  pcContextGroup as character,
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character).
  method public void getContextObject(input  pcContextName as character,
    input  pcContextGroup as character,
    input  phContextObject as handle,
    input  pcRestoreMode as character,
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character).
  method public void setContextObject(input  pcContextName as character,
    input  pcContextGroup as character,
    input  phContextObject as handle,
    input  pdtzContextTTL as datetime-tz, 
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character).
  method public void deleteContextObject(input  pcContextName as character,
    input  pcContextGroup as character,
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character).
  method public void getContextBlock(input TABLE for ttContextBlock,
    input  pcContextGroup as character,
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character).
  method public void setContextBlock(input TABLE for ttContextBlock,
    input  pcContextGroup as character,
    input  pdtzContextTTL as datetime-tz,
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character).
  method public void deleteContextBlock(input  pcContextGroup as character,
    input  piContextScope as integer,
    input  pcSessionID as character,
    input  pcUserID as character).
end interface.
