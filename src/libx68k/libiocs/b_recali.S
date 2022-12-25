| int _iocs_b_recali (int);
.text
.even
.global _iocs_b_recali
.type _iocs_b_recali,@function
_iocs_b_recali:
	move.l	%sp@(4), %d1
	moveq	#0x47, %d0
	trap	#15
	rts
