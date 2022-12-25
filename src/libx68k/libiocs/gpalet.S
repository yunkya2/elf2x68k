| int _iocs_gpalet (int, int);
.text
.even
.global _iocs_gpalet
.type _iocs_gpalet,@function
_iocs_gpalet:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2
	moveq	#0xffffff94, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
