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
	if (appDebug) printf("[threadedOscSender::start] starting OSC sender thread...\n");
	startThread();
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
          /*  m[0].clear();
            m[0].setAdress("/button1");
             m[i].addIntArg
            
            sender[ID].sendMessage( m[i] );
            */
        }
    }
}
