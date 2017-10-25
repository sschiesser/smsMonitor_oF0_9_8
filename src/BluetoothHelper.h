//
//  BluetoothHelper.hpp
//  smsMonitor
//
//  Created by SABRE on 14.10.17.
//

#ifndef BluetoothHelper_hpp
#define BluetoothHelper_hpp

#include <stdio.h>
#include "ofxBLE.h"


#endif /* BluetoothHelper_hpp */

typedef struct{
    bool button1;
    bool button2;
}sensorData;


class BluetoothHelper{
public:
    void searchForDevices(vector<bluetoothDevice>* result);
    void setofxBLE(ofxBLE *myofxBLE1);
    void connectWithDevice(int deviceAtPosition);
    void disconnect();
    void calibrate();
    double getBatteryLevel();
private:
    void loadDevices(vector<bluetoothDevice>* result);
    void getData(sensorData* s);
};
