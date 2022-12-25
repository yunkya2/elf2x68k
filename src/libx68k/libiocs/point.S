| int _iocs_point (const struct _iocs_pointptr *);
.text
.even
.global _iocs_point
.type _iocs_point,@function
_iocs_point:
	move.l	%sp@(4), %a1
	moveq	#0xffffffb7, %d0
	trap	#15
	rts
