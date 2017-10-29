//
//  Adapter.hpp
//  smsMonitor
//
//  Created by SABRE on 28.10.17.
//

#include "Adapter.h"
#include <stdio.h>
#include "Constants.h"





/*C++ Getters----------*/

Adapter::Adapter() {
    
    ble = [[BLEObjectiveC alloc] init];
    //[ble viewDidLoad];
    [ble controlSetup:1];
    
}


bool Adapter::getButton(int i){
    const uint8_t *reportData;
    switch (i) {
        case BUTTON1_SENSOR:
            if(ble.ButtonData == nil){
                return false;
            }
            reportData = (const unsigned char *)[ble.ButtonData bytes];
            return reportData[1];
            break;
        case BUTTON2_SENSOR:
            if(ble.ButtonData == nil){
                return false;
            }
            reportData = (const unsigned char *)[ble.ButtonData bytes];
            return reportData[0];
            break;
        case BUTTON1_REMOTE:
            if(ble.ButtonDataRemote == nil){
                return false;
            }
            reportData = (const unsigned char *)[ble.ButtonDataRemote bytes];
            return reportData[1];
            break;
        case BUTTON2_REMOTE:
            if(ble.ButtonDataRemote == nil){
                return false;
            }
            reportData = (const unsigned char *)[ble.ButtonDataRemote bytes];
            return reportData[0];
            break;
            
        default:
            return false;
            break;
    }
    
}

void Adapter::scanPeripherals(){
    
    NSLog(@"*scanPeripherals*");
    
    if (ble.foundPeripherals != nil){
        ble.foundPeripherals = nil;
    }
    [ble findBLEPeripherals:2];
}

NSMutableArray* Adapter::getPeripherals(){
    
    return ble.foundPeripherals;
}

void Adapter::connectWithPeripheral(int index){
    [ble connectPeripheral:[ble.foundPeripherals objectAtIndex:index]];
}

bool Adapter::isConnected(){
    return ble.isSensorConnected;
}

bool Adapter::isRemoteConnected(){
    return ble.isRemoteConnected;
}

bool Adapter::isSearching(){
    return ble.isSearching;
}


double Adapter::getAhrs(int i){
    
    if(ble.ImuData != nil){
        const uint8_t *data = (const unsigned char *)[ble.ImuData bytes];
        
        typedef union float2bytes{
            float f;
            uint8_t b[4];
        }b2f_t;
        
        b2f_t q1;
        
        for (int j = 0 ; j < 4; j++){
            q1.b[j] = data[j + 4*i];
        }
        
        return q1.f;
    }
    else{
        return 0;
    }
    
    
    //haveahrsDataFlag = true;
    
}



float Adapter::getTemperature(){
    
    if(ble.AirmemsData != nil){
        const uint32_t *data = (const unsigned int *)[ble.AirmemsData bytes];
        return data[1]/100.0;
    }
    else{
        return 0.0;
    }
    
    
    //haveAirmemsDataFlag = true;
    
}



float Adapter::getPressure(){
    
    if(ble.AirmemsData != nil){
        
        //NSLog([NSString stringWithFormat:@"Airmemsdata:  %@",ble.AirmemsData]);
        const uint32_t *data = (const unsigned int *)[ble.AirmemsData bytes];
        return data[0]/100.0;
    }
    else{
        return 0.0;
    }
    //haveAirmemsDataFlag = true;
    
}

float Adapter::getBatteryLevelSensor(){
    if(ble.BatteryLevelSensor != nil){
        const uint8_t *data = (const unsigned char *)[ble.BatteryLevelSensor bytes];
        return data[0]/100.0;
    }
    else{
        return 0.0;
    }
    
}

float Adapter::getBatteryLevelRemote(){
    if(ble.BatteryLevelRemote != nil){
        const uint8_t *data = (const unsigned char *)[ble.BatteryLevelRemote bytes];
        return data[0]/100.0;
    }
    else{
        return 0.0;
    }
    
}


void Adapter::calibrate()
{
    
    const unsigned char bytes[] = {0x1b,0xca,0x57,0x1c};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    NSLog(@"%@", data);
    
    
    [ble writeCalibrate:data];
}

int Adapter::getLinkStrengthSensor(){
    return ble.rssiSensor;
}

int Adapter::getLinkStrengthRemote(){
    return ble.rssiRemote;
}

void Adapter::disconnectRemote(){
    [ble disconnectRemote];
}
void Adapter::disconnectSensor(){
    [ble disconnectSensor];
}



