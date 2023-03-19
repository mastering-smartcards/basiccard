Rem Gambling BasicCard Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 2002 Didier DONSEZ
Rem ------------------------------------------------------------------

Rem  GAMBLING CARD

Rem  Bet program for the Gambling Card






Option Explicit
Option Base Explicit

#Include GAMBLING.DEF ' Declarations common to BasicCard and Terminal programs
rem #Include DEALER.KEY

#Include CARDUTIL.DEF
#Include COMMERR.DEF
#Include COLOURS.DEF

Open Log File "Gambler.log"

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


Do '  Get the action to perform

FgCol = Cyan: Print "Action (e.g. ! or +50 or -10.25 or *10 or pileface or goldrush or exit): " ;
Private Action$, Len@
Private LastAction$=""

FgCol = BrightYellow: Line Input Action$
Action$ = Trim$ (Action$) ' Remove leading and trailing spaces

If Action$ = "!" Then
    Action$=LastAction$
Else
    LastAction$=Action$
End If

Select Case Left$ (Action$, 1)

  Case "+"
    Rem Credit
    Amount& = (100 * Val! (Mid$ (Action$, 2), Len@)) + 0.5
    Call IncreaseAmount (Amount&) : Call CheckSW1SW2()

  Case "-"
    Rem Debit
    Amount& = (100 * Val! (Mid$ (Action$, 2), Len@)) + 0.5
    Call DecreaseAmount (Amount&) : Call CheckSW1SW2()

  Case "*"
    Rem Bet
    Amount& = (100 * Val! (Mid$ (Action$, 2), Len@)) + 0.5
    Call Bet(Amount&) : Call CheckSW1SW2()
    If Amount& = 0 Then
        FgCol = BrightRed: Print "Loss: ";
    Else
        FgCol = BrightRed: Print "Win : ";
        FgCol = BrightYellow: Print Str$ (Amount& / 100) "." ;
        If Amount& Mod 100 < 10 Then Print "0" ;
        Print Str$ (Amount& Mod 100)
    End If

  Case "p"
    Rem SetWinnings and SetBounds for Pile ou Face (0 or 2)
    Call SetWinnings(2,0,2,-1,-1,-1,-1,-1,-1,-1,-1) : Call CheckSW1SW2()
    Call SetBounds(2,2,4,-1,-1,-1,-1,-1,-1,-1,-1) : Call CheckSW1SW2()

  Case "g"
    Rem SetWinnings and SetBounds for Gold Rush (0 or 2 or 5)
    Call SetWinnings(3,0,2,5,-1,-1,-1,-1,-1,-1,-1) : Call CheckSW1SW2()
    Call SetBounds(3,6,8,9,-1,-1,-1,-1,-1,-1,-1) : Call CheckSW1SW2()

  Case "e"
    Rem Exit
    Exit Do

  Case Else
    FgCol = BrightRed: Print "Invalid action"

End Select

Close Log File

Call GetBalance(Amount&)
FgCol = Cyan: Print "Balance: ";
FgCol = BrightYellow: Print Str$ (Amount& / 100) "." ;
If Amount& Mod 100 < 10 Then Print "0" ;
Print Str$ (Amount& Mod 100)


Loop ' Action

REM Didier : End Encrytion is missing