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
#define OSC_SENDER_MAX				4
#define OSC_SENDER_DEFAULT_IP		"127.0.0.1"
#define OSC_SENDER_DEFAULT_PORT		12999

#define OSC_SENDER_MODE_NORMAL		1
#define OSC_SENDER_MODE_IEM			16

#define OSC_DEFAULT_SENDING_INT_MS  50

#ifndef SMS_MAX_PERIPH
#define SMS_MAX_PERIPH              4
#endif

/* --------------------------------------------------------------
*     CLASS DECLARATIONS
* -------------------------------------------------------------- */
class threadedOscSender : public ofThread
{
public:
	threadedOscSender();
	~threadedOscSender();

	void setup();
	void start();
	void stop();
	void threadedFunction();

	ofxOscSender oscSender[OSC_SENDER_MAX];
	bool oscSenderActive[OSC_SENDER_MAX];
	int oscSenderMode[OSC_SENDER_MAX];
	string oscSenderIp[OSC_SENDER_MAX];
	int oscSenderPort[OSC_SENDER_MAX];
	int lastOscSender;
    
    bool readyToSend[SMS_MAX_PERIPH];
    long oscSendingInterval[SMS_MAX_PERIPH];
    long oscPrevTime[SMS_MAX_PERIPH];

	struct smsData sendData[SMS_MAX_PERIPH];
};