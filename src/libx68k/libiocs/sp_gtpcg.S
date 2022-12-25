| int _iocs_sp_gtpcg (int, int, void *);
.text
.even
.global _iocs_sp_gtpcg
.type _iocs_sp_gtpcg,@function
_iocs_sp_gtpcg:
	move.l	%d2, %sp@-
	movem.l	%sp@(8),%d1/%d2/%a1
	moveq	#0xffffffc5, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
