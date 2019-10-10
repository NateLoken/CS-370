	.text
	.section	.rodata
.LC0:
	.string	"hello world"
.LC1:
	.string	"this is a test"
	.text
	.globl	func
	.type	func, @function
func:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset	16
	.cfi_offset	6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register	6
	mov	$.LC0, %rdi
	call	puts
	mov	$.LC1, %rdi
	call	puts
	popq	%rbp
	.cfi_def_cfa	7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	func, .-func

.LC2:
	.string	"goodbye"
.LC3:
	.string	"second"
.LC4:
	.string	"printf call %s \n"
.LC5:
	.string	"and more"
.LC6:
	.string	"hello world"
	.text
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset	16
	.cfi_offset	6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register	6
	mov	$.LC2, %rdi
	mov	$.LC3, %rsi
	movl	$0, %eax
	call	func
	mov	$.LC4, %rdi
	mov	$.LC5, %rsi
	movl	$0, %eax
	call	printf
	mov	$.LC6, %rdi
	call	puts
	popq	%rbp
	.cfi_def_cfa	7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main

