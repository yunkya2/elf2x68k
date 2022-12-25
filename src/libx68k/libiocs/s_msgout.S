| int _iocs_s_msgout (void *);
.text
.even
.global _iocs_s_msgout
.type _iocs_s_msgout,@function
_iocs_s_msgout:
	move.l	%sp@(4), %a1
	moveq	#8, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	rts
