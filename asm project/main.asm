;
; asm project.asm
;
; Created: 21.12.2022 16:49:36
; Author : Mintytail
;
;.listmac

.cseg ; Code segment to assemble to
.org 0 ; Make sure that this starts at address zero
  rjmp start ; Reset
  reti ; INT0
  rjmp remote_pcint0_vector ; PCINT0
  reti ; TC0 overflow
  reti ; EEREADY
  reti ; Analaog comparer
  rjmp timer_compa_vector ; TC0 compare A
  rjmp timer_compb_vector ; TC0 compare B
  reti ; Watchdog timer
  reti ; AD converter
; End of Reset- and Interrupt locations

// atmel studio sometimes fails build for no apparent reason if that is not present here
// (but rebuild helps)
.include "timer.inc"
.include "led.asm"
.include "timer.asm"
.include "remote.asm"
.include "commands.asm"

; Replace with your application code
start:
	// universal register with value 0 in it
	clr r1
	// clear RAM with 0
	// attiny13a internal sram is 0x60 --- 0x9F
	ldi r26, 0x60
	ldi r27, 0x00
	// erase up to the stack top
	in r16, SPL
	memory_erase_loop:
		st x+, r1
		cp r26, r16
	brne memory_erase_loop
	// various inits
	led_init
	timer_init
	remote_init
	commands_init
	// sleep setup
	// idle mode, where io clock and timer are running
	// r2 is reserved specifically for main sleep loop
	in r16, MCUCR
	ori r16, (1 << SE)
	mov r2, r16
	// enable interrupts. No high registers are safe from now on
	sei
	sleep_loop:
		out MCUCR, r2
		sleep
	rjmp sleep_loop
