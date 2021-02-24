.include "m8def.inc"

.equ BAUD = 9600
.equ fCK = 8000000 // ”казываем битрейт на котором будем работать
.equ UBRR_value = (fCK/(BAUD*8))-1
.equ TIMER1_INTERVAL = 0x01
.equ TIMER2_INTERVAL = 0xFF


.dseg

.cseg
	rjmp start
.org $008 
	rjmp TIM1_OVF
.org $009 
	rjmp TIM0_OVF


TIMER1_STR: .db "ping\r\n",0x0D,0
TIMER2_STR: .db "pong\r\n",0x0D,0



init_USART:
	ldi r16,high(UBRR_value)
	out UBRRH, r16
	ldi r16, low(UBRR_value)
	out UBRRL, r16

	ldi r16, 2
	out UCSRA, r16

	ldi r16, (1<<TXEN)
	out UCSRB, r16
	ldi r16, (1<<URSEL)|(1<<UCSZ0)|(1<<UCSZ1)
	out UCSRC, r16
	ret

USART_send:
	sbis UCSRA, UDRE
	rjmp USART_send
	out UDR, r16
	ret

get_flash_byte:
	lpm r16, Z+
	cpi r16, $00
	breq send_str_end
	rcall USART_send
	rjmp get_flash_byte

send_str_end:
	ret

	



start:
	ldi r16,low(RAMEND)
	out SPL, r16
	ldi r17, high(RAMEND)
	out SPH,r17


	

	rcall init_USART
	
 	ldi R17,0b00000101
 	out TCCR1B,R17

	ldi R17,TIMER1_INTERVAL
 	out TCNT1L,R17

 	out TCNT1H,R17
	 ldi R17,0b00000101
 	out TIMSK,R17

	ldi r17, 0b00000101
	out TCCR0,R17

	ldi r17, TIMER2_INTERVAL
	out TCNT0, r17

 	sei	

begin:
	rjmp begin


TIM1_OVF:
	ldi r30, low(TIMER2_STR)
	ldi r31, high(TIMER2_STR)
	add r30, r30
	adc r31, r31
	rcall get_flash_byte
	ret

TIM0_OVF:
	ldi r30, low(TIMER1_STR)
	ldi r31, high(TIMER1_STR)
	add r30, r30
	adc r31, r31
	rcall get_flash_byte
	ldi R17,0b00000100
 	out TIMSK,R17
	sei
	ret






