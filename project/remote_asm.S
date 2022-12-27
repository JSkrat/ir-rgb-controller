
/*
 * remote_asm.S
 *
 * Created: 21.12.2022 15:44:04
 *  Author: Mintytail
 */ 
 //#include "remote.h"

 .global remote_inc_overflow

 .extern timOvfCounter
 .extern widthOverflow

 remote_inc_overflow:
	lds r30, timOvfCounter
	lds r31, timOvfCounter+1
	; add argument
	add r30, r24
	adc r31, r1
   brcc rio_ret
	 ldi r18, 1
	 sts widthOverflow, r18
   rio_ret:
	sts timOvfCounter, r30
	sts timOvfCounter+1, r31
   ret