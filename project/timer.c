/*
 * timer.c
 *
 * Created: 12.12.2022 2:19:38
 *  Author: Mintytail
 */ 

#include "led.h"
#include "remote.h"
#include <stdint.h>
#include <avr/interrupt.h>

ISR(TIM0_COMPA_vect) {
	remote_tim_ovf(OCR0A);
}

ISR(TIM0_COMPB_vect) {
	led_tick();
	if (250 == OCR0B) OCR0B = 50;
	else OCR0B += 50;
}
