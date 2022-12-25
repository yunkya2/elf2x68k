| void _iocs_b_curpat1 (void); /*1.3/iocs.x*/
.text
.even
.global _iocs_b_curpat1
.type _iocs_b_curpat1,@function
_iocs_b_curpat1:
	move.l	%d2, %sp@-
	moveq	#2, %d1
	moveq	#0, %d2
	moveq	#0xffffffad, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
