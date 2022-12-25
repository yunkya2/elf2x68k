| int _iocs_sp_defcg (int, int, const void *);
.text
.even
.global _iocs_sp_defcg
.type _iocs_sp_defcg,@function
_iocs_sp_defcg:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2/%a1
	moveq	#0xffffffc4, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
