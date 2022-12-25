| void _iocs_adpcmout (const void *, int, int);
.text
.even
.global _iocs_adpcmout
.type _iocs_adpcmout,@function
_iocs_adpcmout:
	move.l	%d2, %sp@-
	movem.l	%sp@(8), %d0-%d2
	move.l	%d0, %a1
	moveq	#0x60, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
