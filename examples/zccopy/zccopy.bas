Rem  BasicCard Sample Source Code
Rem  ------------------------------------------------------------------
Rem  Copyright (C) 1997-2001 ZeitControl GmbH

Rem  You have a royalty-free right to use, modify, reproduce and 
Rem  distribute the Sample Application Files (and/or any modified 
Rem  version) in any way you find useful, provided that you agree 
Rem  that ZeitControl GmbH has no warranty, obligations or liability
Rem  for any Sample Application Files.
Rem  ------------------------------------------------------------------

Rem Completed by Didier Donsez, Didier.Donsez@imag.fr

REM Copy file from or to a BasicCard file system

#include commands.def
#Include CARDUTIL.DEF
#Include COMMERR.DEF
#include fileio.def
#Include MISC.DEF ' for timing function

#include fileerr.def
#include local.def
#include chckport.bas

Option Explicit

Static filelen%  as Integer
Static readlen%  as Integer
Static data$   	 as String

Static starttime as DateTime
Static endtime  as DateTime

Static sourcefile$   as String
Static targetfile$   as String

Static blocstr$      as String
Static blocksize@    as Byte
Static blocksizemax@ = 248 ' else FileError = feCommsError: SW1-SW2 = swCommandTooLong

Rem Analyse Parameters

if (nParams<2) then goto usage
if(Param$(1) = "-b") then
	if (nParams<>4) then goto usage
	blocksize@ = val&(Param$(2))
	if (blocksize@>blocksizemax@) then goto usage
	sourcefile$ = Param$(3)
	targetfile$ = Param$(4)
else
	if (nParams<>2) then goto usage
	blocksize@ = 128
	sourcefile$ = Param$(1)
	targetfile$ = Param$(2)
end if

call CheckPort()
ResetCard
Call CheckSW1SW2()
Open sourcefile$ For Binary Access Read Shared As #1
Call CheckFileError(sourcefile$)
Seek #1, 1
Call CheckFileError(sourcefile$)
REM try to kill target 
Kill targetfile$
FileError=0
Open targetfile$ For Binary Access Write Lock read Write As #2
Call CheckFileError(targetfile$)
Seek #2, 1
Call CheckFileError(targetfile$)
filelen%=len(#1)
Call CheckFileError(sourcefile$)

Call GetDateTime (starttime)

Static loops% = 0

while (filelen%>0)
	if (filelen%>blocksize@) then
		readlen%=blocksize@
		filelen%=filelen%-blocksize@
	else
		readlen%=filelen%
		filelen%=0
	end if
	Get #1,, data$, readlen%
	Call CheckFileError(sourcefile$)
	Put #2,, data$
	Call CheckFileError(targetfile$)
      loops% = loops% + 1
wend

Call GetDateTime (endtime)

close #1, #2

print "copy " sourcefile$ " to " targetfile$ " in " TimeInterval(starttime, endtime) " milliseconds (" loops% " loops)"
exit

usage:
	print "syntax:  zccopy [-b blocksize] sourcefile destfile"
	print "syntax:  blocksize must be less than " blocksizemax@ " bytes"
	print "example: zccopy -b 128 @@:\test1 c:\test1copy.dat"
	exit
