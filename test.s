	.data
##AST_DECL##
	.comm x, 4, 4
##AST_DECL##
	.comm y, 4, 4
##AST_DECL##
	.comm arr, 20, 32
	.section	.rodata
.LC0:
	.string 	"a = %d\n"
.LC1:
	.string 	"local=%d\n"
.LC2:
	.string 	"if works!\n"
.LC3:
	.string 	"else works!\n"
.LC4:
	.string 	"if works!\n"
.LC5:
	.string 	"else works!\n"
.LC6:
	.string 	"Test test"
.LC7:
	.string 	"goodbye"
.LC8:
	.string 	"third arg"
.LC9:
	.string 	"goodbye %s %d\n"
.LC10:
	.string 	"second"
.LC11:
	.string 	"Hello World!\n"
.LC12:
	.string 	"Test 1"
.LC13:
	.string 	"Test 2"
.LC14:
	.string 	"Test 3"
.LC15:
	.string 	"Test 4"
	.text
##AST_FUNCTION##
##AST_DECL##
	.comm a, 4, 4
##AST_DECL##
b:	.word 0
##AST_DECL##
s:	.word 0
##AST_DECL##
	.comm local, 4, 4
	.globl	func
	.type	func,@function
func:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$64, %rsp
##AST_ASSIGNMENT##
##AST_CONSTANT##
	movq	$10, %rdx
	push	%rdx
##AST_ASSIGNMENT##
##AST_EXPRESSION##
##AST_CONSTANT##
	movq	$2, %rdx
	pushq	%rdx
##AST_CONSTANT##
	movq	$3, %rdx
	popq	%rcx
	addq	%rcx, %rdx
	push	%rdx
##AST_CONSTANT##
	movq	$1, %rdx
	pop	%rcx
	movq	%rcx, arr(,%rdx,4)
##AST_ASSIGNMENT##
##AST_EXPRESSION##
##AST_CONSTANT##
	movq	$8, %rdx
	pushq	%rdx
##AST_CONSTANT##
	movq	$10, %rdx
	popq	%rcx
	addq	%rcx, %rdx
	push	%rdx
##AST_CONSTANT##
	movq	$2, %rdx
	pop	%rcx
	movq	%rcx, arr(,%rdx,4)
##AST_ASSIGNMENT##
##AST_CONSTANT##
	movq	$1, %rdx
	push	%rdx
##AST_CONSTANT##
	movq	$3, %rdx
	pop	%rcx
	movq	%rcx, arr(,%rdx,4)
##AST_ASSIGNMENT##
##AST_CONSTANT##
	movq	$4, %rdx
	push	%rdx
##AST_CONSTANT##
	movq	$4, %rdx
	pop	%rcx
	movq	%rcx, arr(,%rdx,4)
##AST_ASSIGNMENT##
##AST_CONSTANT##
	movq	$5, %rdx
	push	%rdx
##AST_CONSTANT##
	movq	$5, %rdx
	pop	%rcx
	movq	%rcx, arr(,%rdx,4)
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC0, %rdx
	movq	%rdx, %rdi
##AST_ARGUMENT##
##AST_VARREF##
	movq	-4(%rbp), %rdx
	movq	%rdx, %rsi
	movl	$0, %eax
	call	printf
##AST_ASSIGNMENT##
##AST_EXPRESSION##
##AST_CONSTANT##
	movq	$42, %rdx
	pushq	%rdx
##AST_CONSTANT##
	movq	$12, %rdx
	popq	%rcx
	addq	%rcx, %rdx
	push	%rdx
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC1, %rdx
	movq	%rdx, %rdi
##AST_ARGUMENT##
##AST_VARREF##
	movq	-4(%rbp), %rdx
	movq	%rdx, %rsi
	movl	$0, %eax
	call	printf
##AST_IFTHEN##
##AST_RELEXPR##
##AST_CONSTANT##
	movq	$20, %rdx
	pushq	%rdx
##AST_CONSTANT##
	movq	$10, %rdx
	popq	%rcx
	cmp	%rdx,%rcx
	jg	LL101
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC2, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
	jmp	LL102
LL101:
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC3, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
LL102:##AST_IFTHEN##
##AST_RELEXPR##
##AST_CONSTANT##
	movq	$20, %rdx
	pushq	%rdx
##AST_CONSTANT##
	movq	$10, %rdx
	popq	%rcx
	cmp	%rdx,%rcx
	jl	LL103
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC4, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
	jmp	LL104
LL103:
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC5, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
LL104:	movl	$0, %eax
	leave
	ret
##AST_FUNCTION##
##AST_DECL##
	.comm argc, 4, 4
##AST_DECL##
argv:	.word 0
	.globl	main
	.type	main,@function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$64, %rsp
##AST_ASSIGNMENT##
##AST_CONSTANT##
	movq	$0, %rdx
	push	%rdx
##AST_WHILE##
	jmp	LL105
LL106:
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC6, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
##AST_ASSIGNMENT##
##AST_EXPRESSION##
##AST_VARREF##
	movq	-4(%rbp), %rdx
	pushq	%rdx
##AST_CONSTANT##
	movq	$1, %rdx
	popq	%rcx
	addq	%rcx, %rdx
	push	%rdx
LL105:
##AST_RELEXPR##
##AST_VARREF##
	movq	-4(%rbp), %rdx
	pushq	%rdx
##AST_CONSTANT##
	movq	$5, %rdx
	popq	%rcx
	cmp	%rdx,%rcx
	jl	LL106
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$42, %rdx
	movq	%rdx, %rdi
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC7, %rdx
	movq	%rdx, %rsi
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC8, %rdx
	movq	%rdx, %rdx
	movl	$0, %eax
	call	func
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC9, %rdx
	movq	%rdx, %rdi
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC10, %rdx
	movq	%rdx, %rsi
##AST_ARGUMENT##
##AST_EXPRESSION##
##AST_CONSTANT##
	movq	$42, %rdx
	pushq	%rdx
##AST_EXPRESSION##
##AST_CONSTANT##
	movq	$4, %rdx
	pushq	%rdx
##AST_EXPRESSION##
##AST_VARREF##
	movq	-4(%rbp), %rdx
	pushq	%rdx
##AST_CONSTANT##
	movq	$2, %rdx
	popq	%rcx
	addq	%rcx, %rdx
	popq	%rcx
	addq	%rcx, %rdx
	popq	%rcx
	addq	%rcx, %rdx
	movq	%rdx, %rdx
	movl	$0, %eax
	call	printf
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC11, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC12, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC13, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC14, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
##AST_FUNCALL##
##AST_ARGUMENT##
##AST_CONSTANT##
	movq	$.LC15, %rdx
	movq	%rdx, %rdi
	movl	$0, %eax
	call	puts
	movl	$0, %eax
	leave
	ret
##AST_FUNCTION##
##AST_DECL##
	.comm one, 4, 4
##AST_DECL##
	.comm two, 4, 4
##AST_DECL##
	.comm three, 4, 4
##AST_DECL##
	.comm four, 4, 4
##AST_DECL##
	.comm hey, 4, 4
##AST_DECL##
	.comm look, 4, 4
##AST_DECL##
	.comm variables, 4, 4
	.globl	localTest
	.type	localTest,@function
localTest:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$64, %rsp
	movl	$0, %eax
	leave
	ret
