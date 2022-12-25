| int _iocs_s_phase (void);
.text
.even
.global _iocs_s_phase
.type _iocs_s_phase,@function
_iocs_s_phase:
	moveq	#9, %d1
	moveq	#0xfffffff5, %d0
	trap	#15
	rts
