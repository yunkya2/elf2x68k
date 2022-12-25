| int _iocs_sp_init (void);
.text
.even
.global _iocs_sp_init
.type _iocs_sp_init,@function
_iocs_sp_init:
	moveq	#0xffffffc0, %d0
	trap	#15
	rts
