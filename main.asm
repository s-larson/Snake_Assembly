;
; Snake.asm
;
; Created: 2019-04-25 13:47:41
; Author : potat
;


.DEF end = r16
.DEF row0 = r18 ;C0
.DEF row1 = r19 ;C1
.DEF row2 = r20 ;C2
.DEF row3 = r21 ;C3
.DEF row4 = r22 ;D2
.DEF row5 = r23 ;D3
.DEF row6 = r24 ;D4
.DEF row7 = r25 ;D5

.DSEG
matrix:   .BYTE 8

.CSEG
.ORG 0x0000
nop

main:
ldi row0, 0b10101010	;D6 och D7 är switchade
ldi row1, 0b11110111
ldi row2, 0b10111011
ldi row3, 0b11001011
ldi row4, 0b10111001
ldi row5, 0b01110110
ldi row6, 0b11111011
ldi row7, 0b11011111
 
calcrow_0:
	mov r17, row0
	ldi end, 0b00000000

	cpi r17, 0b10000000
	brlo calc64_0
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från r17
	subi r17, 0b10000000
calc64_0:
	cpi r17, 0b01000000
	brlo calc32_0
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi r17, 0b01000000
calc32_0:
	cpi r17, 0b00100000
	brlo calc16_0
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi r17, 0b00100000
calc16_0:
	cpi r17, 0b00010000
	brlo calc8_0
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi r17, 0b00010000
calc8_0:
	cpi r17, 0b00001000
	brlo calc4_0
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi r17, 0b00001000
calc4_0:
	cpi r17, 0b00000100
	brlo calc2_0
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi r17, 0b00000100
calc2_0:
	cpi r17, 0b00000010
	brlo calc1_0
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi r17, 0b00000010
calc1_0:
	cpi r17, 0b00000001
	brlo calcloopexit_0
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

calcloopexit_0:
 
	ldi r17, 0b00000001
	out PORTC, r17

	mov r17, end
	ANDI r17, 0b11000000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	nop

	out PORTB, r1
	out PORTC, r1
	out PORTD, r1
	;jmp endloop


    //jmp calcloopexit_0

calcrow_1:
	mov r17, row1
	ldi end, 0b00000000

	cpi r17, 0b10000000
	brlo calc64_1
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från r17
	subi r17, 0b10000000
calc64_1:
	cpi r17, 0b01000000
	brlo calc32_1
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi r17, 0b01000000
calc32_1:
	cpi r17, 0b00100000
	brlo calc16_1
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi r17, 0b00100000
calc16_1:
	cpi r17, 0b00010000
	brlo calc8_1
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi r17, 0b00010000
calc8_1:
	cpi r17, 0b00001000
	brlo calc4_1
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi r17, 0b00001000
calc4_1:
	cpi r17, 0b00000100
	brlo calc2_1
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi r17, 0b00000100
calc2_1:
	cpi r17, 0b00000010
	brlo calc1_1
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi r17, 0b00000010
calc1_1:
	cpi r17, 0b00000001
	brlo calcloopexit_1
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

calcloopexit_1:
 
	ldi r17, 0b00000010
	out PORTC, r17

	mov r17, end
	ANDI r17, 0b11000000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	jmp calcloopexit_1

calcrow_2:
	mov r17, row2
	ldi end, 0b00000000

	cpi r17, 0b10000000
	brlo calc64_2
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från r17
	subi r17, 0b10000000
calc64_2:
	cpi r17, 0b01000000
	brlo calc32_2
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi r17, 0b01000000
calc32_2:
	cpi r17, 0b00100000
	brlo calc16_2
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi r17, 0b00100000
calc16_2:
	cpi r17, 0b00010000
	brlo calc8_2
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi r17, 0b00010000
calc8_2:
	cpi r17, 0b00001000
	brlo calc4_2
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi r17, 0b00001000
calc4_2:
	cpi r17, 0b00000100
	brlo calc2_2
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi r17, 0b00000100
calc2_2:
	cpi r17, 0b00000010
	brlo calc1_2
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi r17, 0b00000010
calc1_2:
	cpi r17, 0b00000001
	brlo calcloopexit_2
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

calcloopexit_2:
 
	ldi r17, 0b00000100
	out PORTC, r17

	mov r17, end
	ANDI r17, 0b11000000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	jmp calcloopexit_2

calcrow_3:
	mov r17, row3
	ldi end, 0b00000000

	cpi r17, 0b10000000
	brlo calc64_3
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från r17
	subi r17, 0b10000000
calc64_3:
	cpi r17, 0b01000000
	brlo calc32_3
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi r17, 0b01000000
calc32_3:
	cpi r17, 0b00100000
	brlo calc16_3
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi r17, 0b00100000
calc16_3:
	cpi r17, 0b00010000
	brlo calc8_3
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi r17, 0b00010000
calc8_3:
	cpi r17, 0b00001000
	brlo calc4_3
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi r17, 0b00001000
calc4_3:
	cpi r17, 0b00000100
	brlo calc2_3
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi r17, 0b00000100
calc2_3:
	cpi r17, 0b00000010
	brlo calc1_3
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi r17, 0b00000010
calc1_3:
	cpi r17, 0b00000001
	brlo calcloopexit_3
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

