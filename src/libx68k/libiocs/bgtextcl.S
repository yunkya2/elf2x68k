| int _iocs_bgtextcl (int, int);
.text
.even
.global _iocs_bgtextcl
.type _iocs_bgtextcl,@function
_iocs_bgtextcl:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0xffffffcc, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
