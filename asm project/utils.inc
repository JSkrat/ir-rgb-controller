/*
 * utils.inc
 *
 *  Created: 28.12.2022 14:47:09
 *   Author: Mintytail
 */ 

#ifndef _UTILS_
#define _UTILS_

.macro ldi_z_for_lpm ; address
	ldi r30, low(@0 << 1)
	ldi r31, high(@0 << 1)
.endmacro

#endif
