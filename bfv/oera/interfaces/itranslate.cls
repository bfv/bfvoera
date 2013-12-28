INTERFACE bfv.oera.interfaces.itranslate:
  METHOD PUBLIC VOID translateMessage(
    pcCode AS CHARACTER, 
    pcParam AS CHARACTER,
    OUTPUT pcShort AS CHARACTER,
    OUTPUT pcLong  AS CHARACTER).
END INTERFACE.
