| int _iocs_fntget (int, int, struct _iocs_fntbuf *);
.text
.even
.global _iocs_fntget
.type _iocs_fntget,@function
_iocs_fntget:
	movem.l	%sp@(4), %d0-%d1/%a1
	swap	%d1
	move.w	%d0, %d1
	swap	%d1
	moveq	#0x19, %d0
	trap	#15
	rts
