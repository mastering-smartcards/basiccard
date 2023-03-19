Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem An Enhanced BasicCard with key-protected files
Rem
Rem The name and contents of each data file are an ASCII description of its
Rem access conditions.
Rem
Rem Command &H20 &H04 EnableKey (Key@, Counter@)
Rem
Rem This command executes an EnableKey statement inside the card

Declare ApplicationID = "FILECARD"

#Include GOODKEYS.BAS

Command &H20 &H04 EnableKey (Key@, Counter@)
  Enable Key Key@ (Counter@)
End Command

Dir "\" 			' crée 2 fichiers dans le répertoire racine
  File "Data1"          			' File name
  Read Lock Key = 99,100                 	' Access conditions
  "Contenu du fichier Data1"              	' Contents
  File "Data2"   			' File name
  Read Write Lock Key = 99,100        ' Access conditions
  "Contenu du fichier Data2"        	' Contents
End Dir
