| void _iocs_adpcmmod (int);
.text
.even
.global _iocs_adpcmmod
.type _iocs_adpcmmod,@function
_iocs_adpcmmod:
	move.l	%sp@(4), %d1
	moveq	#0x67, %d0
	trap	#15
	rts
