| int _iocs_home (int, int, int);
.text
.even
.global _iocs_home
.type _iocs_home,@function
_iocs_home:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3
	moveq	#0xffffffb3, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
