/*
 * project.c
 *
 * Created: 12.12.2022 0:40:18
 * Author : Mintytail
 */ 

#include <avr/io.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>
#include "timer.h"
#include "led.h"
#include "remote.h"

int main(void)
{
	// disable analog comparator
	ACSR |= (1 << ACD);
	timer_init();
	led_init();
	remote_init();
	sei();
	set_sleep_mode(SLEEP_MODE_IDLE);
    while (1) {
		sleep_mode();
    }
}

