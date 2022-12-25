| int _iocs_b_intvcs (int, int);
.text
.even
.global _iocs_b_intvcs
.type _iocs_b_intvcs,@function
_iocs_b_intvcs:
	movem.l	%sp@(4),%d1/%a1
	moveq	#0xffffff80, %d0
	trap	#15
	rts
