| int _iocs_dateasc (int, char *);
.text
.even
.global _iocs_dateasc
.type _iocs_dateasc,@function
_iocs_dateasc:
	movem.l	%sp@(4),%d1/%a1
	moveq	#0x5a, %d0
	trap	#15
	rts
