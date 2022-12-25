| int _iocs_mpu_stat (void); /* rom 1.3 only */
.text
.even
.global _iocs_mpu_stat
.type _iocs_mpu_stat,@function
_iocs_mpu_stat:
	moveq	#0, %d1
	moveq	#0xffffffac, %d0
	trap	#15
	rts
