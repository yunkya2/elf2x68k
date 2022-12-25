| int _iocs_cache_md (int); /* rom 1.3 only */
.text
.even
.global _iocs_cache_md
.type _iocs_cache_md,@function
_iocs_cache_md:
	move.l	%d2, %sp@-
	move.l	%sp@(8), %d2
	moveq	#3, %d1
	move.l	%d2, %d0
	addq.l	#1, %d0
	beqs	lcachemd
	moveq	#2, %d1
	addq.l	#1, %d0
	bnes	lcachemd
	moveq	#4, %d1
lcachemd:
	moveq	#0xffffffac, %d0
	trap	#15
	move.l	%sp@+, %d2
	rts
