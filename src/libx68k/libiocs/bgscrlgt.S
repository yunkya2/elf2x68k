| int _iocs_bgscrlgt (int, int *, int *);
.text
.even
.global _iocs_bgscrlgt
.type _iocs_bgscrlgt,@function
_iocs_bgscrlgt:
	move.l	%d2, %sp@-
	move.l	%d3, %sp@-
	move.l	%sp@(12), %d1
	moveq	#0xffffffc9, %d0
	trap	#15
	tst.l	%d0
	bnes	6f
	movem.l	%sp@(16), %a0/%a1
	move.l	%d2, %a0@
	move.l	%d3, %a1@
6:
	move.l	%sp@+, %d3
	move.l	%sp@+, %d2
	rts
