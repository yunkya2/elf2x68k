| int _iocs_spalet (int, int, int);
.text
.even
.global _iocs_spalet
.type _iocs_spalet,@function
_iocs_spalet:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	movem.l	%sp@(12),%d1/%d2/%d3
	moveq	#0xffffffcf, %d0
	trap	#15
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
