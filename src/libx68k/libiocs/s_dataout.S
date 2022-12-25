| int _iocs_s_dataout (int, void *);
.text
.even
.global _iocs_s_dataout
.type _iocs_s_dataout,@function
_iocs_s_dataout:
	move.l	%d3, %sp@-
	movem.l	%sp@(8),%d3/%a1
	moveq	#5, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d3
	rts
