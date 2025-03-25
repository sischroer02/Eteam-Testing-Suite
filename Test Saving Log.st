VAR
    fbFileOpen  : FB_FileOpen;
    fbFileWrite : FB_FileWrite;
    fbFileClose : FB_FileClose;
    fileHandle  : UINT;

    filePath    : T_MaxString := 'C:\TestLogs\TestLog.csv'; // Ensure this folder exists
    writeDone   : BOOL := FALSE;
    logString   : STRING(255);
    i           : INT;
END_VAR

// Step 2: Open the File

fbFileOpen.sFileName := filePath;
fbFileOpen.ePath := PATH_GENERIC; // PATH_GENERIC = C:\ on your dev PC
fbFileOpen.eOpenMode := FOPEN_MODEAPPEND; // Append mode
fbFileOpen(bExecute := TRUE);
IF fbFileOpen.bBusy = FALSE AND fbFileOpen.bError = FALSE THEN
    fileHandle := fbFileOpen.hFile;
END_IF


// Step 3: Format & Write the Log Entries



FOR i := 0 TO LogIndex - 1 DO
    logString := CONCAT(CONCAT(LogStep[i], ','), BOOL_TO_STRING(LogValue[i]));
    fbFileWrite.hFile := fileHandle;
    fbFileWrite.pBuffer := ADR(logString);
    fbFileWrite.nBufferSize := LEN(logString);
    fbFileWrite(bExecute := TRUE);

    // Wait for write to finish before next iteration (simplified for cyclic task)
    IF fbFileWrite.bBusy = FALSE AND fbFileWrite.bError = FALSE THEN
        fbFileWrite(bExecute := FALSE); // reset
    END_IF
END_FOR


// Close the File
fbFileClose.hFile := fileHandle;
fbFileClose(bExecute := TRUE);