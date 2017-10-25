//
//  BluetoothHelper.cpp
//  smsMonitor
//
//  Created by SABRE on 14.10.17.
//

#include "BluetoothHelper.h"
#include "ofxBLE.h"

ofxBLE *myofxBLE;

void BluetoothHelper::setofxBLE(ofxBLE *myofxBLE1){
    myofxBLE = myofxBLE1;
}

/*starts a scan and after two seconds writes the found devices to the result pointer*/
void BluetoothHelper::searchForDevices(vector<bluetoothDevice>* result){
    
    myofxBLE->ofxBLE::scanPeripherals();
    std::thread t1(&BluetoothHelper::loadDevices, this, result);
    t1.detach();

}

/*waits for two seconds and then reads the currently known devices and writes them to the result pointer*/
void BluetoothHelper::loadDevices(vector<bluetoothDevice>* result){
    sleep(2.0);
    NSMutableArray *peripherals = myofxBLE->ofxBLE::getPeripherals();
    for (int i = 0; i < peripherals.count; i++)
    {
        CBPeripheral *p = [peripherals objectAtIndex:i];
        
        if (p.identifier != NULL){
            struct bluetoothDevice mD;
            if(p.name != NULL){
                mD.name = std::string([p.name UTF8String]);
            }
            else{
                mD.name = "null";
            }
            mD.uuid = std::string([p.identifier.UUIDString UTF8String]);
            result->insert(result->end(), mD);
        }
        else{
            NSLog(@"A device identifier was NULL! (index: %d)", i);
        }
    }
    
}

/*connects with the device at a certain position in the device list*/
void BluetoothHelper::connectWithDevice(int deviceAtPosition){
    myofxBLE->ofxBLE::connectWithPeripheral(deviceAtPosition);
}

void BluetoothHelper::disconnect(){
    myofxBLE->ofxBLE::connectWithPeripheral(0);
}


