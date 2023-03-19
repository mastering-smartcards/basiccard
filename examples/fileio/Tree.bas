Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem TREE.BAS
Rem
Rem ZC-Basic program to list a directory tree. To run:
Rem
Rem     ZCDOS TREE [path [output]]
Rem
Rem     path: the directory to list. Default is the current directory.
Rem     output: the output file. If absent, output is displayed on the screen.
Rem
Rem Try e.g. ZCDOS -CTREECARD TREE @:

Option Explicit

#NoList
#Include FILEERR.DEF
#Include COMMERR.DEF
#List

Declare Sub ListDir (Dir$, Prefix$)

Public F ' File number of output file

Private TopDir$
If nParams <> 0 Then
  TopDir$ = Param$ (1)
  If TopDir$ (1) = "@" Then ResetCard : Call CheckSW1SW2()
End If

If nParams < 2 Then
  F = 0 ' Output to screen
Else
  F = Open Param$ (2) For Output
  Call CheckFileError ("Error opening output file")
End If

Rem If we're not outputting to the screen, display a progress monitor
If F <> 0 And TopDir$ <> "\" Then Print TopDir$ ;

Print #F, TopDir$ ;
Call ListDir (TopDir$, Space$ (Len (TopDir$)))

Rem Clear the progress monitor
If F <> 0 Then
  Private nSpaces : nSpaces = CursorX - 1
  CursorX = 1
  Print Space$ (nSpaces)
End If

Rem Sub ListDir (Dir$, Prefix$)
Rem
Rem List a directory and all its sub-directories
Rem
Rem Dir$: the path name of the directory (optionally ending in "\")
Rem Prefix$: Listing prefix, to display the tree recursively

Sub ListDir (Dir$, Prefix$)

  Private nFiles, File$, I

  Rem Add a trailing backslash if necessary (unless it's the current directory)
  If Dir$ <> "" And Right$ (Dir$, 1) <> "\" Then Dir$ = Dir$ + "\"

  Rem Get the number of files and sub-directories
  nFiles = Dir (Dir$ + "*.*") : Call CheckFileError ("Error in directory search")
  If nFiles = 0 Then Print #F : Call CheckFileError ("Error printing results")

  Private ScreenX : ScreenX = CursorX ' For a flicker-free progress monitor

  Rem List each file and sub-directory

  For I = 1 To nFiles

    Rem Print the next file in the directory, with a suitable link
    File$ = Dir (Dir$ + "*.*", I) : Call CheckFileError ("Error in directory search")
    If nFiles = 1 Then
      Print #F, "ÄÄÄ" ;
    ElseIf I = 1 Then
      Print #F, "ÄÂÄ" ;
    Else
      Print #F, Prefix$ ;
      If I = nFiles Then Print #F, " ÀÄ" ; : Else Print #F, " ÃÄ" ;
    End If
    Print #F, File$ ;
    Call CheckFileError ("Error printing results")

    Rem If it's a sub-directory, list its contents too
    Private Attr
    Attr = GetAttr (Dir$ + File$) : Call CheckFileError ("Error in GetAttr")

    If Attr And faDirectory Then
      Rem If it's in the BasicCard, do we have read access?
      If Attr And faCardFile Then
        Private LI As LockInfo 
        Get Lock Dir$ + File$, LI : Call CheckFileError ("Error getting lock info")
        If LI.ReadLock <> liAllowed Or LI.CustomLock = liLocked Then
          Rem No read access to this directory
          Print #F, "ÄÄ(Access Denied)"
          GoTo NextFile
        End If
      End If

      Rem Recursively display the sub-directory
      Private Ext$ ' Extension to Prefix$ for sub-directory listing
      If I = nFiles Then Ext$ = "   " : Else Ext$ = " ³ "
      Ext$ = Ext$ + Space$ (Len (File$))

      If F <> 0 Then
        Rem Update the progress monitor
        If CursorX = ScreenX Then Print "\" ;

        Rem We don't want to wipe the previous name before we print this one,
        Rem as this creates flicker. So just wipe the extra characters:
        Private EndX : EndX = ScreenX + Len (File$) + 1
        If CursorX > EndX Then
          Private nSpaces : nSpaces = CursorX - EndX
          CursorX = EndX
          Print Space$ (nSpaces) ;
        End If
        CursorX = ScreenX + 1 : Print File$ ;
      End If

      Rem List the sub-directory
      Call ListDir (Dir$ + File$, Prefix$ + Ext$)
    Else
      Print #F ' Data file, not directory: print new line
    End If

NextFile:

    Call CheckFileError ("Error printing results")

    If InKey$ <> "" Then Exit ' Check for user interrupt

  Next I

  Rem Clear the progress monitor
  If F <> 0 Then
    nSpaces = CursorX - ScreenX
    CursorX = ScreenX
    Print Space$ (nSpaces) ;
    CursorX = ScreenX
  End If

End Sub
