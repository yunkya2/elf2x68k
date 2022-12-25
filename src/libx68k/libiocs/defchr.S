| int _iocs_defchr (int, int, const void *);
.text
.even
.global _iocs_defchr
.type _iocs_defchr,@function
_iocs_defchr:
	movem.l	%sp@(4), %d0-%d1/%a1
	swap	%d1
	move.w	%d0, %d1
	swap	%d1
	moveq	#0x0f, %d0
	trap	#15
	rts
