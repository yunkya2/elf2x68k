| int _iocs_s_cmdout (int, void *);
.text
.even
.global _iocs_s_cmdout
.type _iocs_s_cmdout,@function
_iocs_s_cmdout:
	move.l	%d3, %sp@-
	movem.l	%sp@(8),%d3/%a1
	moveq	#3, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d3
	rts
