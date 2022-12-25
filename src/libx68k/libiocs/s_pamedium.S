| int _iocs_s_pamedium (int, int);
.text
.even
.global _iocs_s_pamedium
.type _iocs_s_pamedium,@function
_iocs_s_pamedium:
	move.l	%d3, %sp@-
	move.l	%d4, %sp@-
	movem.l	%sp@(12),%d3/%d4
	moveq	#50, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	move.l	%sp@+, %d3
	rts
