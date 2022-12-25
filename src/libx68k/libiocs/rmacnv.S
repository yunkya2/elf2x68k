| int _iocs_rmacnv (int, char *, char *);
.text
.even
.global _iocs_rmacnv
.type _iocs_rmacnv,@function
_iocs_rmacnv:
	move.l	%a2, %sp@-
	movem.l	%sp@(8),%d1/%a1/%a2
	moveq	#0xffffffa3, %d0
	trap	#15
	move.l	%sp@+, %a2
	rts
