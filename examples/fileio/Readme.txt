This directory contains some test programs for the ZC-Basic file I/O commands:
file I/O in the Terminal program, and remote file I/O in the (simulated)
Enhanced BasicCard. Some of these programs require a diskette in drive A:

Note: The Enhanced BasicCard is currently in the manufacturing phase (as of
December 1998). The first production version of the card will be the Enhanced
BasicCard ZC2.3, with 8K of user-programmable EEPROM. It will become available
in February 1999.

A pre-production version, Enhanced BasicCard ZC2.0, is available for testing
and evaluation purposes. All these tests are set up to run in this card.
Contact ZeitControl for ordering information.

Utility programs:

TREE.BAS      Displays a directory tree
WTREE.BAS     Same as TREE.BAS, but without DOS-specific line characters

Test programs:

KEYTEST.BAS   Test keyed access conditions in the BasicCard
LINETEST.BAS  Test LINE INPUT statement, in a diskette and a BasicCard
PUTGET.BAS    Test PUT and GET statements, in a diskette and a BasicCard
NAMETEST.BAS  Test NAME statement in the BasicCard

Enhanced BasicCard programs:

KEYCARD.BAS   A BasicCard with key-protected files
OPENCARD.BAS  A BasicCard with free read/write access to the root directory
TREECARD.BAS  A BasicCard with a directory structure

Key files:

GOODKEYS.BAS  Key file for KEYCARD.BAS
BADKEYS.BAS   Key file for KEYTEST.BAS

Batch files:

RUNALL.BAT    Compiles and runs all the test programs.
