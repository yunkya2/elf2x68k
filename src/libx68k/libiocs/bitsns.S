| int _iocs_bitsns (int);
.text
.even
.global _iocs_bitsns
.type _iocs_bitsns,@function
_iocs_bitsns:
	move.l	%sp@(4), %d1
	moveq	#0x04, %d0
	trap	#15
	rts
