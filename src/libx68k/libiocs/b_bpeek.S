| int _iocs_b_bpeek (const void *);
.text
.even
.global _iocs_b_bpeek
.type _iocs_b_bpeek,@function
_iocs_b_bpeek:
	move.l	%sp@(4), %a1
	moveq	#0xffffff82, %d0
	trap	#15
	rts
