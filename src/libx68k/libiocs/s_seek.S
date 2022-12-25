| int _iocs_s_seek (int, int);
.text
.even
.global _iocs_s_seek
.type _iocs_s_seek,@function
_iocs_s_seek:
	move.l	%d2, %sp@-
	move.l	%d4, %sp@-
	movem.l	%sp@(12),%d2/%d4
	moveq	#45, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	move.l	%sp@+, %d2
	rts
