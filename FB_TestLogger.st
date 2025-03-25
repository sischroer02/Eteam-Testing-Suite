FUNCTION_BLOCK FB_TestLogger
VAR_INPUT
    StepDescription : STRING(80);  // Step label
    StepResult      : BOOL;        // TRUE = Pass, FALSE = Fail
    AddStep         : BOOL;        // Rising edge = Add to log
    WriteLogToFile  : BOOL;        // Rising edge = Save to file
    PrintToLogger   : BOOL;        // Rising edge = Print log to TwinCAT system
END_VAR

VAR_OUTPUT
    LogComplete     : BOOL;        // TRUE once writing is done
    StepCount       : INT;         // How many steps logged
    Busy            : BOOL;        // Writing file
    Error           : BOOL;        // File error occurred
END_VAR

VAR
    // Internal logging arrays
    LogStep   : ARRAY[0..99] OF STRING(80);
    LogValue  : ARRAY[0..99] OF BOOL;
    LogIndex  : INT := 0;

    // File handling
    fbOpen  : FB_FileOpen;
    fbWrite : FB_FileWrite;
    fbClose : FB_FileClose;
    hFile   : UINT;
    i       : INT;
    logStr  : STRING(255);
    writeState : INT := 0;

    // Edge detection
    lastAddStep       : BOOL := FALSE;
    lastWriteLog      : BOOL := FALSE;
    lastPrintToLogger : BOOL := FALSE;
END_VAR

// Detect rising edges
VAR
    risingAdd    : BOOL := AddStep AND NOT lastAddStep;
    risingWrite  : BOOL := WriteLogToFile AND NOT lastWriteLog;
    risingPrint  : BOOL := PrintToLogger AND NOT lastPrintToLogger;
END_VAR

lastAddStep := AddStep;
lastWriteLog := WriteLogToFile;
lastPrintToLogger := PrintToLogger;

LogComplete := FALSE;
Error := FALSE;
Busy := FALSE;
StepCount := LogIndex;

(* === Add Step to Log === *)
IF risingAdd AND (LogIndex < 100) THEN
    LogStep[LogIndex] := StepDescription;
    LogValue[LogIndex] := StepResult;
    LogIndex := LogIndex + 1;
END_IF

(* === Print to TwinCAT Logger === *)
IF risingPrint THEN
    FOR i := 0 TO LogIndex - 1 DO
        TcEventLog.Add(16#00000001, 'Step: ' + LogStep[i] + ' | Result: ' + BOOL_TO_STRING(LogValue[i]));
    END_FOR;
END_IF

(* === Write to CSV File === *)
CASE writeState OF
    0:
        IF risingWrite THEN
            fbOpen.sFileName := 'C:\TestLogs\TestLog.csv';
            fbOpen.ePath := PATH_GENERIC;
            fbOpen.eOpenMode := FOPEN_MODEAPPEND;
            fbOpen(bExecute := TRUE);
            writeState := 1;
        END_IF

    1:
        fbOpen(bExecute := FALSE);
        IF NOT fbOpen.bBusy THEN
            IF fbOpen.bError THEN
                Error := TRUE;
                writeState := 0;
            ELSE
                hFile := fbOpen.hFile;
                i := 0;
                writeState := 2;
            END_IF
        END_IF

    2:
        IF i < LogIndex THEN
            logStr := CONCAT(CONCAT(LogStep[i], ','), BOOL_TO_STRING(LogValue[i]));
            fbWrite.hFile := hFile;
            fbWrite.pBuffer := ADR(logStr);
            fbWrite.nBufferSize := LEN(logStr);
            fbWrite(bExecute := TRUE);
            writeState := 3;
        ELSE
            writeState := 5;
        END_IF

    3:
        fbWrite(bExecute := FALSE);
        IF NOT fbWrite.bBusy THEN
            IF fbWrite.bError THEN
                Error := TRUE;
                writeState := 5;
            ELSE
                i := i + 1;
                writeState := 2;
            END_IF
        END_IF

    5:
        fbClose.hFile := hFile;
        fbClose(bExecute := TRUE);
        writeState := 6;

    6:
        fbClose(bExecute := FALSE);
        IF NOT fbClose.bBusy THEN
            LogComplete := TRUE;
            writeState := 0;
        END_IF
END_CASE