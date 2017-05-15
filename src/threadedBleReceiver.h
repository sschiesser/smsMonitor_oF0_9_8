#pragma once
/* --------------------------------------------------------------
*     INCLUDES
* -------------------------------------------------------------- */
#include "ofMain.h"
#include "ofApp.h"
#include <stdio.h>
#include <string>
#include <fileapi.h>
#include <windows.h>
#include <setupapi.h>
#include <devguid.h>
#include <regstr.h>
#include <bthdef.h>
//#include <bthledef.h>
#include <Bluetoothleapis.h>
#pragma comment(lib, "SetupAPI")
#pragma comment(lib, "BluetoothApis.lib")
#pragma comment(lib, "Kernel32.lib")


/* --------------------------------------------------------------
*     MACROS
* -------------------------------------------------------------- */
#define TO_SEARCH_DEVICE_UUID		L"{00001C57-1212-efde-1523-785feabcd123}" //SABRE_SMS SMSS service UUID

#define SMSS_BUTTON_CHAR_SIZE		2
#define SMSS_PRESS_CHAR_SIZE		8
#define SMSS_IMU_CHAR_SIZE			16


/* --------------------------------------------------------------
*     CLASS DECLARATIONS
* -------------------------------------------------------------- */
class threadedBleReceiver : public ofThread
{
public:
	threadedBleReceiver();
	~threadedBleReceiver();

	void setup();
	void start();
	void stop();
	void threadedFunction();
	int parseInput();
	HANDLE GetBLEHandle(GUID AGuid);



	bool openDevice(GUID AGuid);
	bool closeDevice();


	union f2b {
		float val;
		uint8_t b[4];
	};

	typedef struct {
		uint8_t button[2];
		int32_t pressure;
		int32_t temperature;
		union f2b quaternions[4];
	}sensorValues_t;

	sensorValues_t sensVal;
	bool newVal;

	BLUETOOTH_GATT_EVENT_HANDLE bleEventHandle;

private:
	//static void getNotification(BTH_LE_GATT_EVENT_TYPE EventType, PVOID EventOutParameter, PVOID Context);
	static void getNotification(BTH_LE_GATT_EVENT_TYPE EventType, PVOID EventOutParameter, PVOID Context, threadedBleReceiver *val);

};
