| int _iocs_s_stsin (void *);
.text
.even
.global _iocs_s_stsin
.type _iocs_s_stsin,@function
_iocs_s_stsin:
	move.l	%sp@(4), %a1
	moveq	#6, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	rts
