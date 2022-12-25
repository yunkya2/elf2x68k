| int _iocs_getgrm (struct _iocs_getptr *);
.text
.even
.global _iocs_getgrm
.type _iocs_getgrm,@function
_iocs_getgrm:
	move.l	%sp@(4), %a1
	moveq	#0xffffffbe, %d0
	trap	#15
	rts
