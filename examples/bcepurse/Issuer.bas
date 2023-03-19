Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem  Personalisation program for the ZeitControl DebitCard
Rem
Rem  Prompts the user for name, PIN, and balance, and personalises a DebitCard

Option Explicit
Option Base Explicit

#Include EPURSE.DEF  ' Declarations common to BasicCard and Terminal programs
rem #Include DEALER.KEY
rem #Include ISSUER.KEY

#Include CARDUTIL.DEF
#Include COMMERR.DEF
#Include COLOURS.DEF

Call WaitForCard()
ResetCard : Call CheckSW1SW2()

Rem  Check that the application name is correct
Private Name$ : Call GetApplicationID (Name$) : Call CheckSW1SW2()
If Name$ <> ApplicationName$ Then Print "This is not a ePurse Card !" : Exit

Rem  Get the customer name

Private PIN$, Balance$, Amount&, Len@

FgCol = Cyan : Print "Customer name (Enter to abort): ";
FgCol = BrightYellow : Line Input Name$
If Name$ = "" Then Exit

Rem  Get the PIN

Do
    FgCol = Cyan : Print "PIN (Enter to abort): ";
    FgCol = BrightYellow : Line Input PIN$
    If PIN$ = "" Then Exit
    If Len (PIN$) = 4 Then Exit Do
    FgCol = Red : Print "PIN must be 4 characters long"
Loop

Rem  Get the initial balance

Do
    FgCol = Cyan : Print "Initial balance (e.g. 12.50): ";
    FgCol = BrightYellow : Line Input Balance$
    FgCol = BrightWhite
    Balance$ = Trim$ (Balance$)
    If Balance$ = "" Then Print "Personalization aborted" : Exit

    Rem  Convert Balance$ to Long (in pfennigs) via a Single value (in marks)
    Amount& = (100 * Val! (Balance$, Len@)) + 0.5
    If Len@ = Len (Balance$) Then Exit Do ' Exit if all characters were used
    Print "Invalid number"
Loop

Rem  Send the data to the card. The card only accepts issuer data that is
Rem  encrypted with the Issuing Key (Key 00):

Rem  Try automatic algorithm selection first:
Rem Call StartEncryption (P1=0, P2=0, Rnd)
Rem If SW1SW2 = swUnknownAlgorithm Then
  Rem  That didn't work, so it must be a Compact BasicCard:
  Rem Call StartEncryption (P1=&H12, P2=0, Rnd)
Rem End If
Rem Call CheckSW1SW2()

Open Log File "issuer.log"

Call PersonaliseCard (Amount&, PIN$, Name$) : Call CheckSW1SW2()
Rem Call EndEncryption() : Call CheckSW1SW2()

Close Log File

Print "Personalization successful."
