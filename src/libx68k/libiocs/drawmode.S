| int _iocs_drawmode (int); /* rom 1.3, iocs.x */
.text
.even
.global _iocs_drawmode
.type _iocs_drawmode,@function
_iocs_drawmode:
	move.l	%sp@(4), %d1
	moveq	#0xffffffb0, %d0
	trap	#15
	rts
