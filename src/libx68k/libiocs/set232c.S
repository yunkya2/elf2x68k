| int _iocs_set232c (int);
.text
.even
.global _iocs_set232c
.type _iocs_set232c,@function
_iocs_set232c:
	move.l	%sp@(4), %d1
	moveq	#0x30, %d0
	trap	#15
	rts
