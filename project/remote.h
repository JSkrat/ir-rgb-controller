/*
 * remote.h
 *
 * Created: 12.12.2022 0:42:41
 *  Author: Mintytail
 */ 


#ifndef REMOTE_H_
#define REMOTE_H_

#include <avr/io.h>
#include <stdbool.h>

#define PIN_IR PORTB4
#define PCINT_IR PCINT4

int16_t timOvfCounter;
bool widthOverflow;

void remote_inc_overflow(uint8_t period);

inline void remote_init() {
	// make IR pin input
	DDRB &= ~(1 << PIN_IR);
	// enable PCIE interrupt on IR pin
	PCMSK |= (1 << PCINT_IR);
	// enable PCIE
	GIMSK = (1 << PCIE);
};

inline void remote_tim_ovf(uint8_t period) {
	//if (__builtin_add_overflow(timOvfCounter, (uint16_t) period, &timOvfCounter)) widthOverflow = true;
	remote_inc_overflow(period);
};

#endif /* REMOTE_H_ */