Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem An Enhanced BasicCard with a directory tree:
Rem
Rem   D1���Sub1���SubSub1���Data1
Rem      �      �         ��Data2
Rem      �      ��SubSub2���Data3
Rem      �      �         ��Data4
Rem      �      ��Data5
Rem      ��Sub2���SubSub3���Data6
Rem             �         ��Data7
Rem             ��SubSub4���Data8
Rem             �         ��Data9
Rem             ��Data10

Declare ApplicationID = "TREECARD"

Dir "D1"

  Dir "Sub1"
    Dir "SubSub1"
      File "Data1"
      File "Data2"
    End Dir
    Dir "SubSub2"
      File "Data3"
      File "Data4"
    End Dir
    File "Data5"
  End Dir

  Dir "Sub2"
    Dir "SubSub3"
      File "Data6"
      File "Data7"
    End Dir
    Dir "SubSub4"
      File "Data8"
      File "Data9"
    End Dir
    File "Data10"
  End Dir

End Dir
