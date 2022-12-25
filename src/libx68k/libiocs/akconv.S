| int __pure _iocs_akconv (int, int) __attribute__((const));
.text
.even
.global _iocs_akconv
.type _iocs_akconv,@function
_iocs_akconv:
	move.w	%sp@(6), %d1
	swap	%d1
	move.w	%sp@(10), %d1
	moveq	#0xffffffa2, %d0
	trap	#15
	rts
