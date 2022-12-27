/*
 * timer.asm
 *
 *  Created: 22.12.2022 0:12:38
 *   Author: Mintytail
 */ 

.include "led.asm"
.include "remote.asm"

#ifndef _TIMER_
#define _TIMER_

.macro timer_init
	// the longest pulse from remote is 9ms
	// we need that pulse to fit inside a single timer period
	// so the minimal timer tick length is 9000us/256 = 35.15625us
	// but we can accept a single overflow
	// we'll accept all active start pulses longer than 8ms
	// then we could use f_clk_io/256 with longest trackable pulse length 8.192ms
	// CTC mode, count from 0 to OCR0A register
	//  In CTC mode the counter is cleared to zero when the counter value (TCNT0) matches the OCR0A.
	// The OCR0A defines the top value for the counter, hence also its resolution.
	ldi r16, (1 << WGM01) | (0 << WGM00)
	out TCCR0A, r16
	ldi r16, (0 << WGM02) | (1 << CS02) | (0 << CS01) | (0 << CS00)
	out TCCR0B, r16
	ldi r16, 250
	out OCR0A, r16
	ldi r16, 50
	out OCR0B, r16
	ldi r16, (1 << OCIE0A) | (1 << OCIE0B)
	out TIMSK0, r16
.endmacro

timer_compa_vector:
	in r16, OCR0A
	remote_inc_overflow
reti

timer_compb_vector:
	led_tick
	// step ocr0b by 50 timer ticks every time
	in r16, OCR0B
	ldi r17, 50
	add r16, r17
	brcc _ocr0b_ok
		mov r16, r17
	_ocr0b_ok:
	out OCR0B, r16
reti

#endif
