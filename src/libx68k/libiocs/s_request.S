| int _iocs_s_request (int, int, void *);
.text
.even
.global _iocs_s_request
.type _iocs_s_request,@function
_iocs_s_request:
	move.l	%d3, %sp@-
	move.l	%d4, %sp@-
	movem.l	%sp@(12),%d3/%d4/%a1
	moveq	#44, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	move.l	%sp@+, %d3
	rts
