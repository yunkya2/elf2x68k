| int _iocs_putgrm (const struct _iocs_putptr *);
.text
.even
.global _iocs_putgrm
.type _iocs_putgrm,@function
_iocs_putgrm:
	move.l	%sp@(4), %a1
	moveq	#0xffffffbf, %d0
	trap	#15
	rts
