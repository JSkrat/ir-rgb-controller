/*
 * led.h
 *
 * Created: 12.12.2022 1:30:15
 *  Author: Mintytail
 */ 


#ifndef LED_H_
#define LED_H_

#include <avr/io.h>

#define PIN_RED PORTB1
#define PIN_GREEN PORTB0
#define PIN_BLUE PORTB2

#define LED_PHASES 5
#define LEDS 3
extern uint8_t led[LEDS];
uint8_t led_phase;
const uint8_t led_pins[LEDS];

inline void led_init() {
	// turn led pins off by default
	PORTB &= ~((1 << PIN_RED) | (1 << PIN_GREEN) | (1 << PIN_BLUE));
	// make led pins output
	DDRB |= (1 << PIN_RED) | (1 << PIN_GREEN) | (1 << PIN_BLUE);
};

void led_tick();
#endif /* LED_H_ */