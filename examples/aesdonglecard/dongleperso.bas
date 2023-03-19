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
Public Data As String = "abcdefghijklmnopabcdefghijklmnopabcdefghijklmnop" 

Call WaitForCard()
ResetCard : Call CheckSW1SW2()

Rem  Check that the application name is correct
Private Name$ : Call GetApplicationID (Name$) : Call CheckSW1SW2()
If Name$ <> ApplicationName$ Then Print "This is not a "; ApplicationName$ ;" Card!" : Exit

Print "Personalize"
Call Personalize(1234567,MasterKey16,"Didier Donsez") : Call CheckSW1SW2()

Print "Dongle Card data"
Private Strv$
Private I&
Private J@

Call GetOwner(Strv$)                 : Call CheckSW1SW2(): Print "Owner=" ; Strv$
Call GetSerialNumber(I&)            : Call CheckSW1SW2(): Print "SerialNumber=" ;I&
Call GetEncryptionAlgo(Strv$)     : Call CheckSW1SW2(): Print "EncryptionAlgo=" ; Strv$
Call GetKeySize(J@)                 : Call CheckSW1SW2(): Print "KeySize=" ; J@
Call GetBlockSize(J@)               : Call CheckSW1SW2(): Print "BlockSize=" ; J@