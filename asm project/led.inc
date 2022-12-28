/*
 * led.inc
 *
 *  Created: 27.12.2022 17:41:53
 *   Author: Mintytail
 */ 

#define LED_PHASES 5
#define LEDS 3
#define LED_MAX 4

#ifndef _LED_INC_
#define _LED_INC_

.DSEG
led:		.BYTE LEDS

#endif
