| void _iocs_b_memstr (const void *, void *, int);
.text
.even
.global _iocs_b_memstr
.type _iocs_b_memstr,@function
_iocs_b_memstr:
	move.l	%a2, %sp@-
	movem.l	%sp@(8), %a1/%a2
	move.l	%sp@(16), %d1
	moveq	#0xffffff85, %d0
	trap	#15
	move.l	%sp@+, %a2
	rts
