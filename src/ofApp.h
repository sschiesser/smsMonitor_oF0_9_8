#pragma once

#define POCO_NO_UNWINDOWS

#include "ofMain.h"
#include "ofxOsc.h"
#include "ofxImGui.h"
#include "ofxXmlSettings.h"
#include "ThemeTest.h"
#include "threadedOscReceiver.h"
#include "threadedOscSender.h"
#include "threadedHidReceiver.h"
#include "smsData.h"
#ifdef _WIN32
#include "threadedBleReceiver.h"
#endif

#define OSC_PORT                    11999
#ifndef SMS_MAX_PERIPH
#define SMS_MAX_PERIPH              4 // maximum amount of (each) fully-featured and remote peripherals
#endif

//#define NUM_MSG_STRINGS 20

/* DEFAULT SABRE RECEIVER HID VALUES
* =================================
* Change either here (static) or in the XML conf file (dynamic)
* Note: the constant values are 8-bit encoded. Conversion is
*       needed to fit with some wchar_t variables.
*/
#define SABRE_VENDORID "1C57"
#define SABRE_PRODUCTID "5ABE"
#define SABRE_MANUFACTURERSTRING "ICST"
#define SABRE_PRODUCTSTRING "SABRe"
#define SABRE_USAGE 0x0100
#define SABRE_USAGEPAGE 0xFFAB
/* ================================= */

/* MODIFY AT EACH VERSION CHANGE!!
* ================================= */
#define SERVER_VERSION "0.99"
/* ================================= */


/* Project-wide debug flag */
#ifdef _DEBUG
const bool appDebug = true;
//#elif (DEBUG==1)
//const bool appDebug = true;
#else
const bool appDebug = false;
#endif

struct guiModules {
	bool full[SMS_MAX_PERIPH];
	bool remote[SMS_MAX_PERIPH];
};

struct dataRefresh {
	bool accel;
	bool gyro;
	bool compass;
	bool headpitch;
	bool ahrs;
	bool pressure;
	bool temp[2];
	bool delta[3];
};

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void getBLEDeviceList();

		bool startBleHid();
		bool stopBleHid();

		bool startOscSender();
		bool stopOscSender();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseScrolled(float x, float y);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);

		void remapData(int p);
		void calcDelta(int p);
		void calcJoystick(int p);
		void calcAhrs(int p);
		long getWordClock();

		
		// rawHid
		threadedHidReceiver * RawHidThread;
		bool hidReceiverRunning;
		bool newBleValue;
		// BLE
#ifdef _WIN32
		threadedBleReceiver * BleHidThread;
#endif
		bool bleHidRunning;
		// ofxOsc
		threadedOscReceiver * OscReceiverThread;
		bool oscReceiverRunning;
		threadedOscSender * OscSenderThread;
		bool oscSenderRunning;

		ofTrueTypeFont font;

		long wordClockBase;

		// ofxImGui
		ofxImGui::Gui gui;
		ImVec4 backgroundColor;
		ImFont *fontClock;
		ImFont *fontDisplay;
		ImFont *fontScale;
		unsigned char* fontPx;
		int fontW, fontH;

		bool show_test_window;
		bool show_another_window;

		float floatValue;
		ofImage imageButtonSource;
		GLuint imageButtonID;

		ofPixels pixelsButtonSource;
		GLuint pixelsButtonID;

		ofTexture textureSource;
		GLuint textureSourceID;

		struct guiModules activeMods;
		struct dataRefresh redraw[SMS_MAX_PERIPH];
};
