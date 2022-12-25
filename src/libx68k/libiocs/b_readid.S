| int _iocs_b_readid (int, int, void *);
.text
.even
.global _iocs_b_readid
.type _iocs_b_readid,@function
_iocs_b_readid:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0x4a, %d0
	trap	#15
	movea.l	%sp@(16), %a0
	move.l	%d2, %a0@
	move.l	%sp@+, %d2
	rts
