| int _iocs_timecnv (const char *);
.text
.even
.global _iocs_timecnv
.type _iocs_timecnv,@function
_iocs_timecnv:
	move.l	%sp@(4), %a1
	moveq	#0x59, %d0
	trap	#15
	rts
