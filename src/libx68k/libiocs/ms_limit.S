| int _iocs_ms_limit (int, int, int, int);
.text
.even
.global _iocs_ms_limit
.type _iocs_ms_limit,@function
_iocs_ms_limit:
	move.l	%d2, %sp@-
	movem.l	%sp@(8), %d1-%d2
	swap	%d1
	move.w	%d2, %d1
	move.w	%sp@(18), %d2
	swap	%d2
	move.w	%sp@(22), %d2
	moveq	#0x77, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
