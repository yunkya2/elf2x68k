| int _iocs_s_startstop (int, int);
.text
.even
.global _iocs_s_startstop
.type _iocs_s_startstop,@function
_iocs_s_startstop:
	move.l	%d3, %sp@-
	move.l	%d4, %sp@-
	movem.l	%sp@(12),%d3/%d4
	moveq	#47, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	move.l	%sp@+, %d3
	rts
