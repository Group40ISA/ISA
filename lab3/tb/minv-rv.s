#################
# Basic VERSION	
# This program takes an array v and computes
# min{|v[i]|}, the minimum of the absolute value,
# where v[i] is the i-th element in the array
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
	li x13,7          # put 7 in x16 
	li x5,7

	sw x13,0(x5)      # store the result	

	
