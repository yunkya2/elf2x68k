| int _iocs_fill (const struct _iocs_fillptr *);
.text
.even
.global _iocs_fill
.type _iocs_fill,@function
_iocs_fill:
	move.l	%sp@(4), %a1
	moveq	#0xffffffba, %d0
	trap	#15
	rts
