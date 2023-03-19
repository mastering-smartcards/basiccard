Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem PUTGET.BAS
Rem
Rem Test all versions of PUT and GET sttements, in a diskette and a BasicCard
Rem
Rem To run: ZCDOS -COPENCARD PUTGET (with a diskette inserted!)

Option Explicit

#NoList
#Include FILEERR.DEF
#Include COMMERR.DEF
#List

Declare Sub TestPutGet()

Private OriginalDrive$ : OriginalDrive$ = CurDrive

Rem Diskette drive A:
Rem ChDrive "A"
Rem Call TestPutGet()

Rem BasicCard drive @:
ResetCard : Call CheckSW1SW2()
Private ID$ : Call GetApplicationID (ID$) : Call CheckSW1SW2()
If ID$ <> "OPENCARD" Then Print "Card OPENCARD is required for this test" : Exit

ChDrive "@"
Call TestPutGet()

ChDrive OriginalDrive$

Print "Press any key:" ; : While InKey$ = "" : Wend

Rem Sub TestPutGet()
Rem
Rem Test PUT and GET with all combinations of:
Rem
Rem     Byte and record I/O
Rem     String and Block I/O
Rem     With and without a pos parameter

Sub TestPutGet()

  Rem Byte I/O (Open For Binary)

  Rem Create a file containing "abcxxxghij", &H1234, &H12345678

  Open "PUTGET.BIN" For Binary Access Write As 2
  Call CheckFileError ("Error opening PUTGET.BIN for output")

  Private S$ = "abcde"
  Put 2, , S$ + "fghij" : Call CheckFileError ("Error writing string")
  Private X& = &H12345678
  Put 2, , X& : Call CheckFileError ("Error writing block")
  Put 2, 4, "xxx" : Call CheckFileError ("Error writing string")
  Put 2, 13, X& : Call CheckFileError ("Error writing block")
  Close 2 : Call CheckFileError ("Error closing file")

  Rem Read it back and check that we get what we expect

  Open "PUTGET.BIN" For Binary Access Read As 5
  Call CheckFileError ("Error opening PUTGET.BIN for input")
  Get 5, , S$, 10 : Call CheckFileError ("Error reading string")
  If S$ <> "abcxxxghij" Then Print "Test 1 failed" : Exit
  X& = 0
  Get 5, , X& : Call CheckFileError ("Error reading block")
  If X& <> &H12341234 Then Print "Test 2 failed" : Exit

  Get 5, 3, S$, 5 : Call CheckFileError ("Error reading string")
  If S$ <> "cxxxg" Then Print "Test 3 failed" : Exit

  X& = 0
  Get 5, 12, X& : Call CheckFileError ("Error reading block")
  If X& <> &H34123456 Then Print "Test 4 failed" : Exit

  Close 5 : Call CheckFileError ("Error closing file")
  Kill "PUTGET.BIN" : Call CheckFileError ("Error deleting file")

  Rem Record I/O (Open For Random)

  Rem Create a file with five 11-byte records:
  Rem
  Rem "nopqrst"      6E 6F 70 71 72 73 74 00 00 00 00
  Rem                89 AB CD EF 00 00 00 00 00 00 00
  Rem                FE DC BA 98 00 00 00 00 00 00 00
  Rem                00 00 00 00 00 00 00 00 00 00 00
  Rem "nopqrstuvwx"  6E 6F 70 71 72 73 74 75 76 77 78

  Open "PUTGET.REC" For Random Access Write As 5 Len=11
  Call CheckFileError ("Error opening PUTGET.REC for output")

  S$ = "nopqrst"
  Put 5, , S$ : Call CheckFileError ("Error writing string")
  X& = &H89ABCDEF
  Put 5, , X& : Call CheckFileError ("Error writing block")
  Put 5, 5, S$ + "uvwx" : Call CheckFileError ("Error writing string")
  X& = &HFEDCBA98
  Put 5, 3, X& : Call CheckFileError ("Error writing block")

  Close 5 : Call CheckFileError ("Error closing file")

  Rem Read it back as 11 5-byte records and check that we get what we expect:
  Rem
  Rem "nopqr"    6E 6F 70 71 72
  Rem "st"       73 74 00 00 00
  Rem            00 89 AB CD EF
  Rem            00 00 00 00 00
  Rem            00 00 FE DC BA
  Rem            98 00 00 00 00
  Rem            00 00 00 00 00
  Rem            00 00 00 00 00
  Rem     "n"    00 00 00 00 6E
  Rem "opqrs"    6F 70 71 72 73
  Rem "tuvwx"    74 75 76 77 78

  Open "PUTGET.REC" For Random Access Read As 2 Len=5
  Call CheckFileError ("Error opening PUTGET.REC for input")

  Get 2, , S$, 5 : Call CheckFileError ("Error reading string")
  If S$ <> "nopqr" Then Print "Test 5 failed" : Exit
  Get 2, , X& : Call CheckFileError ("Error reading block")
  If X& <> &H73740000 Then Print "Test 6 failed" : Exit
  Get 2, 10, S$, 3 : Call CheckFileError ("Error reading string")
  If S$ <> "opq" Then Print "Test 7 failed" : Exit
  Get 2, 5, X& : Call CheckFileError ("Error reading block")
  If X& <> &HFEDC Then Print "Test 8 failed" : Exit

  Close 2 : Call CheckFileError ("Error closing file")

  Kill "PUTGET.REC" : Call CheckFileError ("Error deleting file")

  Print "All tests passed on drive " CurDrive ":"

End Sub
