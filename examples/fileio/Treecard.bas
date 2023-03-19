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
Rem   D1ÄÂÄSub1ÄÂÄSubSub1ÄÂÄData1
Rem      ³      ³         ÀÄData2
Rem      ³      ÃÄSubSub2ÄÂÄData3
Rem      ³      ³         ÀÄData4
Rem      ³      ÀÄData5
Rem      ÀÄSub2ÄÂÄSubSub3ÄÂÄData6
Rem             ³         ÀÄData7
Rem             ÃÄSubSub4ÄÂÄData8
Rem             ³         ÀÄData9
Rem             ÀÄData10

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
