| void _iocs_skeyset (int);
.text
.even
.global _iocs_skeyset
.type _iocs_skeyset,@function
_iocs_skeyset:
	move.l	%sp@(4), %d1
	moveq	#0x05, %d0
	trap	#15
	rts
