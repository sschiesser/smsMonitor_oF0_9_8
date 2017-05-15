#pragma once
/* --------------------------------------------------------------
*     INCLUDES
* -------------------------------------------------------------- */
#include "ofMain.h"
#include "ofApp.h"
#include "ofxOsc.h"
#include "smsData.h"


/* --------------------------------------------------------------
*     MACROS
* -------------------------------------------------------------- */
#define OSC_FRAMELENGTH				105
//#define OSC_NUMSENDERS				OSC_SENDER_MAX
#define OSC_ADDSTR_ROOT				"sabre/"
#define OSC_ADDSTR_CREATE			"create"
#define OSC_ADDSTR_DELETE			"delete"
#define OSC_ADDSTR_BUTTON			"button"
#define OSC_ADDSTR_PRESSURE			"pressure"
#define OSC_ADDSTR_MPU				"mpu"


/* --------------------------------------------------------------
*     CLASS DECLARATIONS
* -------------------------------------------------------------- */
class threadedOscReceiver : public ofThread
{
public:
	threadedOscReceiver();
	~threadedOscReceiver();

	void setup(int portNr);
	void start();
	void stop();
	void threadedFunction();
	int parseInput();

	ofxOscReceiver oscReceiver;
	struct bleButtonData rcvButton[8];
	struct blePressureData rcvPressure[8];
	struct bleMpuData rcvMpu[8];

	int haveInput;

//	struct smsData sendData[8];
};