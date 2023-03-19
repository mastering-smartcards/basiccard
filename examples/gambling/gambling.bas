Rem Gambling BasicCard Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 2002 Didier DONSEZ
Rem ------------------------------------------------------------------

Rem  GAMBLING CARD

Rem This file system could be use to store a history file
Dir "\" ' Set the access conditions on the root directory
  Write Unlock
End Dir

Option Explicit ' Disable use of undefined variable names
Option Base 0   ' Arrays start at 0

#Include GAMBLING.DEF ' Declarations common to BasicCard and Terminal programs
rem #Include DEALER.KEY
rem #Include ISSUER.KEY

#Include COMMANDS.DEF
#include PReader.def

Declare ApplicationID = ApplicationName$
Disable Encryption &H11

Rem  Permanent data

Eeprom Personalised = False
Eeprom Balance As Long
Eeprom PIN As String*4
' Change following line to set your initial master PIN
Eeprom MasterPIN As String*6 = "123456"
Eeprom CustomerName$
Eeprom PINErrors

Eeprom WinningRatio As Long

Rem  EEPROM shadow data, to ensure that Balance is always valid
Rem
Rem  See "1.4.4 Permanent Data" in the BasicCard manual.

Eeprom ShadowBalance As Long
Eeprom Committed = False

Rem  Public data (re-initialised when card is reset)

Public PINVerified = False
Public MasterPINVerified = False

Public Bounds(7) As Long
Public Winnings(7) As Long
Public NumberOfBounds As Byte = 0
Public NumberOfWinnings As Byte = 0
Public isConsistent@ = False

Rem  Subroutine declaration

Declare Sub ChangeBalance (NewBalance As Long)
Declare Sub CheckConsistency()
Declare Sub CheckAlgorithm()

Rem  Start-up code: clean up if an EEPROM write was interrupted
Rem
Rem  See "1.4.4 Permanent Data" in the BasicCard manual.

If Committed Then
  Balance = ShadowBalance
  Committed = False
End If

Command &H80 &H00 PersonaliseCard (Amount As Long, NewPIN As String*4, Name$)
rem  Call CheckAlgorithm()
rem   If KeyNumber <> 0 Then SW1SW2 = swIssuingKeyRequired : Exit
  Personalised = False ' In case power is lost in the next three statements
  Balance = Amount
  CustomerName$ = Name$
  PIN = NewPIN
  Personalised = True
End Command

Command &H80 &H02 VerifyPIN (TestPIN As String*4)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
rem  If KeyNumber <> 0 And PINErrors > MaxPINErrors Then _
  If PINErrors > MaxPINErrors Then SW1SW2 = swPINErrorsExceeded : Exit
  If TestPIN = PIN Then PINErrors = 0 : PINVerified = True : Exit
  PINErrors = PINErrors + 1
  SW1SW2 = swInvalidPIN
  PINVerified = False
End Command

