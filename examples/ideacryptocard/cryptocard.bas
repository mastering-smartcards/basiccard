Rem DES CryptoCard (for Enhanced or Professional BasicCard)
Rem -------------------------------------------------------
Rem Copyright (C) 2002 Didier DONSEZ
Rem -------------------------------------------------------

Option Explicit

#Include CRYPTOCARD.DEF
#Include DECLKEYS.DEF
#Include IDEA.DEF


Rem Const BWI=7 ' -> BWT = 2^BWI * 0.1s = 128 * 0.1s = 12.8s

Declare Sub EncryptIDEA (KeyStr$,Data$)
Declare Sub DecryptIDEA (KeyStr$,Data$)
Declare Sub CheckParameters (KeyStr$,Data$)

Declare ApplicationID = ApplicationName$

Eeprom NullKeyStr As String*KeySize= &H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00,&H00


REM ========================================================

Command &H00 &H02 SetKey (KeyNum@, KeyStr$)

  Private KeyLen@

  KeyLen@ = Len(KeyStr$)

  if KeyLen@<>KeySize then
    SW1SW2 = swInvalidKeySize
    Exit
  end if

  Key(KeyNum@)=KeyStr$

End Command

REM --------------------------------------------------------
  
Command &H00 &H04 UnsetKey (KeyNum@)

  Key(KeyNum@)=NullKeyStr

End Command


REM ========================================================

Command &H00 &H12 Encrypt (KeyNum@, Data$)
  Private KeyStr$

  KeyStr$       = Key(KeyNum@)

  Call CheckParameters (KeyStr$,Data$)
  Call EncryptIDEA (KeyStr$,Data$)

End Command

REM --------------------------------------------------------

Command &H00 &H14 Decrypt (KeyNum@, Data$)
  Private KeyStr$

  KeyStr$       = Key(KeyNum@)

  Call CheckParameters (KeyStr$,Data$)
  Call DecryptIDEA (KeyStr$,Data$)
  
End Command

REM ========================================================

Sub EncryptIDEA (KeyStr$,Data$)
  Private DataBlockNum@
  Private I
  Private Block As String*8

  DataBlockNum@ = Len(Data$) / BlockSize

  For I = 0 To DataBlockNum@ - 1
    Block = Mid$(Data$,I*BlockSize+1,BlockSize)
    Block = IdeaEncrypt (KeyStr$, Block)
    Mid$(Data$,I*BlockSize+1,BlockSize) = Block
  Next I
End Sub

Sub DecryptIDEA (KeyStr$,Data$)
  Private DataBlockNum@
  Private I
  Private Block As String*8

  DataBlockNum@ = Len(Data$) / BlockSize

  For I = 0 To DataBlockNum@ - 1
    Block = Mid$(Data$,I*BlockSize+1,BlockSize)
    Block = IdeaDecrypt (KeyStr$, Block)
    Mid$(Data$,I*BlockSize+1,BlockSize) = Block
  Next I
End Sub

Sub CheckParameters (KeyStr$,Data$)
  Private KeyLen@
  Private DataBlockNum@

  KeyLen@       = Len(KeyStr$)
  DataBlockNum@ = Len(Data$) / BlockSize

  if KeyLen@=0 or KeyStr$=NullKeyStr then
    SW1SW2 = swNoKey
    Exit
  elseif KeyLen@<>KeySize then
    SW1SW2 = swInvalidKeySize
    Exit
  end if

  if Len(Data$) mod BlockSize <> 0 or DataBlockNum@=0 then
    SW1SW2 = swInvalidDataLength
    Exit
  end if
End Sub

