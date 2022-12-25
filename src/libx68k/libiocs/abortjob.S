| __dead void _iocs_abortjob (void);
.text
.even
.global _iocs_abortjob
.type _iocs_abortjob,@function
_iocs_abortjob:
	moveq	#0xffffffff, %d0
	trap	#15