Command &H80 &H04 IncreaseAmount (Diff As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
  If Not (PINVerified OR MasterPINVerified) Then SW1SW2 = swPINRequired : Exit
  Call ChangeBalance (Balance + Diff)
End Command

Command &H80 &H06 DecreaseAmount (Diff As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
  If Not (PINVerified OR MasterPINVerified) Then SW1SW2 = swPINRequired : Exit
  If Diff > Balance Then SW1SW2 = swInsufficientFunds : Exit
  Call ChangeBalance (Balance - Diff)
End Command

Command &H80 &H08 ChangePIN (NewPIN As String*4)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
  If Not (PINVerified OR MasterPINVerified) Then SW1SW2 = swPINRequired : Exit
  PIN = NewPIN
End Command

Command &H80 &H0A GetCardData (Amount As Long, PINCount, Name$)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
  Amount = Balance
  PINCount = MaxPINErrors - PINErrors
  Name$ = CustomerName$
End Command

Command &H80 &H20 GetBalance (Amount As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
  Amount = Balance
End Command

Command &H80 &H22 Debit (Amount As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
  If Not (PINVerified OR MasterPINVerified) Then SW1SW2 = swPINRequired : Exit
  If Amount > Balance Then SW1SW2 = swInsufficientFunds : Exit
  Call ChangeBalance (Balance - Amount)
  Amount=Balance ' new balance is returned in amount param
End Command

Command &H80 &H24 Credit (Amount As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
  If Not (PINVerified OR MasterPINVerified) Then SW1SW2 = swPINRequired : Exit
  Call ChangeBalance (Balance + Amount)
  Amount=Balance ' new balance is returned in amount param
End Command

Command &H80 &H26 Bet(betAmount As Long)
  Private b As Byte
  Private r As Long
  Private winning As Long

  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
  If Not (PINVerified OR MasterPINVerified) Then SW1SW2 = swPINRequired : Exit
  If betAmount > Balance Then SW1SW2 = swInsufficientFunds : Exit

  rem check if Bounds and Winnings are consistent
  Call CheckConsistency()
    
  rem next random to decide between bank and (win or loss)
  r=Abs(Rnd) Mod 100
  if r<WinningRatio then
        rem next random to decide between win and loss
        r=Abs(Rnd) Mod Bounds(NumberOfBounds-1)

    rem win or lost in the winnings/bounds
    rem b is the bound
    for b=0 to (NumberOfBounds-1)
        If r<Bounds(b) Then
            Exit For
        End If
    Next b

    winning=Winnings(b)*betAmount
        rem winning may zero or positive (even negative)
  Else
    rem for the bank
    winning=0
  End If

  Call ChangeBalance (Balance - betAmount + winning)

  rem return the winning
  betAmount=winning

End Command

Command &H80 &H30 SetWinRatio(wr As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
    if wr>100 Then SW1SW2 = swInconsistentWinningRatio : Exit
    WinningRatio=wr
End Command

Command &H80 &H32 GetWinRatio(wr As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
    wr=WinningRatio
End Command

Command &H80 &H34 GetBounds(numbounds@, bound0&,bound1&,bound2&,bound3&,bound4&,bound5&,bound6&,bound7&,bound8&,bound9&)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()

    numbounds@=NumberOfBounds
    bound0& = Bounds(0)
    bound1& = Bounds(1)
    bound2& = Bounds(2)
    bound3& = Bounds(3)
    bound4& = Bounds(4)
    bound5& = Bounds(5)
    bound6& = Bounds(6)
End Command

Command &H80 &H36 SetBounds(numbounds@, bound0&,bound1&,bound2&,bound3&,bound4&,bound5&,bound6&,bound7&,bound8&,bound9&)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()

    isConsistent@ = False           ' Bounds and Winnings must be checked before betting
    NumberOfBounds = numbounds@
    Bounds(0) = bound0&
    Bounds(1) = bound1&
    Bounds(2) = bound2&
    Bounds(3) = bound3&
    Bounds(4) = bound4&
    Bounds(5) = bound5&
    Bounds(6) = bound6&
End Command

Command &H80 &H38 GetWinnings(numwinnings@, winning0&,winning1&,winning2&,winning3&,winning4&,winning5&,winning6&,winning7&,winning8&,winning9&)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()

    numwinnings@=NumberOfWinnings
    winning0& = Winnings(0)
    winning1& = Winnings(1)
    winning2& = Winnings(2)
    winning3& = Winnings(3)
    winning4& = Winnings(4)
    winning5& = Winnings(5)
    winning6& = Winnings(6)
End Command

Command &H80 &H3A SetWinnings(numwinnings@, winning0&,winning1&,winning2&,winning3&,winning4&,winning5&,winning6&,winning7&,winning8&,winning9&)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()

    isConsistent@ = False           ' Bounds and Winnings must be checked before betting
    NumberOfWinnings = numwinnings@
    Winnings(0) = winning0&
    Winnings(1) = winning1&
    Winnings(2) = winning2&
    Winnings(3) = winning3&
    Winnings(4) = winning4&
    Winnings(5) = winning5&
    Winnings(6) = winning6&
End Command


Rem  Sub CheckAlgorithm()
Rem
Rem  Check that the appropriate encryption algorithm is enabled (&H12
Rem  in the Compact BasicCard, &H21 in the Enhanced BasicCard)

Sub CheckAlgorithm()

#IfDef CompactBasicCard
  If Algorithm <> &H12 Then SW1SW2 = swEncryptionRequired : Exit
#ElseIfDef EnhancedBasicCard
  If Algorithm <> &H21 Then SW1SW2 = swEncryptionRequired : Exit
#Else
  If Algorithm <> &H23 Then SW1SW2 = swEncryptionRequired : Exit
#EndIf

End Sub
 
Rem  Sub ChangeBalance (NewBalance As Long)
Rem
Rem  Change the Balance variable, guarding against the possibility that
Rem  it is left in an inconsistent state by a sudden loss of power.
Rem
Rem  See "1.4.3 Permanent Data" in the BasicCard manual.

Sub ChangeBalance (NewBalance As Long)
  ShadowBalance = NewBalance
  Committed = True
  Balance = ShadowBalance
  Committed = False
End Sub

Sub CheckConsistency()
  Rem check values of Bounds() and Winnings()
  Private total&
  Private b As Byte

  If isConsistent@ = True Then Exit Sub       ' check during a previous call

  If NumberOfBounds < 2 Then GoTo Problem

  If NumberOfWinnings < 2 Then GoTo Problem

  If NumberOfWinnings <> NumberOfBounds Then GoTo Problem

  For b=0 To (NumberOfBounds-1)
        if Bounds(b) < 0 Then GoTo Problem
        if Winnings(b) < 0 Then GoTo Problem
  Next b

  For b=1 To (NumberOfBounds-1)
        if Bounds(b) <= Bounds(b-1) Then GoTo Problem
  Next b

  total&=Bounds(0)*Winnings(0)
  For b=1 To (NumberOfBounds-1)
        total&= total& + ((Bounds(b)-Bounds(b-1))*Winnings(b))
  Next b
  If total& > Bounds(NumberOfBounds-1) Then GoTo Problem

  rem All checks are passed
  isConsistent@ = True
  Exit Sub
   
  Problem:
  rem isConsistent@ = False
  SW1SW2 = swInconsistentBoundsAndWinnings
  Exit
End Sub

Command &H80 &H0E ChangeMasterPIN (NewPIN As String*6)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem   Call CheckAlgorithm()
  If Not MasterPINVerified Then SW1SW2 = swPINRequired : Exit
  MasterPIN = NewPIN
End Command

REM In opposition to normal PIN we use no PIN count, but
REM issuer key is required instead.
Command &H80 &H0C VerifyMasterPIN (TestPIN As String*6)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem   Call CheckAlgorithm()
rem  If KeyNumber <> 0 Then _
rem     SW1SW2 = swIssuingKeyRequired : Exit
  If TestPIN = MasterPIN Then MasterPINVerified = True : Exit
  SW1SW2 = swInvalidPIN
  MasterPINVerified = False
End Command
