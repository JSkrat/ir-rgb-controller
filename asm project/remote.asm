/*
 * remote.asm
 *
 *  Created: 22.12.2022 1:10:16
 *   Author: Mintytail
 */ 

#ifndef _REMOTE_
#define _REMOTE_

.include "utils.inc"
.include "timer.inc"
.include "commands.asm"

#define PIN_IR PORTB4
#define PCINT_IR PCINT4
;#define DEBUG PORTB3
// ir remote address (first 2 bytes)
#define ir_address 0x00F7
// ir remote protocol, all units are timer ticks
#define IR_MARGIN (int(562.5/TIMER_TICK)-1)
#define START1 int(9000/TIMER_TICK)
#define START2 int(4500/TIMER_TICK)
#define BIT_START int(562.5/TIMER_TICK)
#define BIT_0 int(562.5/TIMER_TICK)
#define BIT_1 int(1687.5/TIMER_TICK)
// ir parser fsm states
#define ersStart1 0
#define ersStart2 1
#define ersBeginBit 2
#define ersEndBit 3
// indices of pulse lengths in r_lengths
#define iStart1 0
#define iStart2 1
#define iBitStart 2
#define iBit0 3
#define iBit1 4
#define rBufferBits 32

.macro _debug_nops ; number of nops
	.if @0 == 1
		nop
	.elif @0 > 1
		nop
		_debug_nops int(@0)-1
	.endif
.endmacro

.macro debug_blink ; number of nops
	#ifdef DEBUG
		sbi PORTB, DEBUG
		_debug_nops @0
		cbi PORTB, DEBUG
	#endif
.endmacro

.dseg
r_buffer: .byte 4
r_buffer_index: .byte 1
r_timer_start: .byte 1
r_timer_ovf_counter: .byte 2
r_width_overflow: .byte 1
r_parser_state: .byte 1

.cseg
#define CODES_SIZE 24
codes: .dw 	0x00FF, 0x807F, 0x40BF, 0xC03F, \
			0xE01F, 0xD02F, 0xF00F, 0xC837, 0xE817, \
			0x20DF, 0x10EF, 0x30CF, 0x08F7, 0x28D7, \
			0xA05F, 0x906F, 0xB04F, 0x8877, 0xA857, \
			0x609F, 0x50AF, 0x708F, 0x48B7, 0x6897
r_lengths: .dw START1, START2, BIT_START, BIT_0, BIT_1

.macro remote_init
	// make IR pin input
	cbi DDRB, PIN_IR
	// enable PCIE interrupt on IR pin
	sbi PCMSK, PCINT_IR
	// enable PCIE (we know that no one use GIMSK except us, so simplify initialization a bit)
	ldi r16, (1 << PCIE)
	out GIMSK, r16
	#ifdef DEBUG
	// debug to output
	sbi DDRB, DEBUG
	debug_blink 1
	#endif
.endmacro

.macro remote_inc_overflow
	// add provided period to overflow counter. if overflow overflew, raise flag
	#define _period r16
	lds r30, r_timer_ovf_counter
	lds r31, r_timer_ovf_counter+1
	; add argument
	add r30, _period
	adc r31, r1
   brcc rio_ret
	 ldi r18, 1
	 sts r_width_overflow, r18
   rio_ret:
	sts r_timer_ovf_counter, r30
	sts r_timer_ovf_counter+1, r31
	#undef _period
.endmacro

check_pulse_width_within:
	// r16 is index to value in r_lengths to compare against
	// r24:r25 is pulse length to compare
	// output 0 to r17 if check pass, 1 otherwise
	// destroys r26-r31
	#define _pl_index r16
	// load specified etalon pulse length to r26:r27
	ldi_z_for_lpm r_lengths
	// index times 2, item is word
	add r30, r16
	adc r31, r1
	add r30, r16
	adc r31, r1
	lpm r26, Z+
	lpm r27, Z
	// subtract provided pulse length from that and make value absolute
	sub r26, r24
	sbc r27, r25
	brpl _r_difference_is_positive
		// couldn't find better solution to change sign for a word
		com r27
		com r26
		adiw r26, 1
	_r_difference_is_positive:
	// now check if difference is bigger than ir margin or not
	ldi r17, 0
	ldi r28, low(IR_MARGIN)
	ldi r29, high(IR_MARGIN)
	cp r28, r26
	cpc r29, r27
	brcc _cpww_ret
		ldi r17, 1
	_cpww_ret:
	#undef _pl_index
ret

