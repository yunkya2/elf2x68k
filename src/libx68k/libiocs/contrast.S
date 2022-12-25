| int _iocs_contrast (int);
.text
.even
.global _iocs_contrast
.type _iocs_contrast,@function
_iocs_contrast:
	move.l	%sp@(4), %d1
	moveq	#0x11, %d0
	trap	#15
	rts
