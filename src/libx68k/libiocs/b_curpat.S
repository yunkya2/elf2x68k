| void _iocs_b_curpat (int); /*1.3/iocs.x*/
.text
.even
.global _iocs_b_curpat
.type _iocs_b_curpat,@function
_iocs_b_curpat:
	move.l	%d2, %sp@-
	move.l	%sp@(8), %d2
	tst.w	%d2
	beqs	6f
	moveq	#2, %d1
	moveq	#0xffffffad, %d0
	trap	#15
6:
	move.l	%sp@+, %d2
	rts
