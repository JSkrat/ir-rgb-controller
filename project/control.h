/*
 * control.h
 *
 * Created: 17.12.2022 23:55:49
 *  Author: Mintytail
 */ 


#ifndef CONTROL_H_
#define CONTROL_H_


typedef enum {
	ecBrightnessUp = 0,	ecBrightnessDown = 1,	ecOff = 2,		ecOn = 3,
	ecFF0000 = 4,		ec00FF00 = 5,			ec0000FF = 6,	ecFFFFFF = 7,
	ecFF4000 = 8,		ec00FF40 = 9,			ec4000FF = 10,	ecFlash = 11,
	ecFF8000 = 12,		ec00FF80 = 13,			ec8000FF = 14,	ecStrobe = 15,
	ecFFC000 = 16,		ec00FFC0 = 17,			ecC000FF = 18,	ecFade = 19,
	ecFFFF00 = 20,		ec00FFFF = 21,			ecFF00FF = 22,	ecSmooth = 23
} eCommands;

typedef enum {
	ecRed0 = ecFF0000,		ecRed1 = ecFF4000,		ecRed2 = ecFF8000,		ecRed3 = ecFFC000,		ecRed4 = ecFFFF00,
	ecGreen0 = ec00FF00,	ecGreen1 = ec00FF40,	ecGreen2 = ec00FF80,	ecGreen3 = ec00FFC0,	ecGreen4 = ec00FFFF,
	ecBlue0 = ec0000FF,		ecBlue1 = ec4000FF,		ecBlue2 = ec8000FF,		ecBlue3 = ecC000FF,		ecBlue4 = ecFF00FF
} eColors;

void command(eCommands command);


#endif /* CONTROL_H_ */