Rem IDEA CryptoCard (for Enhanced or Professional BasicCard)
Rem -------------------------------------------------------
Rem Copyright (C) 2002 Didier DONSEZ
Rem -------------------------------------------------------

Option Explicit

#Include COMMERR.DEF
#Include CARDUTIL.DEF
#Include CryptoCARD.DEF

Public MasterKey16 As String*16 = &H01,&H21,&H3C,&H41,&H29,&H47,&HD9,&H96,&H73,&HD2,&H70,&HB5,&H6F,&HCA,&H15,&HA8
Public Key16 As String*16 = &H02,&H2C,&H3C,&H41,&H29,&H47,&HD9,&H96,&H73,&HD2,&H70,&HB5,&H6F,&HCA,&H15,&HA8

Rem  Data to be encrypted:
Public Data As String = "abcdefghijklmnop" 

Call WaitForCard()
ResetCard : Call CheckSW1SW2()

Rem  Check that the application name is correct
Private Name$ : Call GetApplicationID (Name$) : Call CheckSW1SW2()
If Name$ <> ApplicationName$ Then Print "This is not a "+ ApplicationName$ +" Card!" : Exit

Print "Set Key"
Call SetKey(3,Key16) : Call CheckSW1SW2()

Print "Encryption test"
Call Encrypt(3,Data) : Call CheckSW1SW2()

Print "Decryption test"
Call Decrypt(3,Data) : Call CheckSW1SW2()

Print "Unset Key"
Call UnsetKey(3) : Call CheckSW1SW2()

Print "Encryption test"
Call Encrypt(3,Data) : Call CheckSW1SW2()
