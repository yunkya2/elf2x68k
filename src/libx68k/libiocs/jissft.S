| int __pure _iocs_jissft (int) __attribute__((const));
.text
.even
.global _iocs_jissft
.type _iocs_jissft,@function
_iocs_jissft:
	move.l	%sp@(4), %d1
	moveq	#0xffffffa1, %d0
	trap	#15
	rts
