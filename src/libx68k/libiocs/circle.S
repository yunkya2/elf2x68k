| int _iocs_circle (const struct _iocs_circleptr *);
.text
.even
.global _iocs_circle
.type _iocs_circle,@function
_iocs_circle:
	move.l	%sp@(4), %a1
	moveq	#0xffffffbb, %d0
	trap	#15
	rts
