/*
 * led.asm
 *
 *  Created: 21.12.2022 21:33:36
 *   Author: Mintytail
 */ 

#ifndef _LED_
#define _LED_
.include "led.inc"
.include "utils.inc"
#define PIN_RED PORTB1
#define PIN_GREEN PORTB0
#define PIN_BLUE PORTB2

.DSEG
led_phase:	.BYTE 1

.CSEG

led_pins: .db (1 << PIN_RED), (1 << PIN_GREEN), (1 << PIN_BLUE), 0

 .macro led_init
	cbi PORTB, PIN_RED
	cbi PORTB, PIN_GREEN
	cbi PORTB, PIN_BLUE
	sbi DDRB, PIN_RED
	sbi DDRB, PIN_GREEN
	sbi DDRB, PIN_BLUE
	// init led_phase
	ldi r16, LED_PHASES
	sts led_phase, r16
 .endmacro

 .macro led_tick
	#define _led_phase r16
	lds _led_phase, led_phase
	dec _led_phase
	brne led_phase_ok
	ldi _led_phase, LED_PHASES - 1
   led_phase_ok:
	sts led_phase, _led_phase
   calc_leds:
	#define _led_on r17
	#define _led_off r18
	clr _led_on
	ser _led_off
	// loop through all leds
	ldi r20, LEDS
	// for chips with less than 256 bytes of sram r29 is not a part of Y register in any way
	ldi r28, led
	ldi_z_for_lpm led_pins
	calc_leds_loop:
		#define _led_i_brightness r21
		#define _led_i_pin r22
		ld _led_i_brightness, Y+
		lpm _led_i_pin, Z+
		// if led brightness is lower than the phase, reset this led pin in _led_off
		// otherwise set this led pin in _led_on
		cp _led_i_brightness, _led_phase
		brlo cll_off
		cll_on:
			or _led_on, _led_i_pin
		rjmp cll_end
		cll_off:
			com _led_i_pin
			and _led_off, _led_i_pin
		cll_end:
		#undef _led_i_pin
		#undef _led_i_brightness
	dec r20
	brne calc_leds_loop
	// reset and set leds pins
	in r19, PORTB
	and r19, _led_off
	or r19, _led_on
	out PORTB, r19
	#undef _led_off
	#undef _led_on
	#undef _led_phase
 .endmacro
#endif
