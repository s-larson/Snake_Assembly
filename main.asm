;
; Snake.asm
;
; Created: 2019-04-25 13:47:41
; Author : potat & co
;


.DEF end = r16
.DEF temp1 = r17
.DEF temp2 = r18
.DEF temp3 = r19
.DEF temp4 = r20
.DEF temp5 = r21
.DEF pointerValue = r22
.DEF food = r23
.DEF length = r24
.DEF direction = r25

.DSEG
snakebody:		.BYTE 16

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
	ldi YH, HIGH(snakebody)
	ldi YL, LOW(snakebody)
	
	// Snake head
	ldi temp1, 0b10101010
	st Y, temp1
	ldi temp1, 0b00101010
	std Y+1, temp1
	ldi temp1, 0b11001010
	std Y+2, temp1	
	ldi temp1, 0b01001010
	std Y+3, temp1
	ldi length, 4
	
	// Enable Joystick
	ldi r16, 0b01100000
	lds temp1, ADMUX
	or r16, temp1
	sts ADMUX, r16
	ldi r16, 0b10000111
	lds temp1, ADCSRA
	or r16, temp1
	sts ADCSRA, r16

main:
	ldi pointerValue, 0
	call translateLoop
	jmp calcrow_0

translateLoop:
	ld temp1, Y
	mov temp2, temp1
	ori temp2, 0b00001111
	
	cpi temp2, 0
	cpi temp2, 1
	cpi temp2, 4
	cpi temp2, 8

	subi YL, -1
	jmp translateLoop
	ret
calcrow_0:
	ld temp1, Y
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_0
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från temp1
	subi temp1, 0b10000000
calc64_0:
	cpi temp1, 0b01000000
	brlo calc32_0
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi temp1, 0b01000000
calc32_0:
	cpi temp1, 0b00100000
	brlo calc16_0
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi temp1, 0b00100000
calc16_0:
	cpi temp1, 0b00010000
	brlo calc8_0
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi temp1, 0b00010000
calc8_0:
	cpi temp1, 0b00001000
	brlo calc4_0
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8

	subi temp1, 0b00001000
calc4_0:
	cpi temp1, 0b00000100
	brlo calc2_0
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi temp1, 0b00000100
calc2_0:
	cpi temp1, 0b00000010
	brlo calc1_0
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi temp1, 0b00000010
calc1_0:
	cpi temp1, 0b00000001
	brlo outputrow_0
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi temp1, 0b00000001

outputrow_0:
 
	ldi temp1, 0b00000001
	out PORTC, temp1

	mov temp1, end
	ANDI temp1, 0b11000000
	out PORTD, temp1

	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	
	call delay1
	
calcrow_1:
	ldd temp1, Y+1

	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_1
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från temp1
	subi temp1, 0b10000000
calc64_1:
	cpi temp1, 0b01000000
	brlo calc32_1
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi temp1, 0b01000000
calc32_1:
	cpi temp1, 0b00100000
	brlo calc16_1
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi temp1, 0b00100000
calc16_1:
	cpi temp1, 0b00010000
	brlo calc8_1
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi temp1, 0b00010000
calc8_1:
	cpi temp1, 0b00001000
	brlo calc4_1
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi temp1, 0b00001000
calc4_1:
	cpi temp1, 0b00000100
	brlo calc2_1
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi temp1, 0b00000100
calc2_1:
	cpi temp1, 0b00000010
	brlo calc1_1
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi temp1, 0b00000010
calc1_1:
	cpi temp1, 0b00000001
	brlo outputrow_1
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi temp1, 0b00000001

outputrow_1:
 
	ldi temp1, 0b00000010
	out PORTC, temp1

	mov temp1, end
	ANDI temp1, 0b11000000
	out PORTD, temp1

	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1

	call delay1

calcrow_2:
	ldd temp1, Y+2

	ldi end, 0b00000000

	cpi temp1, 0b10000000
	brlo calc64_2
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från temp1
	subi temp1, 0b10000000
calc64_2:
	cpi temp1, 0b01000000
	brlo calc32_2
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi temp1, 0b01000000
calc32_2:
	cpi temp1, 0b00100000
	brlo calc16_2
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi temp1, 0b00100000
calc16_2:
	cpi temp1, 0b00010000
	brlo calc8_2
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi temp1, 0b00010000
calc8_2:
	cpi temp1, 0b00001000
	brlo calc4_2
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi temp1, 0b00001000
calc4_2:
	cpi temp1, 0b00000100
	brlo calc2_2
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi temp1, 0b00000100
calc2_2:
	cpi temp1, 0b00000010
	brlo calc1_2
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi temp1, 0b00000010
calc1_2:
	cpi temp1, 0b00000001
	brlo outputrow_2
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi temp1, 0b00000001