// pcint interrupt
_r_buffer_filled:
	// first check the remote address
	debug_blink 8
	lds r16, r_buffer+3
	cpi r16, high(ir_address)
	brne _r_buffer_filled_exit
	debug_blink 0
	lds r16, r_buffer+2
	cpi r16, low(ir_address)
	brne _r_buffer_filled_exit
	debug_blink 0
	ldi r17, CODES_SIZE
	lds r18, r_buffer
	lds r19, r_buffer+1
	ldi_z_for_lpm codes
	_r_find_command_loop:
		debug_blink 0
		lpm r20, z+
		lpm r21, z+
		cp r20, r18
		brne _r_find_command_loop_end
		cp r21, r19
		brne _r_find_command_loop_end
			// command have found!
			debug_blink 2
			rcall c_command
			rjmp _r_buffer_filled_exit
		_r_find_command_loop_end:
		dec r17
	brne _r_find_command_loop
	_r_buffer_filled_exit:
	rjmp _r_reset_fsm_and_exit
_r_buffer_filled_trampoline:
	rjmp _r_buffer_filled
////////////////////////////
// entry point /////////////
////////////////////////////
remote_pcint0_vector:
	#define _pulse_width_lo r24
	#define _pulse_width_hi r25
	#define _current_tcnt0 r16
	in _current_tcnt0, TCNT0
	// first calculate this pulse width (since last pin change interrupt)
	lds _pulse_width_lo, r_timer_ovf_counter
	lds _pulse_width_hi, r_timer_ovf_counter+1
	add _pulse_width_lo, r16
	adc _pulse_width_hi, r1
	// previous tcnt0
	lds r17, r_timer_start
	sub _pulse_width_lo, r17
	sbc _pulse_width_hi, r1
	// re-initialize variables to calculate next pulse width
	sts r_timer_ovf_counter, r1
	sts r_timer_ovf_counter+1, r1
	sts r_timer_start, _current_tcnt0
	#undef _current_tcnt0
	// check width overflow and reset fsm if it is
	lds r16, r_width_overflow
	or r16, r16
	breq _no_width_overflow
		// reset parser and width overflow and exit
		// we know that ersStart1 is 0 so we use r1
		_r_reset_fsm_and_exit:
		sts r_parser_state, r1
		sts r_width_overflow, r1
		reti
_r_buffer_filled_trampoline2:
	rjmp _r_buffer_filled_trampoline
	_no_width_overflow:
	// FSM swich case
	#define _parser_state r16
	lds _parser_state, r_parser_state
	rcall check_pulse_width_within
	// output for a check pulse witdth within function
	#define _pulse_length_correct r17
	cpi _parser_state, ersEndBit
	brne _r_check_start1
		// determine received bit here
		// by default check was performed against bit 0 for bit end state
		sbrc _pulse_length_correct, 0
		rjmp _r_check_for_bit_1
			// it is bit 0
			debug_blink 0
			clc
			rjmp _r_bit_received
		_r_check_for_bit_1:
			ldi r16, iBit1
			rcall check_pulse_width_within
			sbrc _pulse_length_correct, 0
			rjmp _r_reset_fsm_and_exit
			debug_blink 4
			// it is bit 1
			sec
		_r_bit_received:
			// ld/st does not affect flags
			// for less than 256 bytes sram chips index registers are 1 byte, r27 is not part of X
			ldi r26, low(r_buffer)
			//ldi r27, high(r_buffer)
			ld r18, x+
			ld r19, x+
			ld r20, x+
			ld r21, x+
			// rotate through carry flag
			rol r18
			rol r19
			rol r20
			rol r21
			st -x, r21
			st -x, r20
			st -x, r19
			st -x, r18
			lds r18, r_buffer_index
			dec r18
			sts r_buffer_index, r18
			breq _r_buffer_filled_trampoline2
			ldi _parser_state, ersBeginBit
		rjmp _r_end_switch_case
	_r_check_start1:
	// all other states are performing check against current state number
	sbrc _pulse_length_correct, 0
	rjmp _r_reset_fsm_and_exit
	#undef _pulse_length_correct
	cpi _parser_state, ersStart1
	brne _r_check_start2
		// start1
		// first bit should be zero, but it is interrupt after change, so pin is 1 now
		sbis PINB, PIN_IR
		rjmp _r_reset_fsm_and_exit
		ldi _parser_state, ersStart2
		// reset buffer index
		ldi r18, rBufferBits
		sts r_buffer_index, r18
		// in fact we do not need to clear the buffer, it will be overwritten anyway
		rjmp _r_end_switch_case
	_r_check_start2:
	cpi _parser_state, ersStart2
	brne _r_check_bit_start
		// start2
		ldi _parser_state, ersBeginBit
		rjmp _r_end_switch_case
	_r_check_bit_start:
	cpi _parser_state, ersBeginBit
	brne _r_reset_state
		// begin bit
		ldi _parser_state, ersEndBit
		rjmp _r_end_switch_case
	_r_reset_state:
		ldi _parser_state, ersStart1
	_r_end_switch_case:
		sts r_parser_state, _parser_state
	#undef _parser_state
reti

#endif
