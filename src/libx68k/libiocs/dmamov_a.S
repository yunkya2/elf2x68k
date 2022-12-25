| void _iocs_dmamov_a (const struct _iocs_chain *, void *, int, int);
.text
.even
.global _iocs_dmamov_a
.type _iocs_dmamov_a,@function
_iocs_dmamov_a:
	move.l	%d2, %sp@-
	move.l	%a2, %sp@-
	movem.l	%sp@(12), %d1-%d2/%a1-%a2
	exg	%d1, %a1
	exg	%d2, %a2
	moveq	#0xffffff8b, %d0
	trap	#15
	move.l	%sp@+, %a2
	move.l	%sp@+, %d2
	rts
