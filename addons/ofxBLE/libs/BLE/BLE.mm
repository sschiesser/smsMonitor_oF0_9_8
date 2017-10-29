
/*
 
 Copyright (c) 2013 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BLE.h"
#import "BLEDefines.h"
#import "Cocoa/Cocoa.h"

@implementation BLEObjectiveC

@synthesize delegate;
@synthesize CM;
@synthesize foundPeripherals;
@synthesize activePeripheral;
@synthesize activePeripheralRemote;
@synthesize AirmemsData;
@synthesize ButtonData;
@synthesize ButtonDataRemote;
@synthesize ImuData;
@synthesize BatteryLevelSensor;
@synthesize BatteryLevelRemote;
@synthesize rssiSensor;
@synthesize rssiRemote;
@synthesize isSensorConnected;
@synthesize isRemoteConnected;

static bool isSearching = false;

int numberOfSMSDevice;
int checkNumberOFDevice;

-(void) readRSSI
{
   // return rssi;
    [activePeripheral readRSSI];
    [activePeripheralRemote readRSSI];
}

-(BOOL) isSearching
{
    return isSearching;
}



// SMS Service Charakteristiken


//Send Calibrate Request Sensor
-(void) writeCalibrate:(NSData *)d
{
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@CALIBRATE_CHARACTERISTIC_UUID];
    
    [self writeValue:uuid_service characteristicUUID:uuid_char p:activePeripheral data:d];
}


/*
-(void) readButton
{
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_BUTTON_UUID];

}
*/
/*
-(void) read
{
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_TX_UUID];
    
    [self readValue:uuid_service characteristicUUID:uuid_char p:activePeripheral];
}
*/
/*
-(void) write:(NSData *)d
{
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_RX_UUID];
    
    [self writeValue:uuid_service characteristicUUID:uuid_char p:activePeripheral data:d];
}
*/
/*
-(void) enableReadNotification:(CBPeripheral *)p
{
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_BUTTON_UUID];
    
    [self notification:uuid_service characteristicUUID:uuid_char p:p on:YES];
}
*/
/*
-(void) notification:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        NSLog(@"1 Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    [p setNotifyValue:on forCharacteristic:characteristic];
}
*/
/*
-(UInt16) frameworkVersion
{
    return RBL_BLE_FRAMEWORK_VER;
}
*/

-(NSString *) CBUUIDToString:(CBUUID *) cbuuid;
{
    NSData *data = cbuuid.data;
    
    if ([data length] == 2)
    {
        const unsigned char *tokenBytes = (unsigned char *)[data bytes];
        return [NSString stringWithFormat:@"%02x%02x", tokenBytes[0], tokenBytes[1]];
    }
    else if ([data length] == 16)
    {
        NSUUID* nsuuid = [[NSUUID alloc] initWithUUIDBytes:(unsigned char *)[data bytes]];
        return [nsuuid UUIDString];
    }
    
    return [cbuuid description];
}

