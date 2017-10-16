//
//  BluetoothHelper.cpp
//  smsMonitor
//
//  Created by SABRE on 14.10.17.
//

#include "BluetoothHelper.h"
#include "ofxBLE.h"



void deviceListChanged(void* data){
    char **p = (char**)data;
    printf("%s\n", p[0]);
    printf("%s\n", p[1]);
    printf("%s\n", p[2]);
    printf("%s\n", p[3]);

    printf("%ui\n", (unsigned int) sizeof(*p));

    NSLog(@"asdfqwpeofihasdkjfhawepfoih");

}

void BluetoothHelper::searchForDevices(ofxBLE * myofxBLE){
    
    
    int i = 0;

    myofxBLE->ofxBLE::scanPeripherals(deviceListChanged, &i);

    //myOfxBLE->ofxBLE::scanPeripherals();
    
    
}




