| int _iocs_alarmget (int *, int *, int *);
.text
.even
.global _iocs_alarmget
.type _iocs_alarmget,@function
_iocs_alarmget:
	move.l	%d2, %sp@-
	moveq	#0x5f, %d0
	trap	#15
	movem.l	%sp@(8), %a0/%a1
	move.l	%d1, %a0@
	move.l	%d2, %a1@
	movea.l	%sp@(16), %a0
	move.l	%d0, %a0@
	move.l	%sp@+, %d2
	rts
