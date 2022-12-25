| int _iocs_box (const struct _iocs_boxptr *);
.text
.even
.global _iocs_box
.type _iocs_box,@function
_iocs_box:
	move.l	%sp@(4), %a1
	moveq	#0xffffffb9, %d0
	trap	#15
	rts
