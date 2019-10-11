	.text
	.section	.rodata
.LC0:
	.string	"hello world"
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
	movl	$0, %eax
	call	puts
	popq	%rbp
	.cfi_def_cfa	7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	func, .-func

.LC1:
	.string	"goodbye"
.LC2:
	.string	"second"
.LC3:
	.string	"printf call %s %d\n"
.LC4:
	.string	"and more"
.LC5:
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
	mov	$.LC1, %rdi
	mov	$.LC2, %rsi
	mov	$42, %rdx
	movl	$0, %eax
	call	func
	mov	$.LC3, %rdi
	mov	$.LC4, %rsi
	mov	$42, %rdx
	mov	$4, %rcx
	add	%rcx, %rdx
	mov	$5, %r8
	add	%r8, %rdx
	mov	$2, %r9
	add	%r9, %rdx
	movl	$0, %eax
	call	printf
	mov	$.LC5, %rdi
	movl	$0, %eax
	call	puts
	popq	%rbp
	.cfi_def_cfa	7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main

