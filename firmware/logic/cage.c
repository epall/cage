/*
* Entry point for Chronos Advanced Gesture Engine
*/

#include "project.h"
#include "acceleration.h"
#include "vti_as.h"
#include "buzzer.h"
#include "display.h"
#include "timer.h"

// from acceleration.c
extern u16 convert_acceleration_value_to_mgrav(u8 value);

void cage_main(void){
  static u8 xyz[3];

  as_start();
  Timer0_A4_Delay(CONV_MS_TO_TICKS(20));
  as_get_data(xyz);
  as_stop();
  
  if(xyz[2] > 0xE0 && xyz[2] < 0xE8)
    display_symbol(LCD_ICON_RECORD, SEG_ON);
  else
    display_symbol(LCD_ICON_RECORD, SEG_OFF);
}