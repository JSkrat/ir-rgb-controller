/*
 * commands.asm
 *
 *  Created: 27.12.2022 13:03:20
 *   Author: Mintytail
 */ 

 #ifndef _COMMANDS_
 #define _COMMANDS_

 .include "led.inc"
 .include "commands.inc"

 .dseg
 c_led_color: .byte 3
 c_led_brightness: .byte 1

 .cseg
 c_red: .db cbR0, cbR1, cbR2, cbR3, cbR4, 0
 c_green: .db cbG0, cbG1, cbG2, cbG3, cbG4, 0
 c_blue: .db cbB0, cbB1, cbB2, cbB3, cbB4, 0

 .macro commands_init
	// debug initialization
	ldi r16, 3
	ldi r17, 5
	sts c_led_color, r16
	sts c_led_color+1, r17
	sts c_led_color+2, r16
	// max brightness
	sts c_led_brightness, r17
	//rcall _c_update_led
 .endmacro

 _c_update_led:
	ldi r16, LEDS
	ldi r26, low(c_led_color)
	//ldi r27, high(c_led_color)
	ldi r28, low(led)
	_c_update_led_loop:
		ld r17, x+
		st y+, r17
		dec r16
	brne _c_update_led_loop
	ret

 c_command:
	// r17 contains index of command, 1-24
	// no registers to save
	#define _command_index r17
	cpi _command_index, cbOn
	breq _command_on
	cpi _command_index, cbOff
	breq _command_off
	#undef _command_index
	ret
	_command_on:
	// do nothing, that will update led colors
	_command_exec_exit:
	rcall _c_update_led
	ret

_command_off:
	sts led, r1
	sts led+1, r1
	sts led+2, r1
	ret
	
#endif
