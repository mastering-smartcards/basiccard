Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem FILETEST.BAS
Rem
Rem Test keyed access conditions in the BasicCard
Rem
Rem File KEYCARD.BAS contains the BasicCard source, so
Rem
Rem     ZCDOS -CFILECARD FILETEST

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

Private ID$ : Call GetApplicationID (ID$) : Call CheckSW1SW2()
If ID$ <> "OPENCARD" Then Print "Card FILECARD is required for this test" : Exit
ResetCard : Call CheckSW1SW2()
ChDrive "@"
Private F, S$

Open "DATA1.TXT" As F
If FileError == feAccessDenied Then Print "Access Denied to DATA1" : Exit
FileError = feFileOK

Read Key File "GOODKEYS.BAS" : Call CheckFileError ("Error reading key file")
Call StartEncryption (P2 = 99, Rnd) : Call CheckSW1SW2()
F= Open "DATA1.TXT" : Call CheckFileError ("Error opening DATA1")
Line Input #F, S$ : Call CheckFileError ("Error reading DATA1")
Print S$
Close F : Call CheckFileError ("Error closing DATA1")
Call EndEncryption() : Call CheckSW1SW2()

Rem Ouverture et Création d’un fichier
F = Open "DATA3.TXT" For Output : Call CheckFileError ("Error opening for output")
Print #F, "abcdefg" : Print #F, "hijklem" : Call CheckFileError ("Error writing to file")
Close F : Call CheckFileError ("Error closing file")
F = Open "DATA3.TXT" : Call CheckFileError ("Error opening for input")
Line Input #F, S$ : Call CheckFileError ("Error reading a line")
Print "DATA3.TXT contains:",S$  ' abcdefg
Line Input #F, S$ : Call CheckFileError ("Error reading a line")
Print "DATA3.TXT contains:",S$  ' hijklem
Line Input #F, S$
If FileError == feReadError Then Print "ReadError since no more input"
FileError = feFileOK
Close : Call CheckFileError ("Error closing all files")
Kill "DATA3.TXT" : Call CheckFileError ("Error deleting file")


Print "All tests passed. Press any key:" ; : While InKey$ = "" : Wend
