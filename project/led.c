/*
 * led.c
 *
 * Created: 12.12.2022 1:30:24
 *  Author: Mintytail
 */ 
#include <avr/io.h>
#include "led.h"

uint8_t led_phase = 0;
uint8_t led[LEDS] = {0, 0, 0};
const uint8_t led_pins[LEDS] = {PIN_RED, PIN_GREEN, PIN_BLUE};
	
void led_tick() {
	if (LED_PHASES <= ++led_phase) led_phase = 1;
	uint8_t led_on = 0;
	uint8_t led_off = 0xFF;
	for (int8_t i = 0; i < LEDS; ++i) {
		if (led_phase > led[i]) led_off &= ~(1 << led_pins[i]);
		else led_on |= (1 << led_pins[i]);
	}
	PORTB = (PORTB & led_off) | led_on;
};