calcloopexit_3:
 
	ldi r17, 0b00000100
	out PORTC, r17

	mov r17, end
	ANDI r17, 0b11000000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	jmp calcloopexit_3

calcrow_4:
	mov r17, row4
	ldi end, 0b00000000

	cpi r17, 0b10000000
	brlo calc64_4
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från r17
	subi r17, 0b10000000
calc64_4:
	cpi r17, 0b01000000
	brlo calc32_4
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi r17, 0b01000000
calc32_4:
	cpi r17, 0b00100000
	brlo calc16_4
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi r17, 0b00100000
calc16_4:
	cpi r17, 0b00010000
	brlo calc8_4
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi r17, 0b00010000
calc8_4:
	cpi r17, 0b00001000
	brlo calc4_4
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi r17, 0b00001000
calc4_4:
	cpi r17, 0b00000100
	brlo calc2_4
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi r17, 0b00000100
calc2_4:
	cpi r17, 0b00000010
	brlo calc1_4
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi r17, 0b00000010
calc1_4:
	cpi r17, 0b00000001
	brlo calcloopexit_4
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

calcloopexit_4:
	out PORTC, r1 ;?

	mov r17, end
	ANDI r17, 0b11000000
	ORI r17, 0b00000100
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	jmp calcloopexit_4

calcrow_5:
	mov r17, row5
	ldi end, 0b00000000

	cpi r17, 0b10000000
	brlo calc64_5
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från r17
	subi r17, 0b10000000
calc64_5:
	cpi r17, 0b01000000
	brlo calc32_5
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi r17, 0b01000000
calc32_5:
	cpi r17, 0b00100000
	brlo calc16_5
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi r17, 0b00100000
calc16_5:
	cpi r17, 0b00010000
	brlo calc8_5
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi r17, 0b00010000
calc8_5:
	cpi r17, 0b00001000
	brlo calc4_5
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi r17, 0b00001000
calc4_5:
	cpi r17, 0b00000100
	brlo calc2_5
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi r17, 0b00000100
calc2_5:
	cpi r17, 0b00000010
	brlo calc1_5
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi r17, 0b00000010
calc1_5:
	cpi r17, 0b00000001
	brlo calcloopexit_5
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

calcloopexit_5:
	out PORTC, r1 ;?

	mov r17, end
	ANDI r17, 0b11000000
	ORI r17, 0b00001000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	jmp calcloopexit_5

calcrow_6:
	mov r17, row6
	ldi end, 0b00000000

	cpi r17, 0b10000000
	brlo calc64_6
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från r17
	subi r17, 0b10000000
calc64_6:
	cpi r17, 0b01000000
	brlo calc32_6
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi r17, 0b01000000
calc32_6:
	cpi r17, 0b00100000
	brlo calc16_6
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi r17, 0b00100000
calc16_6:
	cpi r17, 0b00010000
	brlo calc8_6
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi r17, 0b00010000
calc8_6:
	cpi r17, 0b00001000
	brlo calc4_6
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi r17, 0b00001000
calc4_6:
	cpi r17, 0b00000100
	brlo calc2_6
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi r17, 0b00000100
calc2_6:
	cpi r17, 0b00000010
	brlo calc1_6
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi r17, 0b00000010
calc1_6:
	cpi r17, 0b00000001
	brlo calcloopexit_6
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

calcloopexit_6:
 
	out PORTC, r1 ;?

	mov r17, end
	ANDI r17, 0b11000000
	ORI r17, 0b00010000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	jmp calcloopexit_6

calcrow_7:
	mov r17, row7
	ldi end, 0b00000000

	cpi r17, 0b10000000
	brlo calc64_7
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från r17
	subi r17, 0b10000000
calc64_7:
	cpi r17, 0b01000000
	brlo calc32_7
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi r17, 0b01000000
calc32_7:
	cpi r17, 0b00100000
	brlo calc16_7
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi r17, 0b00100000
calc16_7:
	cpi r17, 0b00010000
	brlo calc8_7
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi r17, 0b00010000
calc8_7:
	cpi r17, 0b00001000
	brlo calc4_7
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi r17, 0b00001000
calc4_7:
	cpi r17, 0b00000100
	brlo calc2_7
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi r17, 0b00000100
calc2_7:
	cpi r17, 0b00000010
	brlo calc1_7
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi r17, 0b00000010
calc1_7:
	cpi r17, 0b00000001
	brlo calcloopexit_7
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

	jmp calcrow_7

calcloopexit_7:

	out PORTC, r1 ;?

	mov r17, end
	ANDI r17, 0b11000000
	ORI r17, 0b00100000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	jmp calcloopexit_7