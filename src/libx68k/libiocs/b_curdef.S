| void _iocs_b_curdef (void *); /*1.3/iocs.x*/
.text
.even
.global _iocs_b_curdef
.type _iocs_b_curdef,@function
_iocs_b_curdef:
	move.l	%d2, %sp@-
	move.l	%sp@(8), %d2
	moveq	#3, %d1
	moveq	#0xffffffad, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
