//
//  ofxBLE.mm
//
//  Created by Andikan on 11/11/2014.
//

#import "ofxBLE.h"
#import "Cocoa/Cocoa.h"
// Objective C class implementations

@interface ofxBLEDelegate ()

@end

@implementation ofxBLEDelegate

@synthesize dataDelegate;
@synthesize ble;
@synthesize receivedDATA;
@synthesize lengthOfDATA;

bool haveButtonDataFlag;
bool haveahrsDataFlag;
bool haveAirmemsDataFlag;

bool Button1Remote = 0,Button2Remote = 0;

bool Button1 = 0,Button2 = 0;
float Pressure;
float Temperature;
float ahrs[4];
int ahrsIndex;
double batteryLevel;

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

//- (id)initWithStyle:(UITableViewStyle)style
//- (id)initWithStyle:()style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}


- (void)viewDidLoad
{

    ble = [[BLE alloc] init];
    [ble controlSetup:1];
    ble.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ----------- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#pragma mark - BLE delegate

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    self.dataDelegate->BLEdidDisconnect();
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    NSString *test = rssi.stringValue;
    self.dataDelegate->BLEdidUpdateRSSI([[test cStringUsingEncoding:NSASCIIStringEncoding] floatValue]);
    // cout << [test cStringUsingEncoding:NSASCIIStringEncoding] <<endl;
    
}

// When disconnected, this will be called
-(void) bleDidConnect
{
    NSLog(@"->Connected");
    self.dataDelegate->didBLEConnect();
}

// When data is comming, this will be called
/*-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    
   // NSLog(@"------- bleDidReceiveData");
    self.dataDelegate->BLEdidRecieveData(data,length);
    
}*/

#pragma mark - Actions

// Connect button will call to this
- (void)btnScanForPeripherals
{
    
    NSLog(@"I'm in the btnScanFor Peripherals");
    
    if (ble.activePeripheral)
    {
        
        NSLog(@"in ble.activePeripheral");
        /*
        if(ble.activePeripheral.isConnected)
        {
            if(appDebug){NSLog(@"it's still connected and will disconect now!");
            }
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
//            [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
         */
    }
    
    if (ble.peripherals) ble.peripherals = nil;
    
//    [btnConnect setEnabled:false];
    [ble findBLEPeripherals:2];
    
    //[NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
//    [indConnecting startAnimating];
}


-(void) calibrate
{
    //const unsigned char bytes[] = {0x1c,0x57,0xca,0x1b};

    const unsigned char bytes[] = {0x1b,0xca,0x57,0x1c};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    NSLog(@"%@", data);

    
    [ble writeCalibrate:data];
}

-(void) bleDidReceiveButtonData: (const uint8_t * ) data
{
        Button2 = data[0];
    
        Button1 = data[1];
    
    /*
    mySensorData->button1 = data[0];
    mySensorData->button2 = data[1];
    */
    haveButtonDataFlag = true;
}

-(void) bleDidReceiveButtonDataRemote: (const uint8_t * ) data
{
    Button2Remote = data[0];
    
    Button1Remote = data[1];
    
}

-(void) bleDidReceiveBatteryLevel:(const uint8_t *)data
{
    batteryLevel = data[0];
    batteryLevel = batteryLevel / 100.0;
}

-(double) getBatteryLevel
{
    return batteryLevel;
}

-(bool)getButton1Data
{
    return Button1;
}
-(bool)getButton2Data
{
    return Button2;
}

-(bool)getButton2DataRemote
{
    return Button2Remote;
}

-(bool)getButton1DataRemote
{
    return Button1Remote;
}


-(bool)gethaveButtonDataFlag
{
    return haveButtonDataFlag;
}

-(void)sethaveButtonDatafalse
{
    haveButtonDataFlag = false;
}
-(void) bleDidReceiveAirmemsData: (const uint32_t * ) data
{
    
    Pressure = data[0];
    Temperature = data[1];
    Pressure = Pressure / 100.0;
    Temperature = Temperature / 100.0;
    
//    NSLog(@"Pressure changed, %f",Pressure);
//    NSLog(@"Temperature changed, %f",Temperature);
    
    haveAirmemsDataFlag = true;

}
-(double)getPressureData
{
    return Pressure;
}
-(double)getTemperatureData
{
    return Temperature;
}
-(bool)gethaveAirmemsDataFlag
{
    return haveAirmemsDataFlag;
}

