| int _iocs_b_dskini (int, const void *, int);
.text
.even
.global _iocs_b_dskini
.type _iocs_b_dskini,@function
_iocs_b_dskini:
	move.l	%d2, %sp@-
	movem.l	%sp@(8), %d1-%d2/%a1
	exg	%d2, %a1
	moveq	#0x43, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
