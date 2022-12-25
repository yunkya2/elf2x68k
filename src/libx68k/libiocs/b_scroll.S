| void _iocs_b_scroll (int); /*1.3/iocs.x*/
.text
.even
.global _iocs_b_scroll
.type _iocs_b_scroll,@function
_iocs_b_scroll:
	move.l	%d2, %sp@-
	move.l	%sp@(8), %d2
	moveq	#16, %d1
	cmp.l	%d1, %d2
	bcss	lscriocs
	move.l	%d2, %d1
lscriocs:
	moveq	#0xffffffad, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
