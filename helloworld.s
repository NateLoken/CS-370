	.data
	.comm x, 4, 4
	.comm y, 4, 4
	.section	.rodata
.LC0:
	.string	"if works!"
.LC1:
	.string	"%d "
.LC2:
	.string	""
.LC3:
	.string	"not-equals works!"
.LC4:
	.string	"equals-equals works!"
.LC5:
	.string	"if shouldn't work..."
.LC6:
	.string	"else works!"
.LC7:
	.string	"goodbye %s %d\n"
.LC8:
	.string	"second"
.LC9:
	.string	"Hello World!\n"
	.text
	.globl	func
	.type	func, @function
func:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$42, %edx
	pushq	%rdx
	movl	$21, %edx
	popq	%rcx
	cmp	%edx, %ecx
	jg	LL101
	jmp	LL102
LL101:
	movq	$.LC0, %rdi
	call	puts
LL102:
	movl	$0, %edx
	movl	%edx, x
	movl %edx, %esi
	jmp LL104
LL103:
	movq	$.LC1, %rdi
	movl	x, %edx
	call	printf
	movl	x, %edx
	pushq	%rdx
	movl	$1, %edx
	popq	%rcx
	addl	%ecx, %edx
	movl	%edx, x
	movl %edx, %esi
LL104:
	movl	x, %edx
	pushq	%rdx
	movl	$10, %edx
	popq	%rcx
	cmp	%edx, %ecx
	jl	LL103
	popq	%rbp
	movl	$0, %eax
	ret

	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	call	func
	movq	$.LC2, %rdi
	call	puts
	movl	$21, %edx
	pushq	%rdx
	movl	$42, %edx
	popq	%rcx
	cmp	%edx, %ecx
	jne	LL105
	jmp	LL106
LL105:
	movq	$.LC3, %rdi
	call	puts
LL106:
	movl	$21, %edx
	pushq	%rdx
	movl	$21, %edx
	popq	%rcx
	cmp	%edx, %ecx
	je	LL107
	jmp	LL108
LL107:
	movq	$.LC4, %rdi
	call	puts
LL108:
	movl	$21, %edx
	pushq	%rdx
	movl	$42, %edx
	popq	%rcx
	cmp	%edx, %ecx
	jg	LL109
	movq	$.LC6, %rdi
	call	puts
	jmp	LL110
LL109:
	movq	$.LC5, %rdi
	call	puts
LL110:
	movq	$.LC7, %rdi
	movq	$.LC8, %rsi
	movl	$42, %edx
	pushq	%rdx
	movl	$4, %edx
	pushq	%rdx
	movl	x, %edx
	pushq	%rdx
	movl	$2, %edx
	popq	%rcx
	addl	%ecx, %edx
	popq	%rcx
	addl	%ecx, %edx
	popq	%rcx
	addl	%ecx, %edx
	call	printf
	movq	$.LC9, %rdi
	call	puts
	popq	%rbp
	movl	$0, %eax
	ret

