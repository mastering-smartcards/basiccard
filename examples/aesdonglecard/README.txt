DongleCard
----------



J'ai trouvé l'erreur : une constante etait restée en dure : la taille du bloc dans les subroutines
Sub DecryptAES (ByRef KeyStr$,ByRef Data$) et Sub EncryptAES (ByRef KeyStr$,ByRef Data$)

  Private Block As String*KeySize Rem au lieu de Private Block As String*8 dans l'ancienne version

Je vous attache le nouveau code !

Il faut aussi maintenent que le P-Code stack dans l'option de compilation de la BasicCard doit etre de 122 ! Sinon le compilateur repond qu'il n'y a pas assez de RAM

Autre info, les clés des licences passées a la Command DongleCardCLA &H20 SetLicence (KeyNum@, EncryptedKeyStr$ As String*KeySize)

doit être crypté avec la MasterKey car la carte les decrypte avec la MasterKey pour les installer !

(Ce mecanisme permet de proteger les clés de licences lors de leur installation par le porteur de la carte !)


-- 
---------------------------------------------------------
Didier DONSEZ
Laboratoire LSR, Institut Imag, Universite Joseph Fourier
Bat. C, 220 rue de la Chimie, Domaine Universitaire
BP 53, 38041 Grenoble Cedex 9, France
Tel : +33 4 76 63 55 49           Fax : +33 4 76 63 55 50
mailto:Didier.Donsez@imag.fr
URL: http://www-adele.imag.fr/~donsez
---------------------------------------------------------
