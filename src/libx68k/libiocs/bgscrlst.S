| int _iocs_bgscrlst (int, int, int);
.text
.even
.global _iocs_bgscrlst
.type _iocs_bgscrlst,@function
_iocs_bgscrlst:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3
	moveq	#0xffffffc8, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
