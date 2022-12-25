| int _iocs_cache_st (void); /* rom 1.3 only */
.text
.even
.global _iocs_cache_st
.type _iocs_cache_st,@function
_iocs_cache_st:
	moveq	#1, %d1
	moveq	#0xffffffac, %d0
	trap	#15
	rts
