| int _iocs_dakjob (char *);
.text
.even
.global _iocs_dakjob
.type _iocs_dakjob,@function
_iocs_dakjob:
	move.l	%sp@(4), %a1
	moveq	#0xffffffa4, %d0
	trap	#15
	rts
