| int _iocs_timeasc (int, char *);
.text
.even
.global _iocs_timeasc
.type _iocs_timeasc,@function
_iocs_timeasc:
	movem.l	%sp@(4),%d1/%a1
	moveq	#0x5b, %d0
	trap	#15
	rts
