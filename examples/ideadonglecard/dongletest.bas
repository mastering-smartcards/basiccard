Rem DongleCard (for Enhanced or Professional BasicCard)
Rem -------------------------------------------------------
Rem Copyright (C) 2002 Didier DONSEZ
Rem -------------------------------------------------------

Option Explicit

#Include COMMERR.DEF
#Include CARDUTIL.DEF
#Include DONGLECARD.DEF

Public MasterKey16 As String*16 = &H01,&H21,&H3C,&H41,&H29,&H47,&HD9,&H96,&H73,&HD2,&H70,&HB5,&H6F,&HCA,&H15,&HA8
Public Key16 As String*16 = &H02,&H2C,&H3C,&H41,&H29,&H47,&HD9,&H96,&H73,&HD2,&H70,&HB5,&H6F,&HCA,&H15,&HA8
Public NullKeyStr As String*KeySize= &H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00

Rem  Data to be encrypted:
Public Data As String = "abcdefghijklmnopqrstuvwx" 

Call WaitForCard()
ResetCard : Call CheckSW1SW2()

Rem  Check that the application name is correct
Private Name$ : Call GetApplicationID (Name$) : Call CheckSW1SW2()
If Name$ <> ApplicationName$ Then Print "This is not a "+ ApplicationName$ +" Card!" : Exit

Print "Set MasterKey"
Call SetKey(0,NullKeyStr) : Call CheckSW1SW2()
Call SetMasterKey(MasterKey16) : Call CheckSW1SW2()

Print "Set Licence"
REM Call SetLicence(3,Key16) : Call CheckSW1SW2()
Call SetKey(3,Key16) : Call CheckSW1SW2()

Print "Encryption test"
Call Encrypt(3,Data) : Call CheckSW1SW2()

Print "Decryption test"
Call Decrypt(3,Data) : Call CheckSW1SW2()

Print "Unset Licence"
Call UnsetLicence(3) : Call CheckSW1SW2()

Print "Encryption test (must Failed)"
Call Encrypt(3,Data) : Call CheckSW1SW2()
