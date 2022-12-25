| void _iocs_b_lpoke (void *, int);
.text
.even
.global _iocs_b_lpoke
.type _iocs_b_lpoke,@function
_iocs_b_lpoke:
	movea.l	%sp@(4), %a1
	move.l	%sp@(8) , %d1
	moveq	#0xffffff88, %d0
	trap	#15
	rts
