| void _iocs_txyline (const struct _iocs_ylineptr *);
.text
.even
.global _iocs_txyline
.type _iocs_txyline,@function
_iocs_txyline:
	move.l	%sp@(4), %a1
	moveq	#0xffffffd4, %d0
	trap	#15
	rts
