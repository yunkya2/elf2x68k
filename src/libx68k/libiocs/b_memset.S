| void _iocs_b_memset (void *, const void *, int);
.text
.even
.global _iocs_b_memset
.type _iocs_b_memset,@function
_iocs_b_memset:
	move.l	%a2, %sp@-
	movem.l	%sp@(8), %a1/%a2
	move.l	%sp@(16), %d1
	moveq	#0xffffff89, %d0
	trap	#15
	move.l	%sp@+, %a2
	rts
