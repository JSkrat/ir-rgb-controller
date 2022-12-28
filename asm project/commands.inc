/*
 * commands.inc
 *
 *  Created: 27.12.2022 17:59:26
 *   Author: Mintytail
 */ 

#define cbBrightnessUp 0x18
#define cbBrightnessDown 0x17
#define cbOff 0x16
#define cbOn 0x15
#define cbWhite 0x14
#define cbFlash 0x13
#define cbStrobe 0x12
#define cbFade 0x11
#define cbSmooth 0x10
#define cbR4 0x0F
#define cbR3 0x0E
#define cbR2 0x0D
#define cbR1 0x0C
#define cbR0 0x0B
#define cbG4 0x0A
#define cbG3 0x09
#define cbG2 0x08
#define cbG1 0x07
#define cbG0 0x06
#define cbB4 0x05
#define cbB3 0x04
#define cbB2 0x03
#define cbB1 0x02
#define cbB0 0x01

#define cbRGBBegin (cbR4+1)
#define cbRedBegin (cbR4+1)
#define cbRedNorm cbR0
#define cbGreenBegin (cbG4+1)
#define cbGreenNorm cbG0
#define cbBlueBegin (cbB4+1)
#define cbBlueNorm cbB0
