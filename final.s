@ CMSC 411 Final Project
@ Teacher - Russel Cain
@ Pinhead Programmers - Group 18
@ Joey Eller, Matt Hood, Travis Nguyen, Chetra Mo
.text
.global _start
_start:

@ INPUT DEGREE VALUE FLOAT TO FIXED
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
MOV r0, #0              @  make r0 = 0
CMP r1, r0              @ if sign bit is negative (1)
BEQ done				@ branch to done and skip the next few lines
MOV r0, #0              @ if it is negative, make r0 = 0
SUB r0, r0, #1          @ if it is negative, r0 = 0xFFFFFFFF
EOR r7, r7, r0          @ if it is negative, invert the bits of the number
ADD r7, r7, #1          @ if it is negative, twos compliment
done:					@ escape if the thing is negative
MOV r4, r7				@ put fixed input value into r4

@ LOAD REGISTERS FOR SIN AND COS CALCULATIONS
MOV r1, #0				@ bit shift and calculation register
LDR r0, =x				@ load address of x
LDR r2, [r0] 			@ load x into r2
LDR r0, =y				@ load address of y
LDR r3, [r0]			@ load y into r3
LDR r5, =Alpha			@ load address of alpha int r5
MOV r6, #0				@ holds the newx value
MOV r7, #0				@ bit shift and calculation register
MOV r0, #0 				@ holds the counter, increment by 4
MOV r8, #0				@ holds actual alpha value at specific index
MOV r9, #0				@ holds the sign bit
MOV r10, #0				@ holds the counter, increment by 1

@ FOR LOOP SECTION FOR SIN AND COS CALCULATIONS
forloop:				@ start of for loop for findingg sin and cos in fixed form
CMP r0, #44				@ compare r0 (counter) to 11
BGE exit				@ if the counter is greater than 11, stop the loop
MOV r6, #0				@ set newx to 0 (not needed, only for comparison to c)
LSR r9, r4, #31			@ shift out the sign bit, put into r9
CMP r9, #0				@ compare the sign bit to 0
BEQ pos					@ if the sign bit is 0, the number is positive, jump to the 'pos' part of if statement
LSR r1, r3, r10			@ bit shift right by i for y
ADD r6, r2, r1			@ newx = x + r1
LSR r7, r2, r10			@ bit shift right by i for x
SUB r3, r3, r7			@ y -= r7
MOV r2, r6				@ x = newx
LDR r8, [r5,r0]			@ loading alpha[i] into r8
ADD r4, r4, r8 			@ add the alpha[i] value
ADD r0, r0, #4			@ increment r0 by 4
ADD r10, r10, #1		@ increment r10 by 1
B forloop				@ jump to the beginning of the loop
pos:					@ this section is if(input > 0)
LSR r1, r3, r10			@ bit shift right by i for y
SUB r6, r2, r1			@ newx = x - r1
LSR r7, r2, r10			@ bit shift right by i for x
ADD r3, r3, r7			@ y += r7
MOV r2, r6				@ x = newx
LDR r8, [r5,r0]			@ loading alpha[i] into r8
SUB r4, r4, r8 			@ substract the alpha[i] value
ADD r0, r0, #4			@ increment r0 by 4
ADD r10, r10, #1		@ increment r10 by 1
B forloop				@ jump to the beginning of the loop
exit:					@ excape route for ending the loop
MOV r8, r3				@ put fixed  value into r8
MOV r7, r2				@ put x value into r7

@ COS FIXED TO FLOAT
LSR r12, r7, #31        @ look at msb of number
CMP r12, #0             @ check for negative (1)
BEQ else1				@ if negative, skip the net few lines
MOV r0, #0				@ clear out r0			
SUB r0, r0, #1			@ subtract one to get 0xFFFFFFFF
EOR r7, r7, r0			@ invert the bits of the fixed value
ADD r7, r7, #1			@ twos compliment
else1:					@ this happens if positive
CLZ r0, r7				@ fill number of 0s into r0
MOV r1, #16				@ r1 = 16
SUB r0, r1, r0			@ r0 = 16 - number of 0s
ADD r1, r0, #126		@ r1 = r0 + 126 (for mantissa caluclation)
MOV r2, #8				@ r2 = 8
SUB r2, r2, r0			@ r2 = 8 - (16 - number of 0s)
LSL r7, r7, r2			@ shift left
LDR r2, =mant1			@ load address of mantissa inverse
LDR r2, [r2]			@ load value of mantissa inverse
EOR r7, r2				@ change negative bit
LSL r12, r12, #8		@ build the floating point number by shifting left 8 bits
ORR r12, r12, r1		@ add the exponent
LSL r12, r12, #23		@ shift 23 bits for mantissa
ORR r12, r12, r7		@ add the mantissa
VMOV s0, r12			@ put final float value into float register s0

@ SIN FIXED TO FLOAT
LSR r12, r8, #31        @ look at msb of number
CMP r12, #0             @ check for negative (1)
BEQ else2				@ if negative, skip the net few lines
MOV r0, #0				@ clear out r0			
SUB r0, r0, #1			@ subtract one to get 0xFFFFFFFF
EOR r8, r8, r0			@ invert the bits of the fixed value
ADD r8, r8, #1			@ twos compliment
else2:					@ this happens if positive
CLZ r0, r8				@ fill number of 0s into r0
MOV r1, #16				@ r1 = 16
SUB r0, r1, r0			@ r0 = 16 - number of 0s
ADD r1, r0, #126		@ r1 = r0 + 126 (for mantissa caluclation)
MOV r2, #8				@ r2 = 8
SUB r2, r2, r0			@ r2 = 8 - (16 - number of 0s)
LSL r8, r8, r2			@ shift left
LDR r2, =mant1			@ load address of mantissa inverse
LDR r2, [r2]			@ load value of mantissa inverse
EOR r8, r2				@ change negative bit
LSL r12, r12, #8		@ build the floating point number by shifting left 8 bits
ORR r12, r12, r1		@ add the exponent
LSL r12, r12, #23		@ shift 23 bits for mantissa
ORR r12, r12, r8		@ add the mantissa
VMOV s1, r12			@ put final float value into float register s1

.data
Alpha:
	.word	2949120		@ 45 * 65536
	.word	1740963		@ 26.6 * 65536
	.word	919876		@ 14.0 * 65536
	.word	466945		@ 7.1 * 65536
	.word	234378		@ 3.6 * 65536
	.word	117303		@ 1.8 * 65536
	.word	58666		@ 0.9 * 65536
	.word	29334		@ 0.4 * 65536
	.word	14667		@ 0.2 * 65536
	.word	7333		@ 0.1 * 65536
	.word	3666		@ 0.05 * 65536
	.word	1833		@ 0.02 * 65536
	
x:	.word	39796 		@ constant times the fixed number times 1
y:	.word	0			@ constant times the fixed number times 0
in:	.float	28.027 		@ cos = 0.88237 , sin = 0.4705
@in:		.float	30	@ cos = 0.867 , sin = 0.5
@in:		.float	45	@ cos = 0.707, sin = 0.707
@in:		.float	60	@ cos = 0.5 , sin = 0.867


mant:               .word 0x7FFFFF		@ mantissa value
mant1:              .word 0x800000		@ mantissa value + 1
msize:              .word 23			@ mantissa size
exp:                .word 0xFF			@ exponent value

@ end of program
.end