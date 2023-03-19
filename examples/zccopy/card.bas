Rem  BasicCard Sample Source Code
Rem  ------------------------------------------------------------------
Rem  Copyright (C) 1997-2001 ZeitControl GmbH

Rem  You have a royalty-free right to use, modify, reproduce and 
Rem  distribute the Sample Application Files (and/or any modified 
Rem  version) in any way you find useful, provided that you agree 
Rem  that ZeitControl GmbH has no warranty, obligations or liability
Rem  for any Sample Application Files.
Rem  ------------------------------------------------------------------


#include keys.bas
#include local.def

Dir "\"
	Read Unlock
	Write Unlock
	File "test1"
	Read Unlock
	Write Lock
	"Test1"
	File "test2"
	Read Unlock
	Write Unlock
	"Test2"
	Dir "readonly"
		Read Unlock
		Write Lock
		File "test1"
		Read Unlock
		Write Unlock
		"Test11"
		File "test2"
		Read Lock
		Write Lock
		"Test12"
	End dir
End Dir

Command &HFE &H02 Encrypt(ByRef data$ as String*64, Key% as Integer)
	Private in$ as String
	Private i% as Integer
	Private out$ as String
	out$ = ""
	for i%=1 to 8
		in$=mid$(data$, ((i%-1)*8)+1, 8)
		in$ = des(+3, Key%, in$)
		out$ = out$ + in$
	next i%
	data$ = out$
End command

Command &HFE &H04 Decrypt(ByRef data$ as String*64, Key% as Integer)
	Private in$ as String
	Private i% as Integer
	Private out$ as String
	out$ = ""
	for i%=1 to 8
		in$=mid$(data$, ((i%-1)*8)+1, 8)
		in$ = des(-3, Key%, in$)
		out$ = out$ + in$
	next i%
	data$ = out$
End command