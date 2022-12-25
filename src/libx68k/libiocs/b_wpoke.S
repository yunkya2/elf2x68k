| void _iocs_b_wpoke (void *, int);
.text
.even
.global _iocs_b_wpoke
.type _iocs_b_wpoke,@function
_iocs_b_wpoke:
	movea.l	%sp@(4), %a1
	move.l	%sp@(8) , %d1
	moveq	#0xffffff87, %d0
	trap	#15
	rts
