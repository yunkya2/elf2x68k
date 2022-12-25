| int _iocs_b_lpeek (const void *);
.text
.even
.global _iocs_b_lpeek
.type _iocs_b_lpeek,@function
_iocs_b_lpeek:
	move.l	%sp@(4), %a1
	moveq	#0xffffff84, %d0
	trap	#15
	rts
