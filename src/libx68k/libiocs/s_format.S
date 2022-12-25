| int _iocs_s_format (int, int);
.text
.even
.global _iocs_s_format
.type _iocs_s_format,@function
_iocs_s_format:
	move.l	%d3, %sp@-
	move.l	%d4, %sp@-
	movem.l	%sp@(12),%d3/%d4
	moveq	#35, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	move.l	%sp@+, %d3
	rts
