/*
 * timer.inc
 *
 *  Created: 22.12.2022 1:42:45
 *   Author: Mintytail
 */ 

// in microseconds, given F_CPU is 8000000 and prescaler is 1/256
// todo: consider using prescaler 1/8 or 1/64
#define F_CPU 10000000
#define TIMER_TICK (256*1000000/F_CPU)
//#define TIMER_TICK 32
