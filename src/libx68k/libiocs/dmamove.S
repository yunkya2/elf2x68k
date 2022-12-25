| void _iocs_dmamove (void *, void *, int, int);
.text
.even
.global _iocs_dmamove
.type _iocs_dmamove,@function
_iocs_dmamove:
	move.l	%d2, %sp@-
	move.l	%a2, %sp@-
	movem.l	%sp@(12), %d1-%d2/%a1-%a2
	exg	%d1, %a1
	exg	%d2, %a2
	moveq	#0xffffff8a, %d0
	trap	#15
	move.l	%sp@+, %a2
	move.l	%sp@+, %d2
	rts
