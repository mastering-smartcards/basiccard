# BasicCard

Java n’a pas été le seul langage qui a été choisi pour le développement d’applications carte. Ces concurrents basés sur l’interprétation d’instructions intermédiaires (i.e. bytecode) sont et ont été Forth, Visual Basic (SCW), C#/CLI ([.NET SmartCard](https://www.cardlogix.com/glossary/net-smart-card/)), ZC-Basic ([BasicCard](http://basiccard.com/)), … . Ces concurrents  basés sur l’exécution d’instructions natives (i.e. code machine) sont le C incluant parfois l’assembleur du processeur cible. Dans ce chapitre, nous nous intéresseront au langage ZC-Basic, le langage de développement de la BasicCard. Cette carte a la vertu d’être très simple à mettre en œuvre notanment dans un contexte pédagogique. Cependant la BasicCard reste une carte mono-applicative qui ne permet pas d’installer et d’exécuter et de desinstaller plusieurs applications (isolées les unes des autres) de plusieurs prestataires comme la JavaCard ou la SCW.

Le langage ZC-Basic est un dialecte du Basic qui doit être compilé vers un langage intermédiaire, le P-Code, pour être exécuter par un interpréteur de P-Code. La BasicCard contient un interprète de P-Code. Ainsi une application carte est donc écrite en ZC-Basic, puis compilée en P-Code et chargée dans la carte pour y être initialisée et personnalisée. Le langage ZC-Basic est un langage propriétaire de la seule société Zeit-Control.
D’autre part, les BasicCards (sauf Compact) possèdent un système de fichiers hiérarchique avec une racine des noms longs semblable à celui de DOS. Les fichiers sont aussi bien accessibles par l’application carte que par l’application terminal.

Les applications peuvent également développer en ZC-Basic. Celles-ci interprètent alors un programme écrit en P-Code. Les applications terminal peuvent être également écrites dans d’autres langages comme C, C++, C#, VB, Java, Delphi via les interfaces de programmation standards PC/SC, MUSCLE, OCF, eOCF ou propriétaires et sur un certain nombre de plate-formes (Windows32, Unix, Linux, MacOSX, OCF, eOCF …).

Dans ce chapitre, nous présenterons successivement l’environnement de développement d’une application, le langage BasicCard, les principales fonctions de bibliothèque et des commandes prédéfinies. Nous terminerons ce chapître avec notre exemple de porte monnaie électronique.

https://air.imag.fr/index.php/D%C3%A9veloppement_BasicCard
