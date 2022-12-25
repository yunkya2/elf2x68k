| int _iocs_hanjob (char *);
.text
.even
.global _iocs_hanjob
.type _iocs_hanjob,@function
_iocs_hanjob:
	move.l	%sp@(4), %a1
	moveq	#0xffffffa5, %d0
	trap	#15
	rts
