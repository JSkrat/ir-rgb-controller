/*
 * timer.h
 *
 * Created: 12.12.2022 2:19:47
 *  Author: Mintytail
 */ 


#ifndef TIMER_H_
#define TIMER_H_

// in microseconds, given F_CPU is 8000000 and prescaler is 1/256
#define TIMER_TICK 32

inline void timer_init() {
	// the longest pulse from remote is 9ms
	// we need that pulse to fit inside a single timer period
	// so the minimal timer tick length is 9000us/256 = 35.15625us
	// but we can accept a single overflow
	// we'll accept all active start pulses longer than 8ms
	// then we could use f_clk_io/256 with longest trackable pulse length 8.192ms
	// CTC mode, count from 0 to OCR0A register
	//  In CTC mode the counter is cleared to zero when the counter value (TCNT0) matches the OCR0A.
	// The OCR0A defines the top value for the counter, hence also its resolution.
	TCCR0A = (1 << WGM01) | (0 << WGM00);
	TCCR0B = (0 << WGM02) | (1 << CS02) | (0 << CS01) | (0 << CS00);
	OCR0A = 250;
	TIMSK0 = (1 << OCIE0A) | (1 << OCIE0B);
};

#endif /* TIMER_H_ */