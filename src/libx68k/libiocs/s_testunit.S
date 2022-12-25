| int _iocs_s_testunit (int);
.text
.even
.global _iocs_s_testunit
.type _iocs_s_testunit,@function
_iocs_s_testunit:
	move.l	%d4, %sp@-
	move.l	%sp@(8), %d4
	moveq	#36, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	rts
