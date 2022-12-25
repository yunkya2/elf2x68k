| void _iocs_adpcmlot (const struct _iocs_chain2 *, int);
.text
.even
.global _iocs_adpcmlot
.type _iocs_adpcmlot,@function
_iocs_adpcmlot:
	movea.l	%sp@(4), %a1
	move.l	%sp@(8) , %d1
	moveq	#0x64, %d0
	trap	#15
	rts
