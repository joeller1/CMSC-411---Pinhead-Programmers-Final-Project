@ FIR Filter
.text
.global _start
_start:

LDR r0, =in             @ load the floating point value
LDR r1, [r0]            @ stick it into r1
LDR r0, =mant           @ load the bitmask for mantissa
LDR r2, [r0]            @ stick it into r2
LDR r0, =exp            @ load the bitmask for exponent
LDR r3, [r0]            @ stick it into r3
LDR r0, =msize          @ load up mantissa size (23)
LDR r0, [r0]            @ keep it in r0
AND r4, r1, r2          @ get mantissa into r4
ADD r2, r2, #1          @ add one to the bitmask, get 0x800000
ORR r4, r4, r2          @ this adds the implied back on, adding a bit
LSR r1, r1, #23         @ shift off the mantissa
AND r5, r1, r3          @ r5 has the exponent
SUB r5, r5, #127        @ account for 127 offset
SUB r5, r0, r5          @ shift the bits to get integer part
SUB r5, r5, #16         @ shift to get fixed point
LSR r7, r4, r5          @ r2 is now floating point in fixed form
LSR r1, r1, #8          @ r1 is now the sign bit

@ if negative
EOR r0, r0              @  make r0 = 0
CMP r1, r0              @ if sign bit is negative (1)
BEQ done
EOR r0, r0              @  make r0 = 0
SUB r0, r0, #1          @ r0 = 0xFFFFFFFF
EOR r7, r7, r0          @ invert the bits of the number
ADD r7, r7, #1          @ twos compliment
done:

MOV r4, r7		@ put input into r4


MOV r1, #0		@ bit shift and calculation register
LDR r0, =x		
LDR r2, [r0] 	@ load x into r2
LDR r0, =y		
LDR r3, [r0]	@ load y into r3
LDR r0, =Alpha		
LDR r5, [r0, r1]	@ load array into r5
MOV r6, #0		@ newx
MOV r7, #0		@ bit shift and calculation register
MOV r0, #0 		@ holds the counter, increment by 4
MOV r10, #0		@ holds the counter, increment by 1

forloop:
CMP r0, #44
BGE exit
MOV r6, #0		@ newx into r6
LSR r9, r4, #31
CMP r9, #0
BEQ pos
LSR r1, r3, r10	@ bit shift right by i for y
ADD r6, r2, r1	@ newx = x + r1
LSR r7, r2, r10	@ bit shift right by i for x
SUB r3, r3, r7	@ y -= r7
MOV r2, r6		@ x = newx
LDR	r5, =Alpha
LDR r8, [r5,r0]	@ loading alpha[i] into r8
ADD r4, r4, r8 		@ add the alpha[i] value
ADD r0, r0, #4		@ increment r0
ADD r10, r10, #1	@ increment r10
B forloop
pos:
LSR r1, r3, r10	@ bit shift right by i for y
SUB r6, r2, r1	@ newx = x - r1
LSR r7, r2, r10	@ bit shift right by i for x
ADD r3, r3, r7	@ y += r7
MOV r2, r6		@ x = newx
LDR	r5, =Alpha
LDR r8, [r5,r0]	@ loading alpha[i] into r8
SUB r4, r4, r8 		@ substract the alpha[i] value
ADD r0, r0, #4		@ increment r0
ADD r10, r10, #1	@ increment r10
B forloop
exit:

MOV r8, r3
MOV r7, r2
LSR r12, r7, #31        @ look at msb of number

@ if msb == 1
CMP r12, #0             @ check for negative (1)
BEQ else1
EOR r0, r0
SUB r0, r0, #1
EOR r7, r7, r0
ADD r7, r7, #1

else1:
CLZ r0, r7
MOV r1, #16
SUB r0, r1, r0
ADD r1, r0, #126
MOV r2, #8
SUB r2, r2, r0
LSL r7, r7, r2
LDR r2, =mant1
LDR r2, [r2]
EOR r7, r2
LSL r12, r12, #8
ORR r12, r12, r1
LSL r12, r12, #23
ORR r12, r12, r7
VMOV s0, r12

LSR r12, r8, #31        @ look at msb of number

@ if msb == 1
CMP r12, #0             @ check for negative (1)
BEQ else2
EOR r0, r0
SUB r0, r0, #1
EOR r8, r8, r0
ADD r8, r8, #1

else2:
CLZ r0, r8
MOV r1, #16
SUB r0, r1, r0
ADD r1, r0, #126
MOV r2, #8
SUB r2, r2, r0
LSL r8, r8, r2
LDR r2, =mant1
LDR r2, [r2]
EOR r8, r2
LSL r12, r12, #8
ORR r12, r12, r1
LSL r12, r12, #23
ORR r12, r12, r8
VMOV s1, r12

.data
Alpha:
	.word	2949120
	.word	1740963
	.word	919876
	.word	466945
	.word	234378
	.word	117303
	.word	58666
	.word	29334
	.word	14667
	.word	7333
	.word	3666
	.word	1833
	
x:	.word	39796 @ constant times the fixed number
y:	.word	0
@in:	.float	28.027 @ cos = 0.88237 , sin = 0.4705
@in:		.float	0	@ cos = 1 , sin = 0
@in:		.float	60	@ cos = 0.707, sin = 0.707
in:		.float	80	

mant:               .word 0x7FFFFF
mant1:              .word 0x800000
msize:              .word 23
exp:                .word 0xFF

.end