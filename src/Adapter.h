//
//  Adapter.cpp
//  smsMonitor
//
//  Created by SABRE on 28.10.17.
//

#include "BLE.h"

class Adapter{
public:
    Adapter();
    void scanPeripherals();
    NSMutableArray* getPeripherals();
    void connectWithPeripheral(int index);
    bool getButton(int i);
    bool isConnected();
    bool isRemoteConnected();
    bool isSearching();
    double getAhrs(int i);
    float getTemperature();
    float getPressure();
    float getBatteryLevelSensor();
    float getBatteryLevelRemote();
    void calibrate();
    int getLinkStrengthSensor();
    int getLinkStrengthRemote();
    void disconnectSensor();
    void disconnectRemote();
    

private:
    BLEObjectiveC *ble;
    
};
