| int _iocs_apage (int);
.text
.even
.global _iocs_apage
.type _iocs_apage,@function
_iocs_apage:
	move.l	%sp@(4), %d1
	moveq	#0xffffffb1, %d0
	trap	#15
	rts
