Rem BasicCard Sample Source Code
Rem ------------------------------------------------------------------
Rem Copyright (C) 1997-1999 ZeitControl GmbH
Rem You have a royalty-free right to use, modify, reproduce and 
Rem distribute the Sample Application Files (and/or any modified 
Rem version) in any way you find useful, provided that you agree 
Rem that ZeitControl GmbH has no warranty, obligations or liability
Rem for any Sample Application Files.
Rem ------------------------------------------------------------------

Rem  DEBIT CARD
Rem
Rem  A BasicCard implementation of a secure debit card.
Rem
Rem  The card has two keys: Key 00 (Issuing Key) and Key 01 (Dealer Key).
Rem  In the Compact BasicCard, security algorithm &H11 is disabled, for
Rem  maximum security; all commands except GetCardData must be encrypted
Rem  with algorithm &H12.
Rem
Rem  The following commands are implemented:
Rem
Rem  PersonaliseCard (Amount As Long, PIN As String*4, Customer$)
Rem      Requires Issuing Key. A card can be personalised multiple times.
Rem
Rem  VerifyPIN (TestPIN As String*4)
Rem      This command must be called to enable the next three commands. The
Rem      commands remain enabled until the card is powered down or reset.
Rem      Requires Issuing Key or Dealer Key.
Rem
Rem  IncreaseAmount (Diff As Long)
Rem      Adds Diff to the amount on the card. Requires VerifyPIN.
Rem
Rem  DecreaseAmount (Diff As Long)
Rem      Subtracts Diff from the amount on the card. Requires VerifyPIN.
Rem
Rem  ChangePIN (NewPIN As String*4)
Rem      Changes the PIN. Requires VerifyPIN.
Rem
Rem  GetCardData (Amount As Long, PINCount As Byte, Customer$)
Rem      Returns the card data. PINCount@ is the number of attempts remaining
Rem      before the card must be returned to the issuer for personalisation.
Rem      (The number of failed PIN verifications allowed is given by the
Rem      constant MaxPINErrors.)
Rem
Rem  GetBalance (Amount As Long)
Rem      Returns the balance.



Option Explicit ' Disable use of undefined variable names

#Include EPURSE.DEF ' Declarations common to BasicCard and Terminal programs
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

Rem  EEPROM shadow data, to ensure that Balance is always valid
Rem
Rem  See "1.4.4 Permanent Data" in the BasicCard manual.

Eeprom ShadowBalance As Long
Eeprom Committed = False

Rem  Public data (re-initialised when card is reset)

Public PINVerified = False
Public MasterPINVerified = False

Rem  Subroutine declaration

Declare Sub ChangeBalance (NewBalance As Long)
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

Command &H80 &H24 Credit (Amount As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
  If Not (PINVerified OR MasterPINVerified) Then SW1SW2 = swPINRequired : Exit
  Call ChangeBalance (Balance + Amount)
  Amount=Balance ' new balance is returned in amount param
End Command

Command &H80 &H22 Debit (Amount As Long)
  If Not Personalised Then SW1SW2 = swNotPersonalised : Exit
rem  Call CheckAlgorithm()
  If Not (PINVerified OR MasterPINVerified) Then SW1SW2 = swPINRequired : Exit
  If Amount > Balance Then SW1SW2 = swInsufficientFunds : Exit
  Call ChangeBalance (Balance - Amount)
  Amount=Balance ' new balance is returned in amount param
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

Command &HC8 &H00 PRDisplay(RecordNumber as Byte, DataFormat as Byte, DigitCount as Byte, _
                            DecimalPoint as Byte, Delay as Byte, MoreData as Byte, _
                            Data as String)
  Dim BalanceData as Long
  Dim BalanceDataStr as String*4 at BalanceData
  select case RecordNumber
     case 0
       DataFormat=PRNumSign ' Number with sign
       DigitCount=0         ' show all digits
       DecimalPoint=3       ' decimal point at 3 character (2 digits follow point)
       Delay=0              ' show till card is removed
       MoreData=PRNoMoreData ' no more data to show
       BalanceData=Balance  ' convert long to string
       Data=BalanceDataStr  ' and send to balance reader
     case else
       DataFormat=PRAlpha
       DigitCount=0
       DecimalPoint=0
       Delay=1000 / PRDelayUnits ' 1 second to show
       MoreData=PRNoMoreData
       Data="ERR" ' Error message
  end select
End Command