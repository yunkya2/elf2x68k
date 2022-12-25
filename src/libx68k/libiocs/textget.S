| void _iocs_textget (int, int, struct _iocs_fntbuf *);
.text
.even
.global _iocs_textget
.type _iocs_textget,@function
_iocs_textget:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2/%a1
	moveq	#0x1a, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
