Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem LINETEST.BAS
Rem
Rem Test LINE INPUT statement, in a diskette and a BasicCard
Rem
Rem To run: ZCDOS -COPENCARD LINETEST (with a diskette inserted!)

Option Explicit

#NoList
#Include FILEERR.DEF
#Include COMMERR.DEF
#List

Declare Sub TestLineInput()

Private OriginalDrive$ : OriginalDrive$ = CurDrive

Rem Diskette drive H:
ChDrive "H"
Call TestLineInput()

Rem BasicCard drive @:
ResetCard : Call CheckSW1SW2()
Private ID$ : Call GetApplicationID (ID$) : Call CheckSW1SW2()
If ID$ <> "OPENCARD" Then Print "Card OPENCARD is required for this test" : Exit

ChDrive "@"
Call TestLineInput()

ChDrive OriginalDrive$

Print "Press any key:" ; : While InKey$ = "" : Wend

Rem Sub TestLineInput()
Rem
Rem 1. Open LINE.DAT for output, write two lines, and close.
Rem 2. Open LINE.DAT for input, read and check two lines, read a third time
Rem    (expecting error), and close.
Rem 3. Delete LINE.DAT.

Sub TestLineInput()

  Private F, S$
  F = Open "LINE.DAT" For Output : Call CheckFileError ("Error opening for output")
  Print #F, "abcdefg" : Print #F, "hijk" : Call CheckFileError ("Error writing to file")
  Close F : Call CheckFileError ("Error closing file")

  F = Open "LINE.DAT" : Call CheckFileError ("Error opening for input")
  Line Input #F, S$ : Call CheckFileError ("Error reading a line")
  If S$ <> "abcdefg" Then Print "Failed test #1" : Exit
  Line Input #F, S$ : Call CheckFileError ("Error reading a line")
  If S$ <> "hijk" Then Print "Failed test #2" : Exit

  Line Input #F, S$
  If FileError <> feReadError Then Print "Failed test #3" : Exit
  FileError = feFileOK

  Close : Call CheckFileError ("Error closing all files")

  Kill "LINE.DAT" : Call CheckFileError ("Error deleting file")

  Print "All tests passed on drive " CurDrive ":"

End Sub
