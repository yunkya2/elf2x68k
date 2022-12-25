| void _iocs_b_bpoke (void *, int);
.text
.even
.global _iocs_b_bpoke
.type _iocs_b_bpoke,@function
_iocs_b_bpoke:
	movea.l	%sp@(4), %a1
	move.l	%sp@(8) , %d1
	moveq	#0xffffff86, %d0
	trap	#15
	rts
