| int _iocs_hsyncst (const void *);
.text
.even
.global _iocs_hsyncst
.type _iocs_hsyncst,@function
_iocs_hsyncst:
	move.l	%sp@(4), %a1
	moveq	#0x6e, %d0
	trap	#15
	rts