outputrow_2:
 
	ldi temp1, 0b00000100
	out PORTC, temp1

	mov temp1, end
	ANDI temp1, 0b11000000
	out PORTD, temp1

	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1

	call delay1

calcrow_3:
	ldd temp1, Y+3

	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_3
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från temp1
	subi temp1, 0b10000000
calc64_3:
	cpi temp1, 0b01000000
	brlo calc32_3
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi temp1, 0b01000000
calc32_3:
	cpi temp1, 0b00100000
	brlo calc16_3
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi temp1, 0b00100000
calc16_3:
	cpi temp1, 0b00010000
	brlo calc8_3
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi temp1, 0b00010000
calc8_3:
	cpi temp1, 0b00001000
	brlo calc4_3
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi temp1, 0b00001000
calc4_3:
	cpi temp1, 0b00000100
	brlo calc2_3
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi temp1, 0b00000100
calc2_3:
	cpi temp1, 0b00000010
	brlo calc1_3
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi temp1, 0b00000010
calc1_3:
	cpi temp1, 0b00000001
	brlo outputrow_3
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi temp1, 0b00000001

outputrow_3:
 
	ldi temp1, 0b00001000
	out PORTC, temp1

	mov temp1, end
	ANDI temp1, 0b11000000
	out PORTD, temp1

	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1

	call delay1

calcrow_4:
	ldd temp1, Y+4

	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_4
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från temp1
	subi temp1, 0b10000000
calc64_4:
	cpi temp1, 0b01000000
	brlo calc32_4
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi temp1, 0b01000000
calc32_4:
	cpi temp1, 0b00100000
	brlo calc16_4
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi temp1, 0b00100000
calc16_4:
	cpi temp1, 0b00010000
	brlo calc8_4
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi temp1, 0b00010000
calc8_4:
	cpi temp1, 0b00001000
	brlo calc4_4
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi temp1, 0b00001000
calc4_4:
	cpi temp1, 0b00000100
	brlo calc2_4
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi temp1, 0b00000100
calc2_4:
	cpi temp1, 0b00000010
	brlo calc1_4
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi temp1, 0b00000010
calc1_4:
	cpi temp1, 0b00000001
	brlo outputrow_4
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi temp1, 0b00000001

outputrow_4:
	out PORTC, r1 ;?

	mov temp1, end
	ANDI temp1, 0b11000000
	ORI temp1, 0b00000100
	out PORTD, temp1

	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1

	call delay1

calcrow_5:
	ldd temp1, Y+5

	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_5
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från temp1
	subi temp1, 0b10000000
calc64_5:
	cpi temp1, 0b01000000
	brlo calc32_5
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi temp1, 0b01000000
calc32_5:
	cpi temp1, 0b00100000
	brlo calc16_5
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi temp1, 0b00100000
calc16_5:
	cpi temp1, 0b00010000
	brlo calc8_5
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi temp1, 0b00010000
calc8_5:
	cpi temp1, 0b00001000
	brlo calc4_5
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi temp1, 0b00001000
calc4_5:
	cpi temp1, 0b00000100
	brlo calc2_5
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi temp1, 0b00000100
calc2_5:
	cpi temp1, 0b00000010
	brlo calc1_5
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi temp1, 0b00000010
calc1_5:
	cpi temp1, 0b00000001
	brlo outputrow_5
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi temp1, 0b00000001

outputrow_5:
	mov temp1, end
	ANDI temp1, 0b11000000
	ORI temp1, 0b00001000
	out PORTD, temp1

	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1

	call delay1

calcrow_6:
	ldd temp1, Y+6
	
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_6
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från temp1
	subi temp1, 0b10000000
calc64_6:
	cpi temp1, 0b01000000
	brlo calc32_6
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi temp1, 0b01000000
calc32_6:
	cpi temp1, 0b00100000
	brlo calc16_6
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi temp1, 0b00100000
calc16_6:
	cpi temp1, 0b00010000
	brlo calc8_6
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi temp1, 0b00010000
calc8_6:
	cpi temp1, 0b00001000
	brlo calc4_6
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi temp1, 0b00001000
calc4_6:
	cpi temp1, 0b00000100
	brlo calc2_6
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi temp1, 0b00000100
calc2_6:
	cpi temp1, 0b00000010
	brlo calc1_6
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi temp1, 0b00000010
calc1_6:
	cpi temp1, 0b00000001
	brlo outputrow_6
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi temp1, 0b00000001

