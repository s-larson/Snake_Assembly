;
; Snake.asm
;
; Created: 2019-04-25 13:47:41
; Author : potat & co
;


.DEF end = r16

.DSEG
matrix:   .BYTE 8

.CSEG
.ORG 0x0000
jmp init
nop

init:
	// Enable DDR registers
    ldi r16, 0b11111111
    out DDRC, r16
    ldi r16, 0b11111111
    out DDRD, r16
    ldi r16, 0b11111111
    out DDRB, r16

	// Pointers to matrix (snake)
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	
	// Spawn snake
	ldi r18, 0b00000000	;D6 och D7 är switchade
	st Y, r18
	ldi r18, 0b00000000
	std Y+1, r18
	ldi r18, 0b00000000
	std Y+2, r18	
	ldi r18, 0b00000000
	std Y+3, r18
	ldi r18, 0b00010000
	std Y+4, r18
	ldi r18, 0b00000000
	std Y+5, r18
	ldi r18, 0b00000000
	std Y+6, r18
	ldi r18, 0b00000000
	std Y+7, r18	

	// Enable Joystick
	ldi r16, 0b01100000
	lds r17, ADMUX
	or r16, r17
	sts ADMUX, r16
	ldi r16, 0b10000111
	lds r17, ADCSRA
	or r16, r17
	sts ADCSRA, r16

main:

calcrow_0:

	ld r17, Y
	
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
	brlo outputrow_0
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

outputrow_0:
 
	ldi r17, 0b00000001
	out PORTC, r17

	mov r17, end
	ANDI r17, 0b11000000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17
	
	call delay1
	
calcrow_1:
	ldd r17, Y+1

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
	brlo outputrow_1
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

outputrow_1:
 
	
	ldi r17, 0b00000010
	out PORTC, r17

	mov r17, end
	ANDI r17, 0b11000000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	call delay1

calcrow_2:
	ldd r17, Y+2

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
	brlo outputrow_2
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

outputrow_2:
 
	ldi r17, 0b00000100
	out PORTC, r17

	mov r17, end
	ANDI r17, 0b11000000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	call delay1

calcrow_3:
	ldd r17, Y+3

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
	brlo outputrow_3
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

outputrow_3:
 
	ldi r17, 0b00001000
	out PORTC, r17

	mov r17, end
	ANDI r17, 0b11000000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	call delay1

calcrow_4:
	ldd r17, Y+4

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
	brlo outputrow_4
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

outputrow_4:
	out PORTC, r1 ;?

	mov r17, end
	ANDI r17, 0b11000000
	ORI r17, 0b00000100
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	call delay1

calcrow_5:
	ldd r17, Y+5

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
	brlo outputrow_5
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

outputrow_5:
	mov r17, end
	ANDI r17, 0b11000000
	ORI r17, 0b00001000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	call delay1

calcrow_6:
	ldd r17, Y+6
	
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
	brlo outputrow_6
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

outputrow_6:
	mov r17, end
	ANDI r17, 0b11000000
	ORI r17, 0b00010000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	call delay1

calcrow_7:
	ldd r17, Y+7

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
	brlo outputrow_7
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi r17, 0b00000001

outputrow_7:

	mov r17, end
	ANDI r17, 0b11000000
	ORI r17, 0b00100000
	out PORTD, r17

	mov r17, end
	ANDI r17, 0b00111111
	out PORTB, r17

	call delay1

/*joyinputX://Listen to joystick
	lds r18, ADMUX
	ori r18, 0b00000101
	sts ADMUX, r18
	lds r18, ADCSRA
	ori	r18, 0b00100000
	sts ADCSRA, r18

wait1://Wait until "read" is finished
	lds r18, ADCSRA
	sbrc r18, 6 //Check 6th bit if 0
	jmp wait1
	lds r29, ADCH
	*/
joyinputY://Listen to joystick
	ldi r18, 0b01100100
	sts ADMUX, r18
	lds r18, ADCSRA
	ori	r18, 0b01000000
	sts ADCSRA, r18
wait2://Wait until "read" is finished
	lds r18, ADCSRA
	sbrc r18, ADSC //Check 6th bit if 0
	jmp wait2
	lds r24, ADCL
	lds r25, ADCH

	ldi r20, 0b11111111
	std Y+4, r20

	std Y+2, r25 //temp
	std Y+1, r24 //temp

	
	cpi r25, 0b01111111
	brge north	
	cpi r25, 0b00000010
	brlt south
	
	jmp main

south:
	ldi r21, 0b00111100
	std Y+7, r21
	jmp main

north:
	ldi r21, 0b00011000
	st Y, r21
	jmp main

delay1:// Delay called after each output
    ldi  r19, 255
    ldi  r20, 252
L1: dec  r20
    brne L1
    dec  r19
    brne L1
	ret