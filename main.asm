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
.DEF loopcounter = r22
.DEF food = r23
.DEF length = r24
.DEF direction = r25

.DSEG
snakebody:		.BYTE 16
matrix:			.BYTE 8

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
	ldi ZH, HIGH(snakebody)
	ldi ZL, LOW(snakebody)
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	
	// Snake head
	ldi temp1, 0b01110100				
	st Z, temp1
	ldi temp1, 0b01100100
	std Z+1, temp1
	ldi temp1, 0b01010100
	std Z+2, temp1	
	ldi temp1, 0b01000100
	std Z+3, temp1

	// Matrix
	st Y, r1
	std Y+1, r1
	std Y+2, r1
	std Y+3, r1
	std Y+4, r1
	std Y+5, r1
	std Y+6, r1
	std Y+7, r1

	// Tools
	ldi length, 4
	ldi loopcounter, 0
	
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
	call translatePositions		// Translates coordinates (Z) to matrix (Y)
	jmp drawMatrix				// Draws matrix

translatePositions:				// Iterates through Z (positions) to translate into matrix
	cp length, loopcounter
	breq exit2
	ld temp1, Z				// Z = 0 first iteration
	mov temp2, temp1
	andi temp2, 0b11110000	// Mask out X-value (first 4 bits)
	lsr temp2				// Shift 4 steps right to make compares easier
	lsr temp2
	lsr temp2
	lsr temp2
	cpi temp2, 0
	breq X_0
	cpi temp2, 1
	breq X_1
	cpi temp2, 2
	breq X_2
	cpi temp2, 3
	breq X_3
	cpi temp2, 4
	breq X_4
	cpi temp2, 5
	breq X_5
	cpi temp2, 6
	breq X_6
	cpi temp2, 7
	breq X_7

exit1:
	subi loopcounter, -1	// increment i
	subi ZL, -1				// increase pointer (next position is to be read) 
	jmp translatePositions
exit2:
	ldi ZL, LOW(snakebody)	// reset pointer before returning to main
	ret
X_0:
	ldi temp3, 0b00000001
	jmp calcYPos
X_1:
	ldi temp3, 0b00000010
	jmp calcYPos	
X_2:
	ldi temp3, 0b00000100
	jmp calcYPos
X_3:
	ldi temp3, 0b00001000
	jmp calcYPos
X_4:
	ldi temp3, 0b00010000
	jmp calcYPos
X_5:
	ldi temp3, 0b00100000
	jmp calcYPos
X_6:
	ldi temp3, 0b01000000
	jmp calcYPos
X_7:
	ldi temp3, 0b10000000
	jmp calcYPos
calcYPos:					// Calculate which Y position in matrix to draw to
	mov temp4, temp1
	andi temp4, 0b00001111
	cpi temp4, 0
	breq Y_0
	cpi temp4, 1
	breq Y_1
	cpi temp4, 2
	breq Y_2
	cpi temp4, 3
	breq Y_3
	cpi temp4, 4
	breq Y_4
	cpi temp4, 5
	breq Y_5
	cpi temp4, 6
	breq Y_6
	cpi temp4, 7
	breq Y_7 
Y_0:						// Save previous value of matrix row and insert new
	ld temp4, Y
	or temp3, temp4
	st Y, temp3
	jmp exit1
Y_1:
	ldd temp4, Y+1
	or temp3, temp4
	std Y+1, temp3
	jmp exit1
Y_2:
	ldd temp4, Y+2
	or temp3, temp4
	std Y+2, temp3
	jmp exit1
Y_3:
	ldd temp4, Y+3
	or temp3, temp4
	std Y+3, temp3
	jmp exit1
Y_4:
	ldd temp4, Y+4
	or temp3, temp4
	std Y+4, temp3
	jmp exit1
Y_5:
	ldd temp4, Y+5
	or temp3, temp4
	std Y+5, temp3
	jmp exit1
Y_6:
	ldd temp4, Y+6
	or temp3, temp4
	std Y+6, temp3
	jmp exit1
Y_7:
	ldd temp4, Y+7
	or temp3, temp4
	std Y+7, temp3
	jmp exit1

drawMatrix:		// Begin drawing one row at a time. Load in value from matrix and make compares.
				// Depending on value of row, the bits will translate correctly and be saved in register "end"
				// Finally, each row outputs "end" to corresponding port
calcrow_0:			
	ld temp1, Y
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_0
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_0:
	cpi temp1, 0b01000000
	brlo calc32_0
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_0:
	cpi temp1, 0b00100000
	brlo calc16_0
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_0:
	cpi temp1, 0b00010000
	brlo calc8_0
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_0:
	cpi temp1, 0b00001000
	brlo calc4_0
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_0:
	cpi temp1, 0b00000100
	brlo calc2_0
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_0:
	cpi temp1, 0b00000010
	brlo calc1_0
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_0:
	cpi temp1, 0b00000001
	brlo outputrow_0
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_1:
	cpi temp1, 0b01000000
	brlo calc32_1
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_1:
	cpi temp1, 0b00100000
	brlo calc16_1
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_1:
	cpi temp1, 0b00010000
	brlo calc8_1
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_1:
	cpi temp1, 0b00001000
	brlo calc4_1
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_1:
	cpi temp1, 0b00000100
	brlo calc2_1
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_1:
	cpi temp1, 0b00000010
	brlo calc1_1
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_1:
	cpi temp1, 0b00000001
	brlo outputrow_1
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_2:
	cpi temp1, 0b01000000
	brlo calc32_2
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_2:
	cpi temp1, 0b00100000
	brlo calc16_2
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_2:
	cpi temp1, 0b00010000
	brlo calc8_2
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_2:
	cpi temp1, 0b00001000
	brlo calc4_2
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_2:
	cpi temp1, 0b00000100
	brlo calc2_2
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_2:
	cpi temp1, 0b00000010
	brlo calc1_2
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_2:
	cpi temp1, 0b00000001
	brlo outputrow_2
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_3:
	cpi temp1, 0b01000000
	brlo calc32_3
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_3:
	cpi temp1, 0b00100000
	brlo calc16_3
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_3:
	cpi temp1, 0b00010000
	brlo calc8_3
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_3:
	cpi temp1, 0b00001000
	brlo calc4_3
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_3:
	cpi temp1, 0b00000100
	brlo calc2_3
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_3:
	cpi temp1, 0b00000010
	brlo calc1_3
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_3:
	cpi temp1, 0b00000001
	brlo outputrow_3
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_4:
	cpi temp1, 0b01000000
	brlo calc32_4
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_4:
	cpi temp1, 0b00100000
	brlo calc16_4
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_4:
	cpi temp1, 0b00010000
	brlo calc8_4
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_4:
	cpi temp1, 0b00001000
	brlo calc4_4
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_4:
	cpi temp1, 0b00000100
	brlo calc2_4
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_4:
	cpi temp1, 0b00000010
	brlo calc1_4
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_4:
	cpi temp1, 0b00000001
	brlo outputrow_4
	ldi r26, 0b00100000
	neg r26
	sub end, r26
	subi temp1, 0b00000001
outputrow_4:
	out PORTC, r1
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_5:
	cpi temp1, 0b01000000
	brlo calc32_5
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_5:
	cpi temp1, 0b00100000
	brlo calc16_5
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_5:
	cpi temp1, 0b00010000
	brlo calc8_5
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_5:
	cpi temp1, 0b00001000
	brlo calc4_5
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_5:
	cpi temp1, 0b00000100
	brlo calc2_5
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_5:
	cpi temp1, 0b00000010
	brlo calc1_5
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_5:
	cpi temp1, 0b00000001
	brlo outputrow_5
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_6:
	cpi temp1, 0b01000000
	brlo calc32_6
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_6:
	cpi temp1, 0b00100000
	brlo calc16_6
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_6:
	cpi temp1, 0b00010000
	brlo calc8_6
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_6:
	cpi temp1, 0b00001000
	brlo calc4_6
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_6:
	cpi temp1, 0b00000100
	brlo calc2_6
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_6:
	cpi temp1, 0b00000010
	brlo calc1_6
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_6:
	cpi temp1, 0b00000001
	brlo outputrow_6
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_7:
	cpi temp1, 0b01000000
	brlo calc32_7
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_7:
	cpi temp1, 0b00100000
	brlo calc16_7
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_7:
	cpi temp1, 0b00010000
	brlo calc8_7
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_7:
	cpi temp1, 0b00001000
	brlo calc4_7
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_7:
	cpi temp1, 0b00000100
	brlo calc2_7
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_7:
	cpi temp1, 0b00000010
	brlo calc1_7
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_7:
	cpi temp1, 0b00000001
	brlo outputrow_7
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	jmp main
	/*
joyinputX://Listen to joystick (X-axis)
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
	*/

	/*
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
	*/
resetMatrix:	;Troubleshooting, Reset matrix
	st Y, r1
    std Y+1, r1
    std Y+2, r1
    std Y+3, r1
    std Y+4, r1
    std Y+5, r1
    std Y+6, r1
    std Y+7, r1
	ret

delay1:			;Delay called after each output
    ldi  temp3, 13
    ldi  temp4, 252
L1: dec  temp4
    brne L1
    dec  temp3
    brne L1
	ret