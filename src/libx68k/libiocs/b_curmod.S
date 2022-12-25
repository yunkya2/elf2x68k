| void _iocs_b_curmod (int); /*1.3/iocs.x*/
.text
.even
.global _iocs_b_curmod
.type _iocs_b_curmod,@function
_iocs_b_curmod:
	move.l	%sp@(4), %d1
	moveq	#1, %d0
	cmp.l	%d1, %d0
	bcss	6f
	moveq	#0xffffffad, %d0
	trap	#15
6:
	rts
