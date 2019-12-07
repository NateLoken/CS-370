	.data
x:	.word
y:	.word
	.section	.rodata
.LC0:
	.string "Hello World\n"
.LC1:
	.string "x = %d\n"
.LC2:
	.string "adios"
.LC3:
	.string "extra"
.LC4:
	.string "goodbye %s %d\n"
.LC5:
	.string "second"
.LC6:
	.string "Second Hello World!\n"
	.text
	.globl	func
	.type	func, @function
func:
	pushq	%rbp
	movq	%rsp, %rbp
	mov	$.LC0, %rdi
	call	puts
	movl	$2, %edx
	movl	%edx, x
	movl	%edx, %esi
	mov	$.LC1, %rdi
	movl	x, %edx
	call	printf
	popq	%rbp
	ret

	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$42, %edx
	mov	$.LC2, %rdi
	mov	$.LC3, %rsi
	call	func
	mov	$.LC4, %rdi
	mov	$.LC5, %rsi
	movl	$42, %edx
	pushq	%rdx
	movl	$4, %edx
	pushq	%rdx
	movl	x, %edx
	pushq	%rdx
	movl	$1, %edx
	popq	%rcx
	addl	%ecx, %edx
	popq	%rcx
	addl	%ecx, %edx
	popq	%rcx
	addl	%ecx, %edx
	call	printf
	mov	$.LC6, %rdi
	call	puts
	popq	%rbp
	ret
