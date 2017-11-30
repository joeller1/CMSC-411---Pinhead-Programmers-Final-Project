_start:

@float to fixed
LDR r0, =num            @ load the floating point value
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
LSR r2, r4, r5          @ r2 is now floating point in fixed form
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
LSR r12, r7, #31        @ look at msb of number

@ if msb == 1
EOR r0, r0              @  make r0 = 0
CMP r12, r0             @ check for negative (1)
BEQ else
EOR r0, r0
SUB r0, r0, #1
EOR r7, r7, r0
ADD r7, r7, #1

else:
CLZ r0, r7
MOV r1, #16
SUB r0, r2, r0
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

.data
num:                .float -3.1415
mant:               .word 0x7FFFFF
mant1:              .word 0x800000
msize:              .word 23
exp:                .word 0xFF

.end