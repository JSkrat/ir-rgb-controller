# ir-rgb-controller
simple ir rgb led controller for attiny13

# project

Attempt to implement in C. Does not fit into a 1k flash, abandoned.

# asm project

Current firmware version. Implements On, Off buttons and separate RGB component set (5 levels). 
Buttons R, G, B on a second row are maximum brightness, yellow, cyan and violet buttons are off.

So, it is possible to setup more colors unlike default color palette.

Also, unlike default controller PWM frequency is much higher (5kHz for 10MHz RC oscillator setup)

This firmware leaves about half memory for additional features.

# pcb modifications

ATTiny13A has different pinout than default controller, so some traces has to be cut. See picture.

Capacitor may be not needed, theoretically.