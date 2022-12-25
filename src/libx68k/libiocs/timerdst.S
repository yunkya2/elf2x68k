| int _iocs_timerdst (const void *, int, int);
.text
.even
.global _iocs_timerdst
.type _iocs_timerdst,@function
_iocs_timerdst:
	movea.l	%sp@(4), %a1
	moveq	#0, %d1
	move.b	%sp@(11), %d1
	lsl.w	#8, %d1
	move.b	%sp@(15), %d1
	moveq	#0x6b, %d0
	trap	#15
	rts
