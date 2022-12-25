| int _iocs_ms_curst (int, int);
.text
.even
.global _iocs_ms_curst
.type _iocs_ms_curst,@function
_iocs_ms_curst:
	move.w	%sp@(6), %d1
	swap	%d1
	move.w	%sp@(10), %d1
	moveq	#0x76, %d0
	trap	#15
	rts
