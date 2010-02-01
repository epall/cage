/*
* Entry point for Chronos Advanced Gesture Engine
*/

#include "project.h"
#include "acceleration.h"
#include "vti_as.h"
#include "buzzer.h"
#include "display.h"
#include "timer.h"

#define CAGE_MODE_INIT      0x00
#define CAGE_MODE_SLEEP     0x01
#define CAGE_MODE_COMMAND   0x02

#define FACING_DOWN (xyz[2] > 0xE0 && xyz[2] < 0xE8)

#define COMMAND_EXIT_COUNT 100

void cage_main(void){
  static u8 xyz[3];
  static u8 down_count = 0;
  static u8 mode = CAGE_MODE_INIT;
  static u8 heartbeat = 0;

  switch(mode){
    case CAGE_MODE_INIT:
    mode = CAGE_MODE_SLEEP;
    break;

    case CAGE_MODE_SLEEP:
    as_start();
    Timer0_A4_Delay(CONV_MS_TO_TICKS(20));
    as_get_data(xyz);

    if(FACING_DOWN){
      // facing down
      down_count += 1;
      if(down_count >= 2){
        down_count = 0;
        // go to command mode
        start_buzzer(3, CONV_MS_TO_TICKS(20), CONV_MS_TO_TICKS(150));
        mode = CAGE_MODE_COMMAND;
        return;
      }
    }
    else
      down_count = 0;
    // don't stop if we're going to command mode
    if(mode == CAGE_MODE_SLEEP) as_stop();
    break;

    case CAGE_MODE_COMMAND:
    as_get_data(xyz);
    
    if(xyz[2] > 0xCF && xyz[2] < 0xD4){
      ++down_count;
      if(down_count > COMMAND_EXIT_COUNT){
        down_count = 0;
        as_stop();
        display_symbol(LCD_ICON_RECORD, SEG_OFF);
        start_buzzer(3, CONV_MS_TO_TICKS(20), CONV_MS_TO_TICKS(150));
        mode = CAGE_MODE_SLEEP;
        return;
      }
    }
    else
      down_count = 0;
      
    if(heartbeat)
      display_symbol(LCD_ICON_RECORD, SEG_OFF);
    else
      display_symbol(LCD_ICON_RECORD, SEG_ON);
    heartbeat = !heartbeat;
    break;
  }
}
