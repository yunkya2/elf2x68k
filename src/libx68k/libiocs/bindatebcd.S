| int _iocs_bindatebcd (int);
.text
.even
.global _iocs_bindatebcd
.type _iocs_bindatebcd,@function
_iocs_bindatebcd:
	move.l	%sp@(4), %d1
	moveq	#0x50, %d0
	trap	#15
	rts
