Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem NAMETEST.BAS
Rem
Rem Test NAME statement in the BasicCard
Rem
Rem To run: ZCDOS -COPENCARD NAMETEST

Option Explicit

#NoList
#Include FILEERR.DEF
#Include COMMERR.DEF
#List

ResetCard : Call CheckSW1SW2()
Private ID$ : Call GetApplicationID (ID$) : Call CheckSW1SW2()
If ID$ <> "OPENCARD" Then Print "Card OPENCARD is required for this test" : Exit

Rem Construct a directory path 245 characters long
Rem (50 + 40 + 50 + 60 + 40 + five backslashes)

ChDrive ("@")
MkDir "01234567890123456789012345678901234567890123456789" ' 50
Call CheckFileError ("Error in MkDir #1")
ChDir "01234567890123456789012345678901234567890123456789"
Call CheckFileError ("Error in ChDir #1")
MkDir "0123456789012345678901234567890123456789" ' 40
Call CheckFileError ("Error in MkDir #2")
ChDir "0123456789012345678901234567890123456789"
Call CheckFileError ("Error in ChDir #2")
MkDir "012345678901234567890123456789012345678901234567890123456789" ' 60
Call CheckFileError ("Error in MkDir #3")
ChDir "012345678901234567890123456789012345678901234567890123456789"
Call CheckFileError ("Error in ChDir #3")
MkDir "01234567890123456789012345678901234567890123456789" ' 50
Call CheckFileError ("Error in MkDir #4")
ChDir "01234567890123456789012345678901234567890123456789"
Call CheckFileError ("Error in ChDir #4")
MkDir "0123456789012345678901234567890123456789" ' 40
Call CheckFileError ("Error in MkDir #5")
ChDir "0123456789012345678901234567890123456789"
Call CheckFileError ("Error in ChDir #5")

Rem Backslash + 8 more characters = 254, so this should succeed
MkDir "01234567"
Call CheckFileError ("Error in MkDir #6")

Rem Backslash + 9 more characters = 255, so this shoudl fail
MkDir "012345678"
If FileError <> feNameTooLong Then Print "Failed test #1" : Exit

Rem We must reset FileError to zero here, to detect subsequent errors
FileError = 0

RmDir "01234567"
Call CheckFileError ("Error in RmDir #6")

Rem Make a small tree \D1\D2
ChDir "\"
Call CheckFileError ("Error in ChDir #7")
MkDir "D1"
Call CheckFileError ("Error in MkDir #7")
MkDir "D1\D2"
Call CheckFileError ("Error in MkDir #8")

Rem Try and move D1 into itself
Name "D1" As "D1\"
If FileError <> feRecursiveRename Then Print "Failed test #2" : Exit
FileError = 0

Rem Try and rename D1 into itself
Name "D1" As "D1\NEWNAME"
If FileError <> feRecursiveRename Then Print "Failed test #3" : Exit
FileError = 0

Rem Try and move D1 into a sub-directory of itself
Name "D1" As "D1\D2\"
If FileError <> feRecursiveRename Then Print "Success error 4" : Exit
FileError = 0

Rem Check that a legitimate move command succeeds
Name "D1" As "01234567890123456789012345678901234567890123456789\"
Call CheckFileError ("Error in Name #9")

Rem Move the long-name top-level directory down by 9 characters, to
Rem create a 254-character path indirectly
MkDir "01234567"
Call CheckFileError ("Error in MkDir #10")
Name "01234567890123456789012345678901234567890123456789" As "01234567\"
Call CheckFileError ("Error in Name #10")

Rem OK, that worked. Undo it:
Name "01234567\01234567890123456789012345678901234567890123456789" As "\"
Call CheckFileError ("Error in Name #11")
RmDir "01234567"
Call CheckFileError ("Error in RmDir #11")

Rem One more character, and it should fail
MkDir "012345678"
Call CheckFileError ("Error in MkDir #12")
Name "01234567890123456789012345678901234567890123456789" As "012345678\"
If FileError <> feNameTooLong Then Print "Failed test #4" : Exit
FileError = 0

Print "All tests passed. Press any key:" ; : While InKey$ = "" : Wend
