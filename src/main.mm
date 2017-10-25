#include "ofMain.h"
#include "ofApp.hpp"
#include "smsGui.h"
#if (OF_VERSION_MINOR != 9) && defined(TARGET_OPENGLES)
#include "ofGLProgrammableRenderer.h"
#endif

#define FORCE_PROGRAMMMABLE 1

#ifdef FORCE_PROGRAMMMABLE
#include "ofGLProgrammableRenderer.h"
#endif


//========================================================================
int main() {
	ofSetLogLevel(OF_LOG_VERBOSE);
#if defined(TARGET_OPENGLES)
#if (OF_VERSION_MINOR == 9)
	ofGLESWindowSettings settings;
	settings.width = GUI_WINDOW_WIDTH;
	settings.height = GUI_WINDOW_HEIGHT;
	settings.setGLESVersion(2);
	ofCreateWindow(settings);
#else
	ofSetLogLevel("ofThread", OF_LOG_ERROR);
	ofSetCurrentRenderer(ofGLProgrammableRenderer::TYPE);
	ofSetupOpenGL(GUI_WINDOW_WIDTH, GUI_WINDOW_HEIGHT, OF_WINDOW);
#endif
#else
#ifdef FORCE_PROGRAMMMABLE
	ofGLWindowSettings glWindowSettings;
	glWindowSettings.width = GUI_WINDOW_WIDTH;
	glWindowSettings.height = GUI_WINDOW_HEIGHT;
	glWindowSettings.setGLVersion(3, 2);
	ofCreateWindow(glWindowSettings);
#else
	ofSetLogLevel("ofThread", OF_LOG_ERROR);
	ofSetupOpenGL(GUI_WINDOW_WIDTH, GUI_WINDOW_HEIGHT, OF_WINDOW);
#endif

#endif
	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp(new ofApp());
}
