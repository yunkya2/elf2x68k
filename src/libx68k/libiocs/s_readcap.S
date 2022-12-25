| int _iocs_s_readcap (int, struct _iocs_readcap *);
.text
.even
.global _iocs_s_readcap
.type _iocs_s_readcap,@function
_iocs_s_readcap:
	move.l	%d4, %sp@-
	movem.l	%sp@(8),%d4/%a1
	moveq	#37, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	rts
