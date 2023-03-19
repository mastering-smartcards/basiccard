Rem DongleCard (for Enhanced or Professional BasicCard)
Rem -------------------------------------------------------
Rem Copyright (C) 2002 Didier DONSEZ
Rem -------------------------------------------------------

Option Explicit

#Include DONGLECARD.DEF
#Include DECLKEYS.DEF
#Include AES.DEF

REM ========================================================
REM CONSTANTES

Rem Const BWI=7 ' -> BWT = 2^BWI * 0.1s = 128 * 0.1s = 12.8s

Const MasterKey               = &H00
Eeprom NullKeyStr As String*KeySize= &H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00
  rem NullKeyStr could not be declared as a constante

REM ========================================================
REM PRIVATE PROCEDURES

Declare Sub EncryptAES  (KeyStr$,Data$)
Declare Sub DecryptAES  (KeyStr$,Data$)
Declare Sub CheckKeyStr (KeyStr$)
Declare Sub CheckData   (Data$)

Declare ApplicationID = ApplicationName$

REM ========================================================
REM EEPROM VARIABLES

Eeprom Owner$=""
Eeprom SerialNumber&=0
Eeprom Personalized as Integer=False


REM ========================================================

Command DongleCardCLA &H10 Personalize (SerialNumberP&, MasterKeyStr$ As String*KeySize, OwnerP$)

  if Personalized=True then
    SW1SW2 = swYetPersonalized
    Exit
  end if

  if Len(MasterKeyStr$)<>KeySize then
    SW1SW2 = swInvalidKeySize
    Exit
  end if

  Key(MasterKey)=MasterKeyStr$

  Rem set SerialNumber and Owner

  SerialNumber&=SerialNumberP&
  Owner$=OwnerP$

  Rem set donglecard is personalized
  Personalized=True

End Command

REM --------------------------------------------------------
  
Command DongleCardCLA &H12 GetEncryptionAlgo (Name$)
  Name$="AES"
End Command

REM --------------------------------------------------------

Command DongleCardCLA &H14 GetKeySize (KeySizeP@)
  KeySizeP@=KeySize
End Command

REM --------------------------------------------------------

Command DongleCardCLA &H16 GetBlockSize (BlockSizeP@)
  BlockSizeP@=BlockSize
End Command

REM --------------------------------------------------------

Command DongleCardCLA &H18 GetSerialNumber   (SerialNumberP&)
  if Personalized=False then
    SW1SW2 = swNotPersonalized
    Exit
  end if
  SerialNumberP&=SerialNumber&
End Command

REM --------------------------------------------------------

Command DongleCardCLA &H1A GetOwner          (OwnerP$)
  if Personalized=False then
    SW1SW2 = swNotPersonalized
    Exit
  end if
  OwnerP$=Owner$
End Command


REM ========================================================

Command DongleCardCLA &H20 SetLicence (KeyNum@, EncryptedKeyStr$ As String*KeySize)

  Private MasterKeyStr$
  Private KeyLen@

  if Personalized=False then
    SW1SW2 = swNotPersonalized
    Exit
  end if

  MasterKeyStr$=Key(MasterKey)

  Rem Check EncryptedKeyStr
  if KeyNum@=MasterKey then
    SW1SW2 = swIllegalOperation
    Exit
  end if

  KeyLen@ = Len(EncryptedKeyStr$)
  if KeyLen@<>KeySize then
    SW1SW2 = swInvalidKeySize
    Exit
  end if

  Rem Decrypt EncryptedKeyStr$ with Key(MasterKey )
  Call DecryptAES(MasterKeyStr$,EncryptedKeyStr$)

  Rem 
  Key(KeyNum@)=EncryptedKeyStr$
  EncryptedKeyStr$=""

End Command

REM --------------------------------------------------------
  
Command DongleCardCLA &H22 UnsetLicence (KeyNum@)

  if Personalized=False then
    SW1SW2 = swNotPersonalized
    Exit
  end if

  if KeyNum@=MasterKey  then
    SW1SW2 = swIllegalOperation
    Exit
  end if

  Key(KeyNum@)=NullKeyStr

End Command

REM --------------------------------------------------------
REM return SW1SW2=&H9000 if key if present, other else
 
Command DongleCardCLA &H24 IsLicenced        (KeyNum@)
  Private KeyStr$

  if Personalized=False then
    SW1SW2 = swNotPersonalized
    Exit
  end if

  KeyStr$       = Key(KeyNum@)

  Call CheckKeyStr  (KeyStr$)

End Command

REM ========================================================

Command DongleCardCLA &H30 Encrypt (KeyNum@, Data$)
  Private KeyStr$


  if Personalized=False then
    SW1SW2 = swNotPersonalized
    Exit
  end if

  KeyStr$       = Key(KeyNum@)

  rem Call CheckKeyStr  (KeyStr$)
  Call CheckKeyStr  (KeyStr$)
  Call CheckData    (Data$)
  Call EncryptAES   (KeyStr$, Data$)

End Command

REM --------------------------------------------------------

Command DongleCardCLA &H32 Decrypt (KeyNum@, Data$)
  Private KeyStr$

  if Personalized=False then
    SW1SW2 = swNotPersonalized
    Exit
  end if

  KeyStr$       = Key(KeyNum@)

  Call CheckKeyStr  (KeyStr$)
  Call CheckData    (Data$)
  Call DecryptAES   (KeyStr$,Data$)
  
End Command

REM ========================================================

Sub EncryptAES (ByRef KeyStr$,ByRef Data$)
  Private DataBlockNum@
  Private I as byte
  Private Block As String*KeySize

  DataBlockNum@ = Len(Data$) / BlockSize

  For I = 0 To DataBlockNum@ - 1
    Block = Mid$(Data$,I*BlockSize+1,BlockSize)
    Block = AES(KeySize*8,KeyStr$, Block)
    Mid$(Data$,I*BlockSize+1,BlockSize) = Block
  Next I
End Sub

REM --------------------------------------------------------

Sub DecryptAES (ByRef KeyStr$,ByRef Data$)
  Private DataBlockNum@
  Private I as byte
  Private Block As String*KeySize

  DataBlockNum@ = Len(Data$) / BlockSize

  For I = 0 To DataBlockNum@ - 1
    Block = Mid$(Data$,I*BlockSize+1,BlockSize)
    Block = AES(-KeySize*8, KeyStr$, Block)
    Mid$(Data$,I*BlockSize+1,BlockSize) = Block
  Next I
End Sub

REM ========================================================

Sub CheckKeyStr (KeyStr$)
  Private KeyLen@
  KeyLen@       = Len(KeyStr$)

  if KeyLen@=0 or KeyStr$=NullKeyStr then
    SW1SW2 = swNoKey
    Exit
  elseif KeyLen@<>KeySize then
    SW1SW2 = swInvalidKeySize
    Exit
  end if

End Sub

REM --------------------------------------------------------

Sub CheckData (Data$)
  Private DataBlockNum@
  DataBlockNum@ = Len(Data$) / BlockSize

  if Len(Data$) mod BlockSize <> 0 or DataBlockNum@=0 then
    SW1SW2 = swInvalidDataLength
    Exit
  end if
End Sub

