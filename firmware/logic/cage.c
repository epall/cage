/*
* Entry point for Chronos Advanced Gesture Engine
*/

#include "project.h"
#include "acceleration.h"
#include "vti_as.h"
#include "buzzer.h"
#include "display.h"

// from acceleration.c
extern u16 convert_acceleration_value_to_mgrav(u8 value);

void cage_main(void){
  u8 xyz[3];
  u16 accel_data;
  static u8 is_heart = 0;
  
  // heartbeat to prove we're here
  if(is_heart)
    display_symbol(LCD_ICON_HEART, SEG_OFF);
  else
    display_symbol(LCD_ICON_HEART, SEG_ON);
  
  is_heart = !is_heart;

/*  
  as_start();
  as_get_data(xyz);
  accel_data = (u16)((accel_data * 0.2) + (sAccel.data * 0.8));
  */
}