outputrow_6:
	mov temp1, end
	ANDI temp1, 0b11000000
	ORI temp1, 0b00010000
	out PORTD, temp1

	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1

	call delay1

calcrow_7:
	ldd temp1, Y+7

	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_7
	;lägg till 64 till end
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	;ta bort 128 från temp1
	subi temp1, 0b10000000
calc64_7:
	cpi temp1, 0b01000000
	brlo calc32_7
	;lägg till 128
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	;ta bort 64
	subi temp1, 0b01000000
calc32_7:
	cpi temp1, 0b00100000
	brlo calc16_7
	;lägg till 1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	;ta bort 32
	subi temp1, 0b00100000
calc16_7:
	cpi temp1, 0b00010000
	brlo calc8_7
	;lägg till 2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	;ta bort 16
	subi temp1, 0b00010000
calc8_7:
	cpi temp1, 0b00001000
	brlo calc4_7
	;lägg till 4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	;ta bort 8
	subi temp1, 0b00001000
calc4_7:
	cpi temp1, 0b00000100
	brlo calc2_7
	;lägg till 8
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	;ta bort 4
	subi temp1, 0b00000100
calc2_7:
	cpi temp1, 0b00000010
	brlo calc1_7
	;lägg till 16
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	;ta bort 2
	subi temp1, 0b00000010
calc1_7:
	cpi temp1, 0b00000001
	brlo outputrow_7
	;lägg till 32
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	;ta bort 1
	subi temp1, 0b00000001

outputrow_7:
	mov temp1, end
	ANDI temp1, 0b11000000
	ORI temp1, 0b00100000
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	jmp joyinputX



joyinputX://Listen to joystick
	lds temp2, ADMUX
	ldi temp3, 0b00000101
	or temp2, temp3
	sts ADMUX, temp2
	lds temp2, ADCSRA
	ori	temp2, 0b01000000
	sts ADCSRA, temp2

wait1://Wait until "read" is finished
	lds temp2, ADCSRA
	sbrc temp2, ADSC //Check 6th bit if 0
	jmp wait1
	lds temp3, ADCH
		std Y+7, temp3 // temp
	cpi temp3, 50
	brsh east
	cpi temp3, 0
	brlo west

joyinputY://Listen to joystick
	lds temp2, ADMUX
	ldi temp3, 0b11111110
	and temp2, temp3
	ldi temp3, 0b00000100
	or temp2, temp3
	sts ADMUX, temp2
	lds temp2, ADCSRA
	ori	temp2, 0b01000000
	sts ADCSRA, temp2
wait2://Wait until "read" is finished
	lds temp2, ADCSRA
	sbrc temp2, ADSC //Check 6th bit if 0
	jmp wait2
	lds temp3, ADCH
		std Y+7, temp3 // temp
	cpi temp3, 50	// Branches north if input > 130
	brsh north
	cpi temp3, 0	// if input < 100
	brlo south

	jmp main

north:
	ldi direction, 0b00001000
	jmp calcHeadPosition
south:
	ldi direction, 0b00000100
	jmp calcHeadPosition
east:
	ldi direction, 0b00000010
	jmp calcHeadPosition
west:
	ldi direction, 0b00000001
	jmp calcHeadPosition

delay1:// Delay called after each output
    ldi  temp3, 13
    ldi  temp4, 252
L1: dec  temp4
    brne L1
    dec  temp3
    brne L1
	ret

calcHeadPosition:
	ld temp2, Y
	cp temp2, r1		// If row value is greater than 0, move depending on direction
	brne calcDirection
    subi YL, -1 	// Increment, run again if no hit
	jmp calcHeadPosition

calcDirection:
	ldi YL, LOW(snakebody) // ta bort
	sbrc direction, 0
	call moveWest
	sbrc direction, 1
	call moveEast
	sbrc direction, 2
	call moveSouth
	sbrc direction, 3
	call moveNorth
	ldi YL, LOW(snakebody) //reset pointer
	jmp main
moveWest:
	ldi temp3, 0b00011000
	st Y, temp3
	ret
moveEast:
	//lsr temp2
	ldi temp3, 0b00011000
	std Y+1, temp3	//std Y+1, temp3
	ret
moveNorth:
	ldi temp3, 0b00011000
	std Y+2, temp3//std Y+7, temp3
	ret
moveSouth:
	ldi temp3, 0b00011000
	std Y+3, temp3
	ret		



resetMatrix: ;Troubleshooting
	st Y, r1            ;Reset led-matrix
    std Y+1, r1
    std Y+2, r1
    std Y+3, r1
    std Y+4, r1
    std Y+5, r1
    std Y+6, r1
    std Y+7, r1
	ret
