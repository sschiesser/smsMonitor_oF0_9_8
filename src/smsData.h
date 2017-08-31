#pragma once

/******************************************************************************
* RECEIVED data from the SMS Central is basically grouped like the BLE
* services and numbered with periph# (sabre/periph#/...)
* - button			->	1 int with two masked button values
*					->	1 timestamp (2^32 ms)
*					->	1 battery level
* - pressure		->	1 pressure value
*					->	1 temperature value
*					->	1 timestamp
*					->	1 battery level
* - mpu             ->	3 raw gyro values
*					->	3 raw accel values
*					->	3 raw compass values
*					->	1 temperature value
*					->	2 timestamps (TSgyro always, TScomp/temp/batt sometimes)
*					->	1 battery level
******************************************************************************/
// OSC argument positions of the different received values
#define BUTDATA_ARG_BUTTON_POS		0
#define BUTDATA_ARG_BATTERY_POS		1
#define PRESSDATA_ARG_TEMP_POS		0
#define PRESSDATA_ARG_PRESS_POS		1
#define PRESSDATA_ARG_BATTERY_POS	2
#define MPUDATA_ARGS_COMPLETE		11
#define MPUDATA_ARGS_PARTIAL		6
#define MPUDATA_ARG_GYROX_POS		0
#define MPUDATA_ARG_GYROY_POS		1
#define MPUDATA_ARG_GYROZ_POS		2
#define MPUDATA_ARG_ACCELX_POS		3
#define MPUDATA_ARG_ACCELY_POS		4
#define MPUDATA_ARG_ACCELZ_POS		5
#define MPUDATA_ARG_COMPX_POS		6
#define MPUDATA_ARG_COMPY_POS		7
#define MPUDATA_ARG_COMPZ_POS		8
#define MPUDATA_ARG_TEMP_POS		9
#define MPUDATA_ARG_BATTERY_POS		10
// Positions of the different values within the bleMpuData struct
#define MPUDATA_MPUX_POS			0
#define MPUDATA_MPUY_POS			1
#define MPUDATA_MPUZ_POS			2
#define MPUDATA_TS_GYRO_POS			0
#define MPUDATA_TS_COMP_POS			1

struct bleButtonData
{
	uint8_t button; // button value (OFF --> 0x00, ON --> 0xFF)
	long curTs; // timestamp at the packet reception (assigned by smsMonitor)
    long oldTs; // timestamp of the last reception
	int battery; // battery level
	bool newData;
};
struct blePressureData
{
	int pressure; // 32 bit pressure value (mbar x 100)
	int temperature; // 32 bit temperature value (¡C x 100)
	long curTs; // timestamp at the packet reception (assigned by smsMonitor)
    long oldTs; // timestamp of the last reception
	int battery; // battery level
	bool newData;
};
struct bleMpuData
{
	int gyro[3]; //
	int accel[3]; //
	int compass[3]; //
	int temperature; //
	long curTs[2]; // timestamp at the packet reception (assigned by smsMonitor)
    long oldTs[2]; // timestamp of the last reception
	int battery; // battery level
	bool newData;
	bool newExtData; // extended data (compass, temperature, battery)
};

/******************************************************************************
 * FORWARDED data to any user application have been re-parsed to a more
 * usable address space, calibrated and scaled
 * - button			->	2 bool
 * - pressure		->	1 float scaled from -1. to +1.
 * - mpu/gyro		->	4 float (x/y/z/sum) scaled from -1. to +1.
 * - mpu/accel		->	4 float (x/y/z/sum) scaled from -1. to +1.
 * - mpu/compass	->	4 float (x/y/z/sum) scaled from -1. to +1.
 * - temperature	->	2 float (Tpress/Tmpu, °C absolute)
 * - battery		->	1 float scaled from -1. to +1.
 * - timestamp		->	3 int32 (TSbut/TSpress/TSgyro/TScomp)
 * ----------------------------------------------------------------------------
 * CALCULATED data are also sent to the user application:
 * - delta			->	3 int32 (Dpress/Dgyro/Dcomp)
 * - wordClock		->	1 int32 (Clock, starting a monitor start)
 * - joystick		->	2 float (heading/pitch) scaled to -180. - +180.
 * - ahrs			->	3 float (roll/pitch/yaw) scaled to -180. - +180.
 ******************************************************************************/
#define SMSDATA_BUTTON_B0_POS           0
#define SMSDATA_BUTTON_B1_POS           1
#define SMSDATA_MPU_X_POS               0
#define SMSDATA_MPU_Y_POS               1
#define SMSDATA_MPU_Z_POS               2
#define SMSDATA_MPU_SUM_POS             3
#define SMSDATA_TEMP_PRESS_POS          0
#define SMSDATA_TEMP_MPU_POS            1
#define SMSDATA_TS_BUT_POS              0
#define SMSDATA_TS_PRESS_POS            1
#define SMSDATA_TS_GYRO_POS             2
#define SMSDATA_TS_COMP_POS				3
#define SMSDATA_DELTA_PRESS_POS         0
#define SMSDATA_DELTA_GYRO_POS          1
#define SMSDATA_DELTA_COMP_POS          2
#define SMSDATA_JOY_HEAD_POS            0
#define SMSDATA_JOY_PICTH_POS           1
#define SMSDATA_AHRS_ROLL_POS           0
#define SMSDATA_AHRS_PITCH_POS          1
#define SMSDATA_AHRS_YAW_POS            2
#define SMSDATA_AHRS_Q1_POS             0
#define SMSDATA_AHRS_Q2_POS             1
#define SMSDATA_AHRS_Q3_POS             2
#define SMSDATA_AHRS_Q4_POS             3

#define SMSDATA_PRESS_CALIB_START           10
#define SMSDATA_PRESS_CALIB_SAMPLES        100
#define SMSDATA_PRESS_CALIB_STOP            (SMSDATA_PRESS_CALIB_START + SMSDATA_PRESS_CALIB_SAMPLES)

struct smsData
{
	// Forwarded values
	bool button[2];
	float pressure;
	float gyro[4];
	float accel[4];
	float compass[4];
	float temperature[2];
	float battery;
	int timestamp[4];
	
	// Calculated values
	long delta[3];
	long wordClock;
	double joystick[2];
	double ahrs[3];
    double quat[4];
    double euler[3];
};
