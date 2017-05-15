#pragma once
/* --------------------------------------------------------------
*     INCLUDES
* -------------------------------------------------------------- */
#include "ofMain.h"
#include "ofApp.h"


/* --------------------------------------------------------------
*     MACROS
* -------------------------------------------------------------- */


/* --------------------------------------------------------------
*     CLASS DECLARATIONS
* -------------------------------------------------------------- */
class threadedHidReceiver : public ofThread
{
public:
	threadedHidReceiver();
	~threadedHidReceiver();

	void setup();
	void start();
	void stop();
	void threadedFunction();
	int parseInput();
};
