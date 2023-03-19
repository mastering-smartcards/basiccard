..\..\zcmbasic keycard @..\card.prm -oi
..\..\zcmbasic opencard @..\card.prm -oi
..\..\zcmbasic treecard @..\card.prm -oi

..\..\zcmbasic keytest -oi -i..\..\Inc
..\..\zcmbasic linetest -oi -i..\..\Inc
..\..\zcmbasic nametest -oi -i..\..\Inc
..\..\zcmbasic putget -oi -i..\..\Inc
..\..\zcmbasic tree -oi -i..\..\Inc

..\..\zcmsim -ckeycard keytest
..\..\zcmsim -copencard linetest
..\..\zcmsim -copencard nametest
..\..\zcmsim -copencard putget
..\..\zcmsim -ctreecard tree @@:
