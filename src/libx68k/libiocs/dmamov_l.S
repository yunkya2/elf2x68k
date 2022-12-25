| void _iocs_dmamov_l (const struct _iocs_chain2 *, void *, int);
.text
.even
.global _iocs_dmamov_l
.type _iocs_dmamov_l,@function
_iocs_dmamov_l:
	move.l	%a2, %sp@-
	movem.l	%sp@(8), %a1/%a2
	move.l	%sp@(16), %d1
	moveq	#0xffffff8c, %d0
	trap	#15
	move.l	%sp@+, %a2
	rts
