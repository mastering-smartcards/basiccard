Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem  BADKEYS.BAS
Rem
Rem  The keys in this file are different from those in GOODKEYS.BAS, so an
Rem  attempt to use them with a BasicCard program that #Includes GOODKEYS.BAS
Rem  should end in failure.

Declare Key 99 = &H93,&H76,&H07,&H37,&HBA,&H95,&H83,&H0C
Declare Key 100(16) = &HEA,&H93,&HCD,&H7F,&H1E,&H9D,&H25,&HB8,_
        &H6B,&HA9,&HAF,&H3C,&HE0,&HF8,&H47,&HFA
