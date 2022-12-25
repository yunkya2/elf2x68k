| int __pure _iocs_sftjis (int) __attribute__((const));
.text
.even
.global _iocs_sftjis
.type _iocs_sftjis,@function
_iocs_sftjis:
	move.l	%sp@(4), %d1
	moveq	#0xffffffa0, %d0
	trap	#15
	rts
