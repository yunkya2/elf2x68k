| void _iocs_adpcmlin (const struct _iocs_chain2 *, int);
.text
.even
.global _iocs_adpcmlin
.type _iocs_adpcmlin,@function
_iocs_adpcmlin:
	movea.l	%sp@(4), %a1
	move.l	%sp@(8) , %d1
	moveq	#0x65, %d0
	trap	#15
	rts
