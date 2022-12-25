| int _iocs_init_prn (int, int);
.text
.even
.global _iocs_init_prn
.type _iocs_init_prn,@function
_iocs_init_prn:
	moveq	#0, %d1
	move.b	%sp@(7), %d1
	lsl.w	#8, %d1
	move.b	%sp@(11), %d1
	moveq	#0x3c, %d0
	trap	#15
	rts
