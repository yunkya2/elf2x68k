| int _iocs_datecnv (const char *);
.text
.even
.global _iocs_datecnv
.type _iocs_datecnv,@function
_iocs_datecnv:
	move.l	%sp@(4), %a1
	moveq	#0x58, %d0
	trap	#15
	rts
