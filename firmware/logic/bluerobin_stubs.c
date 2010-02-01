#include "project.h"

void BlueRobin_RadioISR_v(void){
  return;
}

void BRRX_TimerTask_v(void){
  return;
}

unsigned char is_bluerobin(void){
  return 0;
}

unsigned char is_bluerobin_searching(void){
  return 0;
}

void test_mode(void){
  return;
}

void reset_bluerobin(void){
  return;
}

void get_bluerobin_data(void){
  return;
}

typedef enum
{
  BLUEROBIN_OFF = 0,        // Not connected
  BLUEROBIN_SEARCHING,      // Searching for transmitter
  BLUEROBIN_CONNECTED,		// Connected
  BLUEROBIN_ERROR			// Error occurred while trying to connect or while connected
} BlueRobin_state_t;

typedef enum
{
  BLUEROBIN_NO_UPDATE = 0,   // No new data available
  BLUEROBIN_NEW_DATA       	// New data arrived
} BlueRobin_update_t;

struct br
{
	// BLUEROBIN_OFF, BLUEROBIN_SEARCHING, BLUEROBIN_CONNECTED, BLUEROBIN_ERROR
	BlueRobin_state_t 	state;
	
	// BLUEROBIN_NO_UPDATE, BLUEROBIN_NEW_DATA
	BlueRobin_update_t	update;
	
	// Chest strap ID	
	u32	cs_id;

	// User settings
	u8 		user_sex;
	u16		user_weight;
	
	// Heart rate (1 bpm)
	u8 		heartrate;
	
	// Calories (1 kCal) - calculated from heart rate, user weight and user sex
	u32 	calories;
	
	// Speed (0.1 km/h) - demo version range is 0.0 to 25.5km/h 
	u8 		speed;
	
	// Distance (1 m)
	u32 	distance;
	
	// 0=display calories, 1=display distance
	u8		caldist_view;
};

struct br sBlueRobin;
