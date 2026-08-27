/*
 * Variables used by crt0
 */

	.bss
	.even

	.global	_MCB
_MCB:		.space	4	| +0x00.l Memory Control Block
	.global	_PSTA
_PSTA:		.space	4	| +0x04.l TEXT Start
	.global	_PEND
_PEND:		.space	4	| +0x08.l TEXT End
	.global	_BSTA
_BSTA:		.space	4	| +0x0c.l BSS Start
	.global	_BEND
_BEND:		.space	4	| +0x10.l BSS End
	.global	_ENV0
_ENV0:		.space	4	| +0x14.l Environment
	.global	_cmdline
_cmdline:	.space	4	| +0x18.l Command Line

	.comm	_SSTA, 4	| +0x1c.l STACK Start
	.comm	_SEND, 4	| +0x20.l STACK End
