| int _iocs_s_rezerounit (int);
.text
.even
.global _iocs_s_rezerounit
.type _iocs_s_rezerounit,@function
_iocs_s_rezerounit:
	move.l	%d4, %sp@-
	move.l	%sp@(8), %d4
	moveq	#43, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	rts
