| int _iocs_sp_cgclr (int);
.text
.even
.global _iocs_sp_cgclr
.type _iocs_sp_cgclr,@function
_iocs_sp_cgclr:
	move.l	%sp@(4), %d1
	moveq	#0xffffffc3, %d0
	trap	#15
	rts
