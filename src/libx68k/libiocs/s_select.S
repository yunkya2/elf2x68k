| int _iocs_s_select (int);
.text
.even
.global _iocs_s_select
.type _iocs_s_select,@function
_iocs_s_select:
	move.l	%d4, %sp@-
	move.l	%sp@(8), %d4
	moveq	#1, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	rts
