| int _iocs_b_drvchk (int, int);
.text
.even
.global _iocs_b_drvchk
.type _iocs_b_drvchk,@function
_iocs_b_drvchk:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x4e, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
