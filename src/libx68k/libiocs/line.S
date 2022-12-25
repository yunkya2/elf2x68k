| int _iocs_line (const struct _iocs_lineptr *);
.text
.even
.global _iocs_line
.type _iocs_line,@function
_iocs_line:
	move.l	%sp@(4), %a1
	moveq	#0xffffffb8, %d0
	trap	#15
	rts
