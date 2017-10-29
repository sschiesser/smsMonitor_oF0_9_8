//
//  BluetoothHelper.hpp
//  smsMonitor
//
//  Created by SABRE on 14.10.17.
//

#ifndef BluetoothHelper_hpp
#define BluetoothHelper_hpp

#include <stdio.h>
//#include "ofApp.hpp"
#include "Constants.h"
#include <string>
#include <thread>
#include <vector>


//#include "ofxBLE.h"

#endif /* BluetoothHelper_hpp */

struct bluetoothDevice{
    std::string name;
    std::string uuid;
    int status;
};


class BluetoothHelper{
public:
    int connectedDevices = 0;    
    
    BluetoothHelper();
    void searchForDevices(std::vector<bluetoothDevice>* result);
    //void setofxBLE(ofxBLE *myofxBLE1);
    void connectWithDevice(int deviceAtPosition);
    void disconnectSensor();
    void disconnectRemote();
    void calibrate();
    double getBatteryLevelSensor();
    double getBatteryLevelRemote();
    bool getButton1DataRemote();
    bool getButton2DataRemote();
    bool getButton1Data();
    bool getButton2Data();
    bool haveAirmemsData();
    double getPressure();
    double getTemperature();
    void sethaveAirmemsDatafalse();
    bool haveahrsData();
    double getAhrsData(int i);
    void sethaveahrsDatafalse();
    bool isSearching();
    bool isConnected();
    bool isRemoteConnected();
    float getLinkStrengthSensor();
    float getLinkStrengthRemote();
    bool haveButtonData();
    void getDeviceList(std::vector<bluetoothDevice>* result);
    

private:
    void loadDevices(std::vector<bluetoothDevice>* result);
    std::vector<bluetoothDevice>* currentDeviceList;

    
};
