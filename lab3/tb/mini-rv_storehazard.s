	.data
	.align	2
v:
	.word	10
	.word	-47
	.word	22
	.word	-3
	.word	15
	.word	27
	.word	-4
m:
	.word	0

	.text
	.align	2
	.globl	__start
__start:
li x3,3
li x1,268500992
li x2,4
add x8,x3,x2
sw x8,0(x1)