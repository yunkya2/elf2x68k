| void _iocs_textput (int, int, const struct _iocs_fntbuf *);
.text
.even
.global _iocs_textput
.type _iocs_textput,@function
_iocs_textput:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2/%a1
	moveq	#0x1b, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
