| int _iocs_b_wpeek (const void *);
.text
.even
.global _iocs_b_wpeek
.type _iocs_b_wpeek,@function
_iocs_b_wpeek:
	move.l	%sp@(4), %a1
	moveq	#0xffffff83, %d0
	trap	#15
	rts
