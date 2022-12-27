/*
 * remote.c
 *
 * Created: 12.12.2022 0:42:31
 *  Author: Mintytail
 */ 
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include "remote.h"
#include "timer.h"
#include "control.h"


#define address 0x00F7
#define CODES_SIZE 24
const static PROGMEM uint16_t codes[CODES_SIZE] = {
	0x00FF, 0x807F, 0x40BF, 0xC03F,
	0x20DF, 0xA05F, 0x609F, 0xE01F,
	0x10EF, 0x906F, 0x50AF, 0xD02F,
	0x30CF, 0xB04F, 0x708F, 0xF00F,
	0x08F7, 0x8877, 0x48B7, 0xC837,
	0x28D7, 0xA857, 0x6897, 0xE817
};
#define BUFFER_SIZE 32
typedef union {
	uint8_t bytes[4];
	uint32_t dword;
	uint16_t words[2];
} uBuffer;
static uBuffer buffer;
static int8_t bufferIndex = 0;
// in timer ticks
#define IR_MARGIN 5
#define START1 ((int16_t) 9000/TIMER_TICK)
#define START2 ((int16_t) 4500/TIMER_TICK)
#define BIT_START ((int16_t) 562.5/TIMER_TICK)
#define BIT_0 ((int16_t) 562.5/TIMER_TICK)
#define BIT_1 ((int16_t) 1687.5/TIMER_TICK)

uint8_t timStart = 0;
int16_t pulseWidth = 0;
int16_t timOvfCounter = 0;
bool widthOverflow = true;


typedef enum {
	ersStart1,
	ersStart2,
	ersBeginBit,
	ersEndBit,
} eReceiveState;
eReceiveState parserState = ersStart1;

void parseCommand() {
	// first check the address
	// bytes 2-3 are the device address (msb)
	if (address != buffer.words[1]) return;
	for (int8_t i = 0; i < CODES_SIZE; ++i) {
		uint16_t code = pgm_read_word(&(codes[i]));
		if (code == buffer.words[0]) {
			command(i);
			return;
		}
	}
}

ISR(PCINT0_vect) {
	pulseWidth = timOvfCounter + (int16_t) TCNT0 - (int16_t) timStart;
	timOvfCounter = 0;
	timStart = TCNT0;
	if (! widthOverflow) {
		bool ir = 0 != (PINB & (1 << PIN_IR));
		bool resetFSM = true;
		switch (parserState) {
			case ersStart1: {
				// catch rising front
				if (! ir) break;
				if (abs(START1 - pulseWidth) > IR_MARGIN) break;
				parserState = ersStart2;
				resetFSM = false;
				buffer.dword = 0;
				bufferIndex = 0;
				break;
			}
			case ersStart2: {
				// make sure it is falling front
				//if (ir) break;
				if (abs(START2  - pulseWidth) > IR_MARGIN) break;
				parserState = ersBeginBit;
				resetFSM = false;
				break;
			}
			case ersBeginBit: {
				// make sure it is rising front
				//if (! ir) break;
				if (abs(BIT_START - pulseWidth) > IR_MARGIN) break;
				if (BUFFER_SIZE == bufferIndex) {
					// end of transaction
					parseCommand();
					break;
				}
				parserState = ersEndBit;
				resetFSM = false;
				break;
			}
			case ersEndBit: {
				// transmission ends with a single low tick, so we will have that falling front anyway
				// make sure it is falling front
				//if (ir) break;
				if (abs(BIT_1 - pulseWidth) <= IR_MARGIN) {
					buffer.dword |= (1 << bufferIndex);
					resetFSM = false;
				} else if (abs(BIT_0 - pulseWidth) <= IR_MARGIN) {
					resetFSM = false;
				} else break;
				++bufferIndex;
				parserState = ersBeginBit;
				break;
			}
		}
		if (resetFSM) parserState = ersStart1;
	}
	widthOverflow = false;
}
