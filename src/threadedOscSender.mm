/* --------------------------------------------------------------
*     INCLUDES
* -------------------------------------------------------------- */
#include "ofApp.h"
#include "threadedOscSender.h"

/* --------------------------------------------------------------
*     FUNCTIONS
* -------------------------------------------------------------- */
threadedOscSender::threadedOscSender()
{

}

//--------------------------------------------------------------
threadedOscSender::~threadedOscSender()
{

}

//--------------------------------------------------------------
void threadedOscSender::setup()
{
	for (int i = 0; i < OSC_SENDER_MAX; i++) {
		oscSenderPort[i] = OSC_SENDER_DEFAULT_PORT;
		oscSenderIp[i] = OSC_SENDER_DEFAULT_IP;
		oscSenderActive[i] = false;
		oscSenderMode[i] = OSC_SENDER_MODE_NORMAL;
		oscSender[i].setup(oscSenderIp[i], oscSenderPort[i]);
//		if (appDebug) cout << "OSC sender set up: ip " << oscSenderIp[i] << ", port " << oscSenderPort[i] << ", mode " << oscSenderMode[i] << endl;
	}
    
    for(int i = 0; i < SMS_MAX_PERIPH; i++) {
        readyToSend[i] = false;
        oscSendingInterval[i] = OSC_DEFAULT_SENDING_INT_MS;
        oscPrevTime[i] = 0;
    }
}

//--------------------------------------------------------------
void threadedOscSender::start()
{
	//if (appDebug) printf("[threadedOscSender::start] starting OSC sender thread...\n");
	startThread();
    
    NSLog(@"got it to thrededoscsender");
}

//--------------------------------------------------------------
void threadedOscSender::stop()
{
	if (appDebug) printf("[threadedOscSender::stop] stopping OSC sender thread...\n");
	stopThread();
}

//--------------------------------------------------------------
void threadedOscSender::threadedFunction()
{
    while(isThreadRunning()) {
        long curTime = ofGetElapsedTimeMillis();
        for(int i = 0; i < SMS_MAX_PERIPH; i++) {
            //send Button
            m[0].clear();
            m[0].setAddress("/button1");
            m[0].addIntArg(sendData[0].button[SMSDATA_BUTTON_B0_POS]);
            
            oscSender[0].sendMessage( m[0] );
            
        }
    }
}
