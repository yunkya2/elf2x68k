| int _iocs_crtmod (int);
.text
.even
.global _iocs_crtmod
.type _iocs_crtmod,@function
_iocs_crtmod:
	move.l	%sp@(4), %d1
	moveq	#0x10, %d0
	trap	#15
	rts
