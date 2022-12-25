| void _iocs_clipput (int, int, const struct _iocs_fntbuf *, const struct _iocs_clipxy *);
.text
.even
.global _iocs_clipput
.type _iocs_clipput,@function
_iocs_clipput:
	move.l	%d2, %sp@-
	move.l	%a2, %sp@-
	movem.l	%sp@(12),%d1/%d2/%a1/%a2
	moveq	#0x1c, %d0
	trap	#15
	move.l	%sp@+, %a2
	move.l	%sp@+, %d2
	rts
