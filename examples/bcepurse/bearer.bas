Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem  Credit/debit program for the ZeitControl ePurse

Option Explicit
Option Base Explicit

#Include EPURSE.DEF ' Declarations common to BasicCard and Terminal programs
rem #Include DEALER.KEY

#Include CARDUTIL.DEF
#Include COMMERR.DEF
#Include COLOURS.DEF

Open Log File "Bearer.log"

Call WaitForCard()
ResetCard : Call CheckSW1SW2()

Rem  Check that the application name is correct
Private Name$ : Call GetApplicationID (Name$) : Call CheckSW1SW2()
If Name$ <> ApplicationName$ Then Print "This is not a ePurse Card!" : Exit

Rem  Display the card data

Private Amount&, PINCount
Call GetCardData (Amount&, PINCount, Name$)
If SW1SW2 = swNotPersonalised Then Print "Card has not been personalised": Exit
Call CheckSW1SW2()

Call GetBalance(Amount&)
If SW1SW2 = swNotPersonalised Then Print "Card has not been personalised": Exit
Call CheckSW1SW2()


FgCol = Cyan: Print "Customer: " ; : FgCol = BrightYellow: Print Name$
FgCol = Cyan: Print "Balance: ";
FgCol = BrightYellow: Print Str$ (Amount& / 100) "." ;
If Amount& Mod 100 < 10 Then Print "0" ;
Print Str$ (Amount& Mod 100)

Rem  Try automatic algorithm selection first:
Rem Call StartEncryption (P1=0, P2=1, Rnd)
Rem If SW1SW2 = swUnknownAlgorithm Then
  Rem  That didn't work, so it must be a Compact BasicCard:
  Rem Call StartEncryption (P1=&H12, P2=1, Rnd)
Rem End If
Rem Call CheckSW1SW2()

Rem  Verify the PIN

Private PIN$
Do ' PIN attempts
  PIN$ = ""
  FgCol = Cyan: Print "Enter PIN (Esc to abort): " ;
  FgCol = BrightYellow
  Do ' Keys pressed
    Private Key$
    Key$ = InKey$
    Select Case Key$

      Case Chr$ (27) : Print : Exit ' Esc

      Case Chr$ (13) ' Enter
        If Len (PIN$) = 4 Then Print: Exit Do ' Exit Keys pressed loop

      Case Chr$ (8) ' Backspace
        If Len (PIN$) <> 0 Then
          PIN$ = Left$ (PIN$, Len (PIN$) - 1)
          CursorX = CursorX - 1
          Print " " ;
          CursorX = CursorX - 1
        End If

      Case Else
        If Len (Key$) = 1 And Len (PIN$) <> 4 Then
          Print "*" ;
          PIN$ = PIN$ + Key$
        End If

    End Select
  Loop ' Keys pressed

Call VerifyPIN (PIN$)
Select Case SW1SW2
  Case swPINErrorsExceeded : Print "Too many PIN errors - card disabled" : Exit
  Case swInvalidPIN: Print "Invalid PIN"
  Case Else : Call CheckSW1SW2() : Exit Do ' Exit PIN attempts loop
End Select

Loop ' PIN attempts

Rem  Get the action to perform

FgCol = Cyan: Print "Action (e.g. +50 or -10.25): " ;
Private Action$, Len@
FgCol = BrightYellow: Line Input Action$
Action$ = Trim$ (Action$) ' Remove leading and trailing spaces
If Action$ = "" Then Exit

Select Case Left$ (Action$, 1)

  Case "+"
    Amount& = (100 * Val! (Mid$ (Action$, 2), Len@)) + 0.5
    Call IncreaseAmount (Amount&) : Call CheckSW1SW2()

  Case "-"
    Amount& = (100 * Val! (Mid$ (Action$, 2), Len@)) + 0.5
    Call DecreaseAmount (Amount&) : Call CheckSW1SW2()

  Case Else
    FgCol = BrightRed: Print "Invalid action"

End Select

Close Log File

REM Didier : End Encrytion is missing