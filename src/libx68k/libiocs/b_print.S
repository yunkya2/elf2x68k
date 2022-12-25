| int _iocs_b_print (const char *);
.text
.even
.global _iocs_b_print
.type _iocs_b_print,@function
_iocs_b_print:
	move.l	%sp@(4), %a1
	moveq	#0x21, %d0
	trap	#15
	rts
