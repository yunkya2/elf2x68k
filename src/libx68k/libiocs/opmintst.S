| int _iocs_opmintst (const void *);
.text
.even
.global _iocs_opmintst
.type _iocs_opmintst,@function
_iocs_opmintst:
	move.l	%sp@(4), %a1
	moveq	#0x6a, %d0
	trap	#15
	rts
