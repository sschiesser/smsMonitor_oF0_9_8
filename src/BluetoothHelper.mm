//
//  BluetoothHelper.cpp
//  smsMonitor
//
//  Created by SABRE on 14.10.17.
//

#include "BluetoothHelper.h"
#include "Adapter.h"
//#include "ofxAdapter.h"
//#include "Adapter.h"

Adapter *myAdapter;

BluetoothHelper::BluetoothHelper() {
    
    myAdapter = new(Adapter);
    currentDeviceList = new(std::vector<bluetoothDevice>);
    /*
    myofxAdapter = new(ofxAdapter);
    myofxAdapter->connectedDevices = 0;
    myofxAdapter->oscRunning = false;
    myofxAdapter->restart = false;
*/
}

void BluetoothHelper::getDeviceList(std::vector<bluetoothDevice>* result){
    
    result->clear();
    BluetoothHelper::currentDeviceList->clear();
    NSMutableArray *peripherals = myAdapter->Adapter::getPeripherals();
    if(peripherals == nil){
        result->clear();
    }
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
            switch (p.state) {
                case CBPeripheralStateConnected:
                    mD.status = PERIPHERAL_STATE_CONNECTED;
                    break;
                case CBPeripheralStateConnecting:
                    mD.status = PERIPHERAL_STATE_CONNECTING;
                    break;
                case CBPeripheralStateDisconnected:
                    mD.status = PERIPHERAL_STATE_DISCONNECTED;
                    break;
                    
                default:
                    break;
            }
            result->insert(result->end(), mD);
        }
        else{
            NSLog(@"A device identifier was NULL! (index: %d)", i);
        }
    }

}

/*starts a scan and after two seconds writes the found devices to the result pointer*/
void BluetoothHelper::searchForDevices(std::vector<bluetoothDevice>* result){
    
    myAdapter->Adapter::scanPeripherals();
    std::thread t1(&BluetoothHelper::loadDevices, this, result);
    t1.detach();

}

/*waits for two seconds and then reads the currently known devices and writes them to the result pointer*/
void BluetoothHelper::loadDevices(std::vector<bluetoothDevice>* result){
    sleep(2.0);
    NSMutableArray *peripherals = myAdapter->Adapter::getPeripherals();
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
            switch (p.state) {
                case CBPeripheralStateConnected:
                    mD.status = PERIPHERAL_STATE_CONNECTED;
                    break;
                case CBPeripheralStateConnecting:
                    mD.status = PERIPHERAL_STATE_CONNECTING;
                    break;
                case CBPeripheralStateDisconnected:
                    mD.status = PERIPHERAL_STATE_DISCONNECTED;
                    break;

                default:
                    break;
            }
            result->insert(result->end(), mD);
        }
        else{
            NSLog(@"A device identifier was NULL! (index: %d)", i);
        }
    }
    
}

/*connects with the device at a certain position in the device list*/
void BluetoothHelper::connectWithDevice(int deviceAtPosition){
    myAdapter->Adapter::connectWithPeripheral(deviceAtPosition);
}


void BluetoothHelper::disconnectRemote(){
    myAdapter->Adapter::disconnectRemote();
}

void BluetoothHelper::disconnectSensor(){
    myAdapter->Adapter::disconnectSensor();
}

void BluetoothHelper::calibrate(){
    myAdapter->Adapter::calibrate();
}


#pragma region DataGetters

double BluetoothHelper::getBatteryLevelSensor(){
    return myAdapter->Adapter::getBatteryLevelSensor();
}

double BluetoothHelper::getBatteryLevelRemote(){
    return myAdapter->Adapter::getBatteryLevelRemote();
}


bool BluetoothHelper::getButton1DataRemote(){
    return myAdapter->getButton(BUTTON1_REMOTE);
}
bool BluetoothHelper::getButton2DataRemote(){
    return myAdapter->getButton(BUTTON2_REMOTE);
}
bool BluetoothHelper::getButton1Data(){
    return myAdapter->getButton(BUTTON1_SENSOR);
}
bool BluetoothHelper::getButton2Data(){
    return myAdapter->getButton(BUTTON2_SENSOR);
}



#pragma toBeReplaced

bool BluetoothHelper::haveAirmemsData(){
    return true;
}

double BluetoothHelper::getPressure(){
    return myAdapter->Adapter::getPressure();

}
double BluetoothHelper::getTemperature(){
    return myAdapter->Adapter::getTemperature();

}
void BluetoothHelper::sethaveAirmemsDatafalse(){
    //return myofxAdapter->ofxAdapter::sethaveahrsDatafalse();

}
bool BluetoothHelper::haveahrsData(){
    //return myofxAdapter->ofxAdapter::haveahrsData();
    return true;

}
double BluetoothHelper::getAhrsData(int i){
    return myAdapter->Adapter::getAhrs(i);

}
void BluetoothHelper::sethaveahrsDatafalse(){
    //return myofxAdapter->ofxAdapter::sethaveahrsDatafalse();

}
bool BluetoothHelper::isSearching(){
    return myAdapter->Adapter::isSearching();

}
bool BluetoothHelper::isConnected(){
    return myAdapter->Adapter::isConnected();
}
bool BluetoothHelper::isRemoteConnected(){
    return myAdapter->Adapter::isRemoteConnected();
}

float BluetoothHelper::getLinkStrengthSensor(){
    return myAdapter->Adapter::getLinkStrengthSensor();

}
float BluetoothHelper::getLinkStrengthRemote(){
    return myAdapter->Adapter::getLinkStrengthRemote();    
}


bool BluetoothHelper::haveButtonData(){
    return false;
}





