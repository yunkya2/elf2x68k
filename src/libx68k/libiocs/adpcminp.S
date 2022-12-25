| void _iocs_adpcminp (void *, int, int);
.text
.even
.global _iocs_adpcminp
.type _iocs_adpcminp,@function
_iocs_adpcminp:
	move.l	%d2, %sp@-
	movem.l	%sp@(8), %d0-%d2
	move.l	%d0, %a1
	moveq	#0x61, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
