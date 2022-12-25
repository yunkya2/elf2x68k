| int _iocs_skey_mod (int, int, int);
.text
.even
.global _iocs_skey_mod
.type _iocs_skey_mod,@function
_iocs_skey_mod:
	move.l	%d2, %sp@-
	move.l	%sp@(8), %d1
	move.w	%sp@(14), %d2
	swap	%d2
	move.w	%sp@(18), %d2
	moveq	#0x7d, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
