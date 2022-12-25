| int _iocs_s_inquiry (int, int, struct _iocs_inquiry *);
.text
.even
.global _iocs_s_inquiry
.type _iocs_s_inquiry,@function
_iocs_s_inquiry:
	move.l	%d3, %sp@-
	move.l	%d4, %sp@-
	movem.l	%sp@(12),%d3/%d4/%a1
	moveq	#32, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	move.l	%sp@+, %d4
	move.l	%sp@+, %d3
	rts
