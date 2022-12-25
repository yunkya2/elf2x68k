| int _iocs_s_datain (int, void *);
.text
.even
.global _iocs_s_datain
.type _iocs_s_datain,@function
_iocs_s_datain:
	move.l	%d3, %sp@-
	movem.l	%sp@(8),%d3/%a1
	moveq	#4, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d3
	rts
