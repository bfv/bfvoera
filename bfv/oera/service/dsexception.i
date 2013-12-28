DEFINE TEMP-TABLE ttException NO-UNDO {&REFERENCE-ONLY}
    FIELD exceptionId         AS CHARACTER
    FIELD exceptionSequence   AS INTEGER
    FIELD timeStamp           AS DATETIME-TZ
    FIELD exceptionLevel      AS INTEGER
    FIELD messageCode         AS CHARACTER
    FIELD parameters          AS CHARACTER
    FIELD shortMessage        AS CHARACTER
    FIELD longMessage         AS CHARACTER
    FIELD progressErrors      AS CHARACTER
    FIELD callStack           AS CHARACTER
    FIELD contextInfo         AS CHARACTER
    INDEX exceptionId IS PRIMARY UNIQUE exceptionId
    INDEX exceptionSequence exceptionSequence.
DEFINE DATASET dsException {&REFERENCE-ONLY} FOR ttException.
