| int _iocs_s_reassign (int, int, void *);
.text
.even
.global _iocs_s_reassign
.type _iocs_s_reassign,@function
_iocs_s_reassign:
	move.l	%d3, %sp@-
	move.l	%d4, %sp@-
	movem.l	%sp@(12),%d3/%d4/%a1
	moveq	#49, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	move.l	%sp@+, %d3
	rts
