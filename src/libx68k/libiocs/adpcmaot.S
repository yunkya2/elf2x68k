| void _iocs_adpcmaot (const struct _iocs_chain *, int, int);
.text
.even
.global _iocs_adpcmaot
.type _iocs_adpcmaot,@function
_iocs_adpcmaot:
	move.l	%d2, %sp@-
	movem.l	%sp@(8), %d0-%d2
	move.l	%d0, %a1
	moveq	#0x62, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
