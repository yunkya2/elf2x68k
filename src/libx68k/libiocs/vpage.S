| int _iocs_vpage (int);
.text
.even
.global _iocs_vpage
.type _iocs_vpage,@function
_iocs_vpage:
	move.l	%sp@(4), %d1
	moveq	#0xffffffb2, %d0
	trap	#15
	rts
