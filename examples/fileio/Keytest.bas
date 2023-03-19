Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem KEYTEST.BAS
Rem
Rem Test keyed access conditions in the BasicCard
Rem
Rem File KEYCARD.BAS contains the BasicCard source, so
Rem
Rem     ZCDOS -CKEYCARD KEYTEST

Option Explicit

#NoList
#Include FILEERR.DEF
#Include COMMERR.DEF
#List

Declare Command &H20 &H04 EnableKey (Key@, Counter@)

ResetCard : Call CheckSW1SW2()
Private ID$ : Call GetApplicationID (ID$) : Call CheckSW1SW2()
If ID$ <> "KEYCARD" Then Print "Card KEYCARD is required for this test" : Exit

ChDrive "@"

Open "Read Lock Key = 99,100" As 1
If FileError <> feAccessDenied Then Print "Test #1 failed" : Exit
FileError = feFileOK

Read Key File "GOODKEYS.BAS" : Call CheckFileError ("Error reading key file")
Call StartEncryption (P2 = 99, Rnd) : Call CheckSW1SW2()

Open "Read Lock Key = 99,100" As 1 : Call CheckFileError ("Error opening file")
Private S$
Line Input #1, S$ : Call CheckFileError ("Error reading file")
If S$ <> "Read Lock Key = 99,100" Then Print "Test #2 failed" : Exit
Close 1 : Call CheckFileError ("Error closing file")

Call EndEncryption() : Call CheckSW1SW2()

Read Key File "BADKEYS.BAS"
Call StartEncryption (P2 = 99, Rnd) : Call CheckSW1SW2()

Open "Read Lock Key = 99,100" As 1
If FileError <> feCommsError Or SW1SW2 <> swRetriesRemaining+4 Then
  Print "Test #3 failed", FileError, Hex$(SW1SW2) : Exit
End If
Open "Read Lock Key = 99,100" As 1
If FileError <> feCommsError Or SW1SW2 <> swRetriesRemaining+3 Then
  Print "Test #3 failed", FileError, Hex$(SW1SW2) : Exit
End If
Open "Read Lock Key = 99,100" As 1
If FileError <> feCommsError Or SW1SW2 <> swRetriesRemaining+2 Then
  Print "Test #3 failed", FileError, Hex$(SW1SW2) : Exit
End If
Open "Read Lock Key = 99,100" As 1
If FileError <> feCommsError Or SW1SW2 <> swRetriesRemaining+1 Then
  Print "Test #3 failed", FileError, Hex$(SW1SW2) : Exit
End If
Open "Read Lock Key = 99,100" As 1
If FileError <> feCommsError Or SW1SW2 <> swRetriesRemaining+0 Then
  Print "Test #3 failed", FileError, Hex$(SW1SW2) : Exit
End If
Open "Read Lock Key = 99,100" As 1
If FileError <> feCommsError Or SW1SW2 <> swKeyDisabled Then
  Print "Test #3 failed", FileError, Hex$(SW1SW2) : Exit
End If

Print "All tests passed. Press any key:" ; : While InKey$ = "" : Wend