-(void)sethaveAirmemsDatafalse
{
    haveAirmemsDataFlag = false;
}
-(void) bleDidReceiveImuData: (const uint8_t * ) data
{
    
    
    
    typedef union float2bytes{
        float f;
        uint8_t b[4];
    }b2f_t;
    
    b2f_t q1;
    b2f_t q2;
    b2f_t q3;
    b2f_t q4;
    
    for (int i = 0 ; i < 4; i++){
        q1.b[i] = data[i];
        q2.b[i] = data[i+4];
        q3.b[i] = data[i+8];
        q4.b[i] = data[i+12];
    }
    
    ahrs[0] = q1.f;
    ahrs[1] = q2.f;
    ahrs[2] = q3.f;
    ahrs[3] = q4.f;

    NSLog(@"AHRS: %f %f %f %f", ahrs[0], ahrs[1], ahrs[2] ,ahrs[3]);
    
//    float f1, f2, f3, f4;
//    f1 = q1.f;
//    f2 = q2.f;
//    f3 = q3.f;
//    f4 = q4.f;
  //  NSLog(@"AHRS: %f %f %f %f", f1, f2, f3 ,f4);

    haveahrsDataFlag = true;

    
    
}
-(double)getahrsData
{
   // NSLog(@" ahrs: %f",ahrs[ahrsIndex]);

        return ahrs[ahrsIndex];

    
}

-(bool)gethaveahrsDataFlag
{
    return haveahrsDataFlag;
}

-(void)sethaveahrsDatafalse
{
    haveahrsDataFlag = false;
}
/*
-(void) connectionTimer:(NSTimer *)timer
{
    NSLog(@"in the Timer!");
//    [btnConnect setEnabled:true];
//    [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    

    if (ble.peripherals.count > 0)
    {
        NSLog(@"Peripherals found!");
        NSLog(@"Peripherlas : %@" , ble.peripherals);
        
       //[ble connectPeripheral:[ble.peripherals objectAtIndex:1]];
    }
    else
    {
        NSLog(@"there are no peripherals");
//        [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
//        [indConnecting stopAnimating];
    }
}
*/
//[someObject sendDigitalOut:self andBool:YES];
//-(void)sendDigitalOut:(id)sender andBool:(BOOL)someBool

//-(void)sendDigitalOut:(id)sender

/*
-(void)sendDigitalOut:(id)sender state:(BOOL)bStatus
{
    UInt8 buf[3] = {0x01, 0x00, 0x00};
    
    if (bStatus)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

 Send command to Arduino to enable analog reading */
/*
-(void)sendAnalogIn:(id)sender state:(BOOL)bStatus
{
    UInt8 buf[3] = {0xA0, 0x00, 0x00};
    
    //if (bStatus){
        buf[1] = 0x01;
        cout<< "setting analog input ON"<<endl;
//    } else {
//        buf[1] = 0x00;
//        cout<< "setting analog input OFF"<<endl;

    //}
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

// PWM slide will call this to send its value to Arduino
-(IBAction)sendPWM:(id)sender
{
    UInt8 buf[3] = {0x02, 0x00, 0x00};
    
//    buf[1] = sldPWM.value;
//    buf[2] = (int)sldPWM.value >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

// Servo slider will call this to send its value to Arduino
-(IBAction)sendServo:(id)sender
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    
//    buf[1] = sldServo.value;
//    buf[2] = (int)sldServo.value >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}
*/


@end



// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
//= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
//                                          C++ class implementation



ofxBLE::ofxBLE(){
    
    dongle = [[ofxBLEDelegate alloc]init];
    [dongle viewDidLoad];
    receivedDATA = 0;
}

ofxBLE::~ofxBLE(){

}

/*
void ofxBLE::setDataStruct(sensorData * s){
    mySensorData = s;
}
*/
void ofxBLE::update(){
    

}

NSMutableArray* ofxBLE::getPeripherals(){
    return dongle.ble.peripherals;
}


void ofxBLE::connectWithPeripheral(int index){

    [dongle.ble connectPeripheral:[dongle.ble.peripherals objectAtIndex:index]];
}




