| int _iocs_prnintst (const void *);
.text
.even
.global _iocs_prnintst
.type _iocs_prnintst,@function
_iocs_prnintst:
	move.l	%sp@(4), %a1
	moveq	#0x6f, %d0
	trap	#15
	rts
