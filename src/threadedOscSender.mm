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
    // set OSC-Adresses:
    SMS_sensors_button_address[0] = "/sabre/SMS_sensors/buttons/button1";
    SMS_sensors_button_address[1] = "/sabre/SMS_sensors/buttons/button2";
    
    SMS_sensors_airmems_pressure_address = "/sabre/SMS_sensors/airpressure";

    SMS_sensors_IMU_ahrs_quat[0] = "/sabre/SMS_sensors/motion/ahars/quat1";
    SMS_sensors_IMU_ahrs_quat[1] = "/sabre/SMS_sensors/motion/ahars/quat2";
    SMS_sensors_IMU_ahrs_quat[2] = "/sabre/SMS_sensors/motion/ahars/quat3";
    SMS_sensors_IMU_ahrs_quat[3] = "/sabre/SMS_sensors/motion/ahars/quat4";

    SMS_sensors_airmems_temperature_address = "/sabre/SMS_sensors/temperature/breath";
    SMS_sensors_IMU_temperature_address = "/sabre/SMS_sensors/temperature/room";

    
}

void threadedOscSender::resetValues()
{
    for(int i = 0; i < SMS_MAX_PERIPH; i++) {
        sendData->pressure = 0;
        sendData->battery = 0;
        sendData->wordClock = 0;
        
        for(int j = 0; j < 2; j++) {
            sendData->button[j] = 0;
            sendData->temperature[j] = 0;
            sendData->joystick[j] = 0.0;
        }
        
        for(int j = 0; j < 3; j++) {
            sendData->gyro[j] = 0.0;
            sendData->accel[j] = 0.0;
            sendData->compass[j] = 0.0;
            sendData->delta[j] = 0;
            sendData->ahrs[j] = 0.0;
        }
        
        for(int j = 0; j < 4; j++) {
            sendData->timestamp[j] = 0;
            sendData->quat[j] = 0.0;
        }
    }
}

//--------------------------------------------------------------
void threadedOscSender::start()
{
	//if (appDebug) printf("[threadedOscSender::start] starting OSC sender thread...\n");
	startThread();
    
    NSLog(@"oscthread started");
}

//--------------------------------------------------------------
void threadedOscSender::stop()
{
	//if (appDebug) printf("[threadedOscSender::stop] stopping OSC sender thread...\n");
	stopThread();
    NSLog(@"oscthread stopped");

}

//--------------------------------------------------------------
void threadedOscSender::threadedFunction()
{
    while(isThreadRunning()) {
        long curTime = ofGetElapsedTimeMillis();
        for(int i = 0; i < SMS_MAX_PERIPH; i++) {
            //send Button
            
            if (newButtonData){
                
                m[0].clear();
                m[0].setAddress(SMS_sensors_button_address[0]);
                m[0].addIntArg(sendData[0].button[SMSDATA_BUTTON_B0_POS]);
                oscSender[0].sendMessage( m[0] );
                
                m[1].clear();
                m[1].setAddress(SMS_sensors_button_address[1]);
                m[1].addIntArg(sendData[0].button[SMSDATA_BUTTON_B1_POS]);
                oscSender[0].sendMessage( m[1] );
                
                 NSLog(@"button send over osc");
                newButtonData = false;
                
            }
            
            //send airPressure
            if (newAirpressureData){
                
                
                m[2].clear();
                m[2].setAddress(SMS_sensors_airmems_pressure_address);
                m[2].addIntArg(sendData[0].pressure);
                oscSender[0].sendMessage( m[2] );
                
                
                newAirpressureData = false;
            }
            
            //send motionData
            
            if (newIMUData){
                
                for (int j = 3; j < 7; j++){
                    
                    m[j].clear();
                    m[j].setAddress(SMS_sensors_IMU_ahrs_quat[j-3]);
                    m[j].addIntArg(sendData[0].quat[j-3]);
                    oscSender[0].sendMessage( m[j] );
                    
                    
                    newIMUData = false;
                }
            }
            
            //send temperatureData
            
            if (newTemperatureData){
                
                
                m[7].clear();
                m[7].setAddress(SMS_sensors_airmems_temperature_address);
                m[7].addIntArg(sendData[0].temperature[0]);
                oscSender[0].sendMessage( m[7] );
                
                m[8].clear();
                m[8].setAddress(SMS_sensors_IMU_temperature_address);
                m[8].addIntArg(sendData[0].temperature[1]);
                oscSender[0].sendMessage( m[8] );
                newTemperatureData = false;
                
            }
            
            if ( newButtonData == false && newAirpressureData == false && newTemperatureData == false && newTemperatureData == false)
            {
                sleep(2);
            }
        }
    }
}