void ofxBLE::scanPeripherals(){
    NSLog(@"*scanPeripherals*");
    
    [dongle btnScanForPeripherals];
}



/*void ofxBLE::sendDigitalOut(bool bState){
    //[dongle sendDigitalOut:0];
    [dongle sendDigitalOut:0 state:bState];

//    UInt8 buf[3] = {0x01, 0x00, 0x00};
//    
//    if (bState) buf[1] = 0x01;
//    else        buf[1] = 0x00;
//    
//    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
//    [dongle.ble write:data];
    
}

void ofxBLE::sendServo(float _val){
    // Servo slider will call this to send its value to Arduino
        UInt8 buf[3] = {0x03, 0x00, 0x00};
        
        buf[1] = _val;
        buf[2] = (int)_val >> 8;
        
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [dongle.ble write:data];

}


void ofxBLE::sendData(UInt8 _b){
    UInt8 buf[1] = {_b};
    NSData *data = [[NSData alloc] initWithBytes:buf length:1];
    [dongle.ble write:data];
}



void ofxBLE::setAnalogInput(bool bState){
    // Send command to Arduino to enable analog reading

    [dongle sendAnalogIn:0];

}
*/

void ofxBLE::setDataDelegate(ofApp *delegate)
{
    if(delegate && this->dongle)
    {
        [dongle setDataDelegate:delegate];
    }
        
}


bool ofxBLE::isConnected(){
    
    return [dongle.ble isConnected];
}

void ofxBLE::readRSSI(){
    [dongle.ble readRSSI];
}

bool ofxBLE::isSearching()
{
    return [dongle.ble isSearching];
}

int ofxBLE::displayRSSI(){
    return [dongle.ble displayRSSI];
}

bool ofxBLE::haveButtonData(){
   return  [dongle gethaveButtonDataFlag];
}
void ofxBLE::sethaveButtonDatafalse(){
    [dongle sethaveButtonDatafalse];
}
double ofxBLE::BatteryLevel(){
    return [dongle getBatteryLevel];
}
bool ofxBLE::Button1Data(){
    return [dongle getButton1Data];
}
bool ofxBLE::Button2Data(){
    return [dongle getButton2Data];
}
bool ofxBLE::Button2DataRemote(){
    return [dongle getButton2DataRemote];
}
bool ofxBLE::Button1DataRemote(){
    return [dongle getButton1DataRemote];
}

bool ofxBLE::haveAirmemsData(){
    return  [dongle gethaveAirmemsDataFlag];
}
void ofxBLE::sethaveAirmemsDatafalse(){
    [dongle sethaveButtonDatafalse];
}

double ofxBLE::PressureData(){
    return [dongle getPressureData];
}
double ofxBLE::TemperatureData(){
    return [dongle getTemperatureData];
}
bool ofxBLE::haveahrsData(){
    return  [dongle gethaveahrsDataFlag];
}
void ofxBLE::sethaveahrsDatafalse(){
    [dongle sethaveahrsDatafalse];
}

void ofxBLE::calibrate(){
    [dongle calibrate];
}


double ofxBLE::ahrsData(int i){
   // NSLog(@"ahrsIndex: %i", ahrsIndex);
    ahrsIndex = i;
    return [dongle getahrsData];
}

/*
bool ofxBLE::haveArimemsData(){
    return [dongle.ble haveAirmemsData];
}
bool ofxBLE::haveImuData(){
    return [dongle.ble haveImuData];
}


void ofxBLE::sethaveArimemsDatafalse(){
    [dongle.ble sethaveAirmemsDatafalse];
}
void ofxBLE::sethaveImuDatafalse(){
    [dongle.ble sethaveImuDatafalse];
}
 
 
 
 




//NSData* ofxBLE::ButtonData(){
//    return [dongle.ble ButtonData];
//    
//
//    
//    int Button1;
//    int Button2;
//    
//   // const uint8_t *reportData = [ButtonData bytes];
//    
//    
//    Button1 = reportData[1];
//    
//    Button2 = reportData[0];
//    
//        // NSLog(@"ButtonData1: %i, ButtonData2: %i",Button1, Button2);
//    
//}
 */



