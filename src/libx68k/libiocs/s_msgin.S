| int _iocs_s_msgin (void *);
.text
.even
.global _iocs_s_msgin
.type _iocs_s_msgin,@function
_iocs_s_msgin:
	move.l	%sp@(4), %a1
	moveq	#7, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	rts
