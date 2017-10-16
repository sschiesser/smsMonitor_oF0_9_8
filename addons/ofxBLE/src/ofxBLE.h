//
// # import "ofxBLE.h"
//
//  Created by Andikan on 11/11/2014.
//
//

#pragma once

#include "ofApp.h"
#include "BLE.h"

#include "ofMain.h"

class ofApp;

@interface ofxBLEDelegate : NSObject <BLEDelegate>
{
    BLE *ble;
}

@property (assign, atomic) ofApp *dataDelegate;
@property (strong, nonatomic)   BLE *ble;
@property unsigned char * receivedDATA;
@property int lengthOfDATA;

@end


class ofxBLE{
protected:
    ofxBLEDelegate *dongle;

public:
    //constructor
    ofxBLE();
    //destructor
    ~ofxBLE();
    
    void update();
    void scanPeripherals();
   /* void sendDigitalOut(bool bState);
    void setAnalogInput(bool bState);*/
    void setDataDelegate(ofApp *delegate);
    //void getData();
    void sendServo(float _val);
    void sendData(UInt8 _b);
    
    int analogVAL;
    unsigned char * receivedDATA;
    int lengthOfDATA;
    
    bool isConnected();
    
    void readRSSI();
    
    bool isSearching();
    
    int displayRSSI();
    
    unsigned int connectedDevices;
    
    bool haveButtonDataFlag;
    bool haveButtonData();
    void sethaveButtonDatafalse();
    bool Button1Data();
    bool Button2Data();

    bool haveAirmemsDataFlag;
    bool haveAirmemsData();
    void sethaveAirmemsDatafalse();
    double PressureData();
    double TemperatureData();
    //double getPressureData;
    //double getTemperatureData;

    bool oscRunning;
    bool restart;
    
    bool haveahrsDataFlag;
    bool haveahrsData();
    void sethaveahrsDatafalse();
    double ahrsData(int i);
    double getahrsData;
     /*
    bool haveArimemsData();
    bool haveImuData();
    
    void sethaveArimemsDatafalse();
    void sethaveImuDatafalse();
    */
    void bleDidReceiveButtonData(const uint8_t *  data);
    void bleDidReceiveAirmemsData(const uint32_t *  data);
    void bleDidReceiveImuData(const uint8_t *  data);

    
    NSData *ButtonData();
    

    
};

//