-(void) readValue: (CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        NSLog(@"2 Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    [p readValueForCharacteristic:characteristic];
}

-(void) writeValue:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    
    if (!characteristic)
    {
        NSLog(@"3 Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

-(UInt16) swap:(UInt16)s
{
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

- (int) controlSetup: (int) s
{
    self.foundPeripherals=[NSMutableArray new];

    self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return 0;
}




- (int) findBLEPeripherals:(int) timeout
{
    NSLog(@"in findBLEPeripherals");
    NSLog(@"CM.state1: %ld",self.CM.state);

    if (self.CM.state != CBCentralManagerStatePoweredOn)
    {
        NSLog(@"CoreBluetooth not correctly initialized !");
        NSLog(@"State = %ld (%s)\r\n", self.CM.state, [self centralManagerStateToString:self.CM.state]);

        return -1;
    }
    
    isSearching = true;
    
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
#if TARGET_OS_IPHONE
    [self.CM scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]] options:nil];
#else
    [self.CM scanForPeripheralsWithServices:nil options:nil]; // Start scanning
#endif
    
    NSLog(@"scanForPeripheralsWithServices");

    return 0; // Started scanning OK !
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    if([peripheral.name isEqualToString:@"SMS_sensors"]){
        activePeripheral = nil;
    }
    else if([peripheral.name isEqualToString:@"SMS_remote"]){
        activePeripheralRemote = nil;
    }
    NSLog(@"didDisconnect");
    //NSLog([NSString stringWithFormat:@"%@", error]);
    [[self delegate] bleDidDisconnect];
    
    if(activePeripheral == nil){
        AirmemsData = nil;
        ButtonData = nil;
        BatteryLevelSensor = nil;
        ImuData = nil;
        isSensorConnected = false;
    }
    if(activePeripheralRemote == nil){
        ButtonDataRemote = nil;
        BatteryLevelRemote = nil;
        isRemoteConnected = false;
    }

    
    NSLog([NSString stringWithFormat:@"%@",error]);

}

-(void)disconnectSensor{
    [self.CM cancelPeripheralConnection:activePeripheral];
}

-(void)disconnectRemote{
    [self.CM cancelPeripheralConnection:activePeripheralRemote];
}


- (void) connectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connecting to peripheral with UUID : %@", peripheral.identifier.UUIDString);
    
    if([peripheral.name isEqualToString:@"SMS_sensors"]){
        self.activePeripheral = peripheral;
        self.activePeripheral.delegate = self;
        //peripheral.delegate = self;
        [self.CM connectPeripheral:self.activePeripheral
                           options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];

    }
    else if([peripheral.name isEqualToString:@"SMS_remote"]){
        self.activePeripheralRemote = peripheral;
        self.activePeripheralRemote.delegate = self;
        //peripheral.delegate = self;
        [self.CM connectPeripheral:self.activePeripheralRemote
                           options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];

    }
    //[self.CM connectPeripheral:peripheral options:nil];
}

- (const char *) centralManagerStateToString: (int)state
{
    switch(state)
    {
        case CBCentralManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    
    return "Unknown state";
}

- (void) scanTimer:(NSTimer *)timer
{
    [self.CM stopScan];
    NSLog(@"Stopped Scanning");
    NSLog(@"Known peripherals : %lu", (unsigned long)[self.foundPeripherals count]);
    isSearching = false;

    //[self printKnownPeripherals];
}

- (BOOL) UUIDSAreEqual:(NSUUID *)UUID1 UUID2:(NSUUID *)UUID2
{
    if ([UUID1.UUIDString isEqualToString:UUID2.UUIDString])
        return TRUE;
    else
        return FALSE;
}

-(void) getAllServicesFromPeripheral:(CBPeripheral *)p
{
    [p discoverServices:nil]; // Discover all services without filter
}

-(void) getAllCharacteristicsFromPeripheral:(CBPeripheral *)p
{
    for (int i=0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        //        printf("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
}

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    
    if (memcmp(b1, b2, UUID1.data.length) == 0)
        return 1;
    else
        return 0;
}

-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2
{
    char b1[16];
    
    [UUID1.data getBytes:b1];
    UInt16 b2 = [self swap:UUID2];
    
    if (memcmp(b1, (char *)&b2, 2) == 0)
        return 1;
    else
        return 0;
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID
{
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

-(CBUUID *) IntToCBUUID:(UInt16)UUID
{
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID])
            return s;
    }
    
    return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service
{
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    
    return nil; //Characteristic not found on this service
}

#if TARGET_OS_IPHONE
//-- no need for iOS
#else

- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    NSLog(@"CM.state2: %ld",self.CM.state);

    switch ([CM state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CBCentralManagerStatePoweredOn");
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:state];
    [alert addButtonWithTitle:@"OK"];
    [alert setIcon:[[NSImage alloc] initWithContentsOfFile:@"AppIcon"]];
    [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:nil contextInfo:nil];

    return FALSE;
}
#endif

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState");
#if TARGET_OS_IPHONE
    NSLog(@"Status of CoreBluetooth central manager changed %d (%s)", central.state, [self centralManagerStateToString:central.state]);
#else
    [self isLECapableHardware];
    NSLog(@"changed state");
    //[self findBLEPeripherals:2];
#endif
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"rssi: %@",RSSI);
    
    /*if (rssi != peripheral.RSSI.intValue)
    {
        rssi = peripheral.RSSI.intValue;
        
        NSLog(@"rssi: %i",rssi);
        //[[self delegate] bleDidUpdateRSSI:activePeripheral.RSSI];
    }
    */
    NSLog(@"didDiscoverPeripheral");
    if (self.foundPeripherals== nil){
        self.foundPeripherals = [[NSMutableArray alloc] initWithObjects:peripheral,nil];
        if(activePeripheral != nil){
            [self.foundPeripherals addObject:activePeripheral];
        }
        if(activePeripheralRemote != nil){
            [self.foundPeripherals addObject:activePeripheralRemote];
        }

    }
    else
    {
        
        //tutorial code
       /* NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
        if ([localName length] > 0) {
            NSLog(@"Found the SMS_Sensor: %@", localName);
            [self.CM stopScan];
            self.activePeripheral = peripheral;
            peripheral.delegate = self;
            [self.CM connectPeripheral:peripheral options:nil];
            */
        }
        
        
        //alter code
    
        for(int i = 0; i < self.foundPeripherals.count; i++)
        {
            CBPeripheral *p = [self.foundPeripherals objectAtIndex:i];
            
            if ((p.identifier == NULL) || (peripheral.identifier == NULL))
                continue;
            
            if ([self UUIDSAreEqual:p.identifier UUID2:peripheral.identifier])
            {
                [self.foundPeripherals replaceObjectAtIndex:i withObject:peripheral];
                NSLog(@"Duplicate UUID found updating...");
                return;
            }
        }
        
        [self.foundPeripherals addObject:peripheral];
        
        NSLog(@"New UUID, adding");
    
    
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral");
    //tutorial code:
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    if([peripheral.name isEqualToString:@"SMS_sensors"]){
        isSensorConnected = true;
    }
    else if([peripheral.name isEqualToString:@"SMS_remote"]){
        isRemoteConnected = true;
    }

    NSLog(@"%@", self.connected);
    
    [[self delegate] bleDidConnect];
    
    //alter code
    /*
    if (peripheral.identifier != NULL)
        NSLog(@"Connected to %@ successful", peripheral.identifier.UUIDString);
    else
        NSLog(@"Connected to NULL successful");
    
    self.activePeripheral = peripheral;
    [self.activePeripheral discoverServices:nil];
    [self getAllServicesFromPeripheral:peripheral];
     */
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"didfail toConnectPeripheral");
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // neuer tutorial code
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]])  {  // 1
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Request button notifications
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@RBL_CHAR_BUTTON_UUID]]) { // 2
              //  self.activePeripheral = aChar(type: aChar.UUID, properties: CBCharacteristicProperties.Read|CBCharacteristicProperties.Notifiy, value: self.dataToSend, permissions: CBAttributePermissions.Readable);

                if([peripheral.name isEqualToString:@"SMS_sensors"]){
                    [self.activePeripheral setNotifyValue:YES forCharacteristic:aChar];
                    NSLog(@"Found button characteristic");
                }
                
                else if([peripheral.name isEqualToString:@"SMS_remote"]){
                    [self.activePeripheralRemote setNotifyValue:YES forCharacteristic:aChar];
                    NSLog(@"Found button characteristic");
                }
                

            }
            // Request AIRMEMS notification
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@RBL_CHAR_AIRMEMS_UUID]]) { // 3
                [self.activePeripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found AIRMEMS characteristic");
            }
            // Request IMU notification
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@RBL_CHAR_IMU_UUID]]) { // 3
                [self.activePeripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found IMU characteristic");
            }
        }
        
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:@BATTERY_SERVICE_UUID]])  {
        for (CBCharacteristic *aChar in service.characteristics){
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@BATTERY_LEVEL_CHARACTERISTIC_UUID]]) { // 2
                if([peripheral.name isEqualToString:@"SMS_sensors"]){
                    [self.activePeripheral setNotifyValue:YES forCharacteristic:aChar];
                }
                else if([peripheral.name isEqualToString:@"SMS_remote"]){
                    [self.activePeripheralRemote setNotifyValue:YES forCharacteristic:aChar];
                    NSLog(@"Found battery characteristic");
                }
            }
        }

    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error)
    {
        //neu aus tutorial:
        for (CBService *service in peripheral.services) {
            NSLog(@"Discovered service: %@", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
//                printf("Services of peripheral with UUID : %s found\n",[self UUIDToString:peripheral.UUID]);
        
        // alter code:
        //[self getAllCharacteristicsFromPeripheral:peripheral];
    }
    else
    {
        NSLog(@"Service discovery was unsuccessful!");
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
       
//                printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
    }
    else
    {
        NSLog(@"Error in setting notification state for characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristic.UUID],
              [self CBUUIDToString:characteristic.service.UUID],
              peripheral.identifier.UUIDString);
        
        
        NSLog(@"Error code was %s", [[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{

    if([peripheral.name isEqualToString:@"SMS_sensors"]){
        if (!isSensorConnected){
            return;
        }
        rssiSensor = RSSI.intValue;
    }
    else if([peripheral.name isEqualToString:@"SMS_remote"]){
        if (!isRemoteConnected){
            return;
        }
        rssiRemote = RSSI.intValue;
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    [self readRSSI];
    if([peripheral.name isEqualToString:@"SMS_sensors"]){
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@RBL_CHAR_BUTTON_UUID]]) {
            //        NSLog(@"button received");
            // 1
            // Updated value for button received
            //NSLog(@"received a button change");
            //[self getButtonData:characteristic error:error];
            ButtonData = characteristic.value;
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@RBL_CHAR_AIRMEMS_UUID]]) {
            // Updated value for AIR received
            // NSLog(@"received a AIR change");
            AirmemsData = [characteristic value];
            
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@RBL_CHAR_IMU_UUID]]) {
            ImuData = [characteristic value];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@BATTERY_LEVEL_CHARACTERISTIC_UUID]]){
            BatteryLevelSensor = [characteristic value];
        }
    }
    else if([peripheral.name isEqualToString:@"SMS_remote"]){
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@RBL_CHAR_BUTTON_UUID]]) {
            NSLog(@"received a button change remote");
            ButtonDataRemote = [characteristic value];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@BATTERY_LEVEL_CHARACTERISTIC_UUID]]){
            BatteryLevelRemote = [characteristic value];
        }


    }

}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if([peripheral.name isEqualToString:@"SMS_sensors"]){
        if (!isSensorConnected){
            return;
        }
        rssiSensor = peripheral.RSSI.intValue;
    }
    else if([peripheral.name isEqualToString:@"SMS_remote"]){
        if (!isRemoteConnected){
            return;
        }
        rssiRemote = peripheral.RSSI.intValue;
    }

}

@end
