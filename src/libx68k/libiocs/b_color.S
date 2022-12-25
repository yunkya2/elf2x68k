| int _iocs_b_color (int);
.text
.even
.global _iocs_b_color
.type _iocs_b_color,@function
_iocs_b_color:
	move.l	%sp@(4), %d1
	moveq	#0x22, %d0
	trap	#15
	rts
