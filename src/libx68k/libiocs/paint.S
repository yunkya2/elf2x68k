| int _iocs_paint (struct _iocs_paintptr *);
.text
.even
.global _iocs_paint
.type _iocs_paint,@function
_iocs_paint:
	move.l	%sp@(4), %a1
	moveq	#0xffffffbc, %d0
	trap	#15
	rts
