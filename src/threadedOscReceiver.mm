/* --------------------------------------------------------------
*     INCLUDES
* -------------------------------------------------------------- */
#include "ofApp.hpp"
#include "threadedOscReceiver.h"
#include "threadedOscSender.h"

/* --------------------------------------------------------------
*     FUNCTIONS
* -------------------------------------------------------------- */
threadedOscReceiver::threadedOscReceiver()
{

}

//--------------------------------------------------------------
threadedOscReceiver::~threadedOscReceiver()
{

}

//--------------------------------------------------------------
void threadedOscReceiver::setup(int portNr)
{
	oscReceiver.setup(portNr);
}

//--------------------------------------------------------------
void threadedOscReceiver::start()
{
	if (appDebug) {
		cout << "[threadedOscReceiver::start] starting thread..." << endl;
	}
	startThread(true);
}

//--------------------------------------------------------------
void threadedOscReceiver::stop()
{
	stopThread();
	if (appDebug) {
		cout << "[threadedOscReceiver::stop] thread stopped" << endl;
	}
}

//--------------------------------------------------------------
void threadedOscReceiver::threadedFunction()
{
	while (isThreadRunning() != 0)
	{
		while (oscReceiver.hasWaitingMessages()) {
			haveInput = parseInput();
			if (haveInput == -1) {
				if (appDebug) cout << "OSC parsing error" << endl;
			}
		}
	}
}

//--------------------------------------------------------------
int threadedOscReceiver::parseInput()
{
	string baseStr = OSC_ADDSTR_ROOT;
	unsigned int baseEnd = baseStr.length();
	string createStr = OSC_ADDSTR_CREATE;
	string deleteStr = OSC_ADDSTR_DELETE;
	ofxOscMessage m;
	oscReceiver.getNextMessage(m);
	string compStr = m.getAddress();

	if (compStr.compare(0, baseStr.length(), baseStr) != 0) {
		if (appDebug) cout << "Base address mismatch!" << endl;
		return -1;
	}
	else if (compStr.compare(baseEnd, createStr.length(), createStr) == 0) {
		if (appDebug) cout << "Creating new instance " << m.getArgAsInt(0) << endl;
		return 0xf0;
	}
	else if (compStr.compare(baseEnd, deleteStr.length(), deleteStr) == 0) {
		if (appDebug) cout << "Deleting instance " << endl;
		return 0xf1;
	}
	else {
		int pNum
			= compStr.at(baseEnd) - '1';
		if (appDebug) cout << "Parsing peripheral# " << pNum << endl;
		if (pNum >= SMS_MAX_PERIPH) {
			if(appDebug) cout << "Maximum number of instances reached" << endl;
			return -1;
		}
		string buttonStr = "button";
		string pressureStr = "pressure";
		string mpuStr = "mpu";
		unsigned int periphStart = baseEnd + 2; // periph# (1 digit) + '/'
        long now = ofGetElapsedTimeMillis();
		if (!compStr.compare(periphStart, buttonStr.length(), buttonStr)) {
			if (appDebug) cout << "button" << endl;
			rcvButton[pNum].button = m.getArgAsInt32(BUTDATA_ARG_BUTTON_POS);
			rcvButton[pNum].oldTs = rcvButton[pNum].curTs;
            rcvButton[pNum].curTs = now;
			rcvButton[pNum].battery = m.getArgAsInt32(BUTDATA_ARG_BATTERY_POS);
			rcvButton[pNum].newData = true;
			return pNum;
		}
		else if (!compStr.compare(periphStart, pressureStr.length(), pressureStr)) {
			if (appDebug) cout << "pressure" << endl;
			rcvPressure[pNum].pressure = m.getArgAsInt32(PRESSDATA_ARG_PRESS_POS);
			rcvPressure[pNum].temperature = m.getArgAsInt32(PRESSDATA_ARG_TEMP_POS);
			rcvPressure[pNum].oldTs = rcvPressure[pNum].curTs;
            rcvPressure[pNum].curTs = now;
			rcvPressure[pNum].battery = m.getArgAsInt32(PRESSDATA_ARG_BATTERY_POS);
            if(appDebug) cout << "Pressure service: p = 0x" << hex << rcvPressure[pNum].pressure << endl;
			rcvPressure[pNum].newData = true;
			return pNum;
		}
		else if (!compStr.compare(periphStart, mpuStr.length(), mpuStr)) {
			if (appDebug) cout << "mpu" << endl;
			rcvMpu[pNum].gyro[MPUDATA_MPUX_POS] = m.getArgAsInt32(MPUDATA_ARG_GYROX_POS);
			rcvMpu[pNum].gyro[MPUDATA_MPUY_POS] = m.getArgAsInt32(MPUDATA_ARG_GYROY_POS);
			rcvMpu[pNum].gyro[MPUDATA_MPUZ_POS] = m.getArgAsInt32(MPUDATA_ARG_GYROZ_POS);
			rcvMpu[pNum].accel[MPUDATA_MPUX_POS] = m.getArgAsInt32(MPUDATA_ARG_ACCELX_POS);
			rcvMpu[pNum].accel[MPUDATA_MPUY_POS] = m.getArgAsInt32(MPUDATA_ARG_ACCELY_POS);
			rcvMpu[pNum].accel[MPUDATA_MPUZ_POS] = m.getArgAsInt32(MPUDATA_ARG_ACCELZ_POS);
			rcvMpu[pNum].oldTs[MPUDATA_TS_GYRO_POS] = rcvMpu[pNum].curTs[MPUDATA_TS_GYRO_POS];
			rcvMpu[pNum].curTs[MPUDATA_TS_GYRO_POS] = now;
			if (m.getNumArgs() == MPUDATA_ARGS_COMPLETE) {
				rcvMpu[pNum].compass[MPUDATA_MPUX_POS] = m.getArgAsInt32(MPUDATA_ARG_COMPX_POS);
				rcvMpu[pNum].compass[MPUDATA_MPUY_POS] = m.getArgAsInt32(MPUDATA_ARG_COMPY_POS);
				rcvMpu[pNum].compass[MPUDATA_MPUZ_POS] = m.getArgAsInt32(MPUDATA_ARG_COMPZ_POS);
				rcvMpu[pNum].temperature = m.getArgAsInt32(MPUDATA_ARG_TEMP_POS);
				rcvMpu[pNum].battery = m.getArgAsInt32(MPUDATA_ARG_BATTERY_POS);
				rcvMpu[pNum].oldTs[MPUDATA_TS_COMP_POS] = rcvMpu[pNum].curTs[MPUDATA_TS_COMP_POS];
				rcvMpu[pNum].curTs[MPUDATA_TS_COMP_POS] = now;
				rcvMpu[pNum].newExtData = true;
			}
			rcvMpu[pNum].newData = true;
			return pNum;
		}
	}

	return -1; // if this line is reached, something went wrong!
}
