		//ldi		r16,HIGH(RAMEND)									//Förbereder pekare
		//out		SPH,r16
		//ldi		r16,LOW(RAMEND)
		//out		SPL,r16
		//call	TIMER1_INIT
		call	DELAY_HALFHALF
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		.cseg

		.equ	SECOND_TICKS = 62500 - 1					//Ger en sekunds avbrott när TIMER1_INIT är inläst - @ 16/256 MHz
		.org	OC1Aaddr
		jmp		AVBROTT
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
MAIN:	
		call	BEEP
		jmp		MAIN
		
BEEP:			
		sbi		DDRB,1
		sbi		PORTB,PB1
		call	DELAY_SECOND
		//cbi		DDRB,0
		cbi		PORTB,PB1
		call	DELAY_SECOND
		ret
NOBEEP:
		cbi		DDRB,0
		cbi		PORTB,PB1
		call	DELAY_SECOND

AVBROTT:
		push	r16													//Sparar en kopia
		in		r16,SREG											//Lägger in SREG
		call	TIME_TICK											//Kallar avbrottet(rutinen)
		out		SREG,r16											//Lagrar tillbaka SREG
		pop		r16													//Skickar till register r16
		reti

TIME_TICK:															//Rutin för uppräckning av tid
		push	XL													//Sparar SREG i STACK
		push	XH													//Sparar SREG i STACK
		push	r16													//Sparar SREG i STACK
		call	BEEP

KLAR:
		st		X,r16												//Ladda värdet i r16 till X-pekare
		pop		r16													//Pop register from STACK
		pop		XH													//Pop register from STACK
		pop		XL													//Pop register from STACK
		ret

TIMER1_INIT:
		ldi		r16,(1<<WGM12)|(1<<CS12)							//CTC , prescale 256
		sts		TCCR1B,r16
		ldi		r16,HIGH(SECOND_TICKS)
		sts		OCR1AH,r16
		ldi		r16,LOW(SECOND_TICKS)
		sts		OCR1AL,r16
		ldi		r16,(1<<OCIE1A)										//allow to interrupt
		sts		TIMSK1,r16
		ret

WAIT:
	sbiw	r24,4
	ret
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Delay 1 second
DELAY_SECOND:                 ; For CLK(CPU) = 1 MHz
    ldi     r16,62     ; One clock cycle;
DELAY1_ONE:
    ldi     r17,255     ; One clock cycle
DELAY2_ONE:
    ldi     r18,252     ; One clock cycle
DELAY3_ONE:
    dec     r18            ; One clock cycle
    nop                     ; One clock cycle
    brne    Delay3_ONE          ; Two clock cycles when jumping to Delay3, 1 clock when continuing to DEC

    dec     r17            ; One clock cycle
    brne    Delay2_ONE          ; Two clock cycles when jumping to Delay2, 1 clock when continuing to DEC

    dec     r16            ; One clock Cycle
    brne    Delay1_ONE          ; Two clock cycles when jumping to Delay1, 1 clock when continuing to RET
	ret
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Delay 0.5 second
DELAY_HALFSECOND:                 ; For CLK(CPU) = 1 MHz
    ldi     r16,31     ; One clock cycle;
DELAY1_TWO:
    ldi     r17,250     ; One clock cycle
DELAY2_TWO:
    ldi     r18,255     ; One clock cycle
DELAY3_TWO:
    dec     r18            ; One clock cycle
    nop                     ; One clock cycle
    brne    Delay3_TWO         ; Two clock cycles when jumping to Delay3, 1 clock when continuing to DEC

    dec     r17            ; One clock cycle
    brne    Delay2_TWO          ; Two clock cycles when jumping to Delay2, 1 clock when continuing to DEC

    dec     r16            ; One clock Cycle
    brne    Delay1_TWO          ; Two clock cycles when jumping to Delay1, 1 clock when continuing to RET
	ret
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Delay 0.25 second
DELAY_HALFHALF:                 ; For CLK(CPU) = 1 MHz
    ldi     r16,16     ; One clock cycle;
DELAY1_THREE:
    ldi     r17,245    ; One clock cycle
DELAY2_THREE:
    ldi     r18,255     ; One clock cycle
DELAY3_THREE:
    dec     r18            ; One clock cycle
    nop                     ; One clock cycle
    brne    Delay3_THREE          ; Two clock cycles when jumping to Delay3, 1 clock when continuing to DEC

    dec     r17            ; One clock cycle
    brne    Delay2_THREE          ; Two clock cycles when jumping to Delay2, 1 clock when continuing to DEC

    dec     r16            ; One clock Cycle
    brne    Delay1_THREE          ; Two clock cycles when jumping to Delay1, 1 clock when continuing to RET
	ret
		//328 timer1

		//ICr1

		//OCR1A