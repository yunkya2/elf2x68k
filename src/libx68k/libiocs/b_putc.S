| int _iocs_b_putc (int);
.text
.even
.global _iocs_b_putc
.type _iocs_b_putc,@function
_iocs_b_putc:
	move.l	%sp@(4), %d1
	moveq	#0x20, %d0
	trap	#15
	rts
