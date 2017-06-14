#include "ofApp.h"
#include "smsGui.h"

#include "ofxBLE.h"

#ifdef _WIN32
#include "combaseapi.h"
#endif

#define IM_ARRAYSIZE(_ARR)  ((int)(sizeof(_ARR)/sizeof(*_ARR)))

ofxBLE * MEINofxBLE;

//--------------------------------------------------------------
void ofApp::setup() {
	string appVersion = SERVER_VERSION;
	string titleString = "SMS monitor version " + appVersion;
	if (appDebug) {
		printf("*************************************\n\r");
		printf("**   SMS monitor version %s   **\n\r", appVersion.c_str());
		printf("*************************************\n\r");
	}
	ofSetLogLevel(OF_LOG_VERBOSE);
    

    
    
	// Setup rawHID receiver
	RawHidThread = new(threadedHidReceiver);
	hidReceiverRunning = false;

	// Setup BLE receiver
//	BleHidThread = new(threadedBleReceiver);
//	bleHidRunning = false;

	// Setup OSC receiver
	OscReceiverThread = new(threadedOscReceiver);
	OscReceiverThread->setup(OSC_PORT);
	oscReceiverRunning = false;

	// Setup OSC sender
	OscSenderThread = new(threadedOscSender);
	OscSenderThread->setup();
	oscSenderRunning = false;


	// Setup ImGui
	ImGuiIO io = ImGui::GetIO();
	fontDisplay = io.Fonts->AddFontFromFileTTF(&ofToDataPath("lucidagrande.ttf")[0], 14.f);
	fontClock = io.Fonts->AddFontFromFileTTF(&ofToDataPath("lucidagrande.ttf")[0], 24.f);
	fontScale = io.Fonts->AddFontFromFileTTF(&ofToDataPath("lucidagrande.ttf")[0], 10.f);
	io.Fonts->GetTexDataAsRGBA32(&fontPx, &fontW, &fontH);

	ofSetFrameRate(10);

	gui.setup();

	//backgroundColor is stored as an ImVec4 type but can handle ofColor
	backgroundColor = ofColor(114, 144, 154);

	if (!appDebug) ofSetEscapeQuitsApp(false);
	ofSetWindowTitle(titleString);
	show_test_window = true;
	show_another_window = false;
	floatValue = 0.0f;

	//load your own ofImage
	imageButtonSource.load("of.png");
	imageButtonID = gui.loadImage(imageButtonSource);

	//or have the loading done for you if you don't need the ofImage reference
	//imageButtonID = gui.loadImage("of.png");

	//can also use ofPixels in same manner
	ofLoadImage(pixelsButtonSource, "of_upside_down.png");
	pixelsButtonID = gui.loadPixels(pixelsButtonSource);

	//and alt method
	//pixelsButtonID = gui.loadPixels("of_upside_down.png");

	//pass in your own texture reference if you want to keep it
	textureSourceID = gui.loadTexture(textureSource, "of_upside_down.png");

	//or just pass a path
	//textureSourceID = gui.loadTexture("of_upside_down.png");

	ofLogVerbose() << "textureSourceID: " << textureSourceID;

	/* STARTING APPLICATION */
	//GUID AGuid;
	//CLSIDFromString(TEXT(TO_SEARCH_DEVICE_UUID), &AGuid);
	//BleHidThread->start();
	//BleHidThread->bleHidDevice.openDevice(AGuid);
    

    //starting Bluetooth
    MEINofxBLE = new(ofxBLE);
    
}

//--------------------------------------------------------------
void ofApp::getBLEDeviceList()
{

	if (appDebug) {
		printf("[ofApp::getBLEDeviceList] Listing bonded BLE devices...\n");
	}
}


//--------------------------------------------------------------
bool ofApp::startBleHid()
{
	if (appDebug) printf("[ofApp::startHID] starting BLE HID device\n");

//	GUID AGuid;
//	CLSIDFromString(TEXT(TO_SEARCH_DEVICE_UUID), &AGuid);
	//BleHidThread->bleHidDevice.openDevice(AGuid);
//	BleHidThread->openDevice(AGuid);
	//BleHidThread->bleHidDevice.deviceOpen = true;

	return true;
}

//--------------------------------------------------------------
bool ofApp::stopBleHid()
{
	if (appDebug) printf("[ofApp::stopHID] stopping BLE HID device\n");
//	BleHidThread->closeDevice();
	//BleHidThread->bleHidDevice.deviceOpen = false;

	return true;
}


//--------------------------------------------------------------
bool ofApp::startOscSender()
{
	if (appDebug) printf("[ofApp::startOSC] starting OSC sender thread\n");
	OscSenderThread->start();
	return true;
}

//--------------------------------------------------------------
bool ofApp::stopOscSender()
{
	if (appDebug) printf("[ofApp::stopOSC] stopping OSC sender thread\n");
	OscSenderThread->stop();
	return true;
}


bool doSetTheme = false;
//--------------------------------------------------------------
void ofApp::update() {

	if (doSetTheme)
	{
		doSetTheme = false;
		gui.setTheme(new ThemeTest());
	}

	if (OscReceiverThread->haveInput > 0x0f) {
		if (appDebug) cout << "Control command " << OscReceiverThread->haveInput << endl;
		OscReceiverThread->haveInput = -1;
	}
	else if (OscReceiverThread->haveInput >= 0) {
		if (appDebug) cout << "Input in periph#" << OscReceiverThread->haveInput << endl;
		remapData(OscReceiverThread->haveInput);
		OscReceiverThread->haveInput = -1;
	}
}

bool doThemeColorsWindow = false;
//--------------------------------------------------------------
void ofApp::draw() {
	ofSetBackgroundColor(backgroundColor);
	gui.begin();

	// Main window
	{
		ImGui::SetNextWindowSize(ImVec2(ofGetWidth(), GUI_HEADER_HEIGHT));
		ImGui::SetNextWindowPos(ImVec2(0, 0));
		ImGuiWindowFlags winFlagsMain = 0;
		winFlagsMain |= ImGuiWindowFlags_NoMove;
		winFlagsMain |= ImGuiWindowFlags_NoResize;
		winFlagsMain |= ImGuiWindowFlags_NoTitleBar;
		bool showWindowMain = true;

		ImGui::Begin("Main Window", &showWindowMain, winFlagsMain);
		{
			// Header bar
			ImGui::BeginGroup();
			{
				// Left part with connected device & framerate
				{
					ImGui::BeginGroup();
					/* HID device info */
					ImGui::Text("Device xx");
					/* Framerate */
					ImGui::Text("Current framerate: %.1f FPS", ImGui::GetIO().Framerate);
					ImGui::EndGroup();
				}
				// Start/stop button
				{
					ImGui::SameLine(286);
					ImGui::PushFont(fontClock);
					if (bleHidRunning) {
						ImGui::PushStyleColor(ImGuiCol_Button, ImColor::HSV(1 / 7.0f, 0.8f, 0.8f));
						ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImColor::HSV(1 / 7.0f, 0.9f, 0.9f));
						ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImColor::HSV(1 / 7.0f, 1.0f, 1.0f));
						if (ImGui::Button("Stop")) {
							OscSenderThread->stop();
							oscSenderRunning = false;

							stopBleHid();

//							BleHidThread->stop();
							bleHidRunning = false;
						}
					}
					else {
						ImGui::PushStyleColor(ImGuiCol_Button, ImColor::HSV(1 / 7.0f, 0.6f, 0.6f));
						ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImColor::HSV(1 / 7.0f, 0.7f, 0.7f));
						ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImColor::HSV(1 / 7.0f, 0.8f, 0.8f));
						if (ImGui::Button("Start")) {
							wordClockBase = ofGetSystemTime();
//							BleHidThread->start();
							bleHidRunning = true;

							startBleHid();

							OscSenderThread->start();
							oscSenderRunning = true;
						}
					}
					ImGui::PopStyleColor(3);
					ImGui::PopFont();
				}
                
                //Connect Button
                {
                    
                    
                    if (MEINofxBLE->isConnected() == false)
                    {
                        ImGui::SameLine(ImGui::GetWindowWidth()-100);
                        ImGui::PushFont(fontClock);
                        
                        ImGui::PushStyleColor(ImGuiCol_Button, ImColor::HSV(1 / 7.0f, 0.8f, 0.8f));
                        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImColor::HSV(1 / 7.0f, 0.9f, 0.9f));
                        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImColor::HSV(1 / 7.0f, 1.0f, 1.0f));
                        if (ImGui::Button("Connect")) {
                            
                            //=================*DeviceList*=========================
                            NSLog(@"look for Devices!");
                        
                            //    ofxBLE * MEINofxBLE;
                            BLEConnectButton = true;
                        
                            MEINofxBLE->ofxBLE::scanPeripherals();
                            
                        }
                    }/*
                    else if (BLEConnectButton == true && MEINofxBLE->isConnected() == false){
                        
                        //NSLog(@"connecting button on");
                        
                        ImGui::SameLine(ImGui::GetWindowWidth()-120);
                        ImGui::PushFont(fontClock);
                        ImGui::PushStyleColor(ImGuiCol_Button, ImColor::HSV(1 / 7.0f, 0.8f, 0.8f));
                        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImColor::HSV(1 / 7.0f, 0.9f, 0.9f));
                        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImColor::HSV(1 / 7.0f, 1.0f, 1.0f));
                        if (ImGui::Button("connecting")) {
                        }
                        
                    }*/
                    else if (MEINofxBLE->isConnected() == true ){
                        BLEConnectButton = false;
                        ImGui::SameLine(ImGui::GetWindowWidth()-120);
                        ImGui::PushFont(fontClock);
                        ImGui::PushStyleColor(ImGuiCol_Button, ImColor::HSV(1 / 7.0f, 0.8f, 0.8f));
                        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImColor::HSV(1 / 7.0f, 0.9f, 0.9f));
                        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImColor::HSV(1 / 7.0f, 1.0f, 1.0f));
                        if (ImGui::Button("Disconnect")) {
                             MEINofxBLE->ofxBLE::scanPeripherals();
                            
                        }
                    }
                    
                    ImGui::PopStyleColor(3);
                    ImGui::PopFont();
                    
                }
                
                //connecting information
                
                {
                    if(BLEConnectButton)
                    {
                        ImGui::SameLine(ImGui::GetWindowWidth()-300);
                        ImGui::PushFont(fontClock);
                        ImGui::Text("connecting...");
                        ImGui::PopFont();
                    }
                }
                
                
				// Timecode
				{
					ImGui::SameLine(360);
					static long ts, ms, s, m, h;
					if (oscReceiverRunning) {
						ts = getWordClock();
						ms = ts % 1000;
						s = ((ts - ms) / 1000) % 60;
						m = ((((ts - ms) / 1000) - s) / 60) % 60;
						h = (((((ts - ms) / 1000) - s) / 60) - m) / 60;
					}
					ImGui::PushFont(fontClock);
					ImGui::Text("Systime: %ldh %02ldm %02lds %03ld", h, m, s, ms);
					ImGui::PopFont();
				}
			}
			ImGui::EndGroup();
		}
		ImGui::End();

		activeMods.full[0] = true;
		activeMods.full[1] = false;
		activeMods.full[2] = false;
		activeMods.full[3] = false;
		activeMods.remote[0] = false;
		activeMods.remote[1] = false;
		activeMods.remote[2] = false;
		activeMods.remote[3] = false;

		// module windows
		for (int mod = 0; mod < SMS_MAX_PERIPH; mod++) {
			if (activeMods.full[mod]) {
				// General window settings
				ImVec2 moduleWindowSize;
				ImVec2 moduleWindowPos;
				moduleWindowSize.x = GUI_MODULE_WIDTH;
				moduleWindowSize.y = GUI_MODULE_HEIGHT;
				moduleWindowPos.x = GUI_MODULE_POS_X0 + (mod * GUI_MODULE_WIDTH);
				moduleWindowPos.y = GUI_MODULE_POS_Y;
				ImGui::SetNextWindowSize(moduleWindowSize);
				ImGui::SetNextWindowPos(moduleWindowPos);
				//ImGui::SetWindowCollapsed(false);
				ImGuiWindowFlags winFlagsMod = 0;
				winFlagsMod |= ImGuiWindowFlags_NoMove;
				winFlagsMod |= ImGuiWindowFlags_NoResize;
				winFlagsMod |= ImGuiWindowFlags_NoCollapse;
				bool showWindow = false;
				string modLabel = "Module #" + ofToString(mod + 1);

				ImGui::Begin(modLabel.c_str(), &showWindow, winFlagsMod);
				// Link quality & battery level (non-collapsable)
				{
					// Link quality display
					{
						ImGui::Text("Link:");
						ImGui::SameLine();
                        float link = 0;
                        if (MEINofxBLE->isConnected()){
                             link = MEINofxBLE->displayRSSI();
                            link = (link + 100.0) / 100.0;
                        }

                        
						char buf[32];
						sprintf(buf, "%d/%d", (int)((link + 0.09) * 10), 10);
						ImGui::PushItemWidth(112);
						ImGui::ProgressBar(link, ImVec2(0.f, 0.f), buf);
						ImGui::PopItemWidth();
					}
					// Battery level display
					{
						ImGui::SameLine(172);
						ImGui::Text("Battery:");
						ImGui::SameLine();
						//float battery = (rand() % 100) / 100.;
                        float battery = 0;
						ImGui::PushItemWidth(112);
						ImGui::ProgressBar(battery, ImVec2(0.0f, 0.0f));
						ImGui::PopItemWidth();
					}
				}

				// Network settings
				{
					ImGuiTreeNodeFlags nodeFlags = 0;
					nodeFlags |= ImGuiTreeNodeFlags_CollapsingHeader;
					nodeFlags |= ImGuiTreeNodeFlags_DefaultOpen;
					bool showHeader = true;
					if (ImGui::CollapsingHeader("OSC", &showHeader, nodeFlags)) {
						string label;
						char txt[OSC_SENDER_MAX][128];
						int in[OSC_SENDER_MAX];
						bool en[OSC_SENDER_MAX];
						string ID;
						for (int i = 0; i < OSC_SENDER_MAX; i++) {
							// label
							{
								label = "Sender#" + ofToString(i + 1) + ":";
								ImGui::Text(label.c_str());
							}
							// IP
							{
								ImGui::Text("IP:"); ImGui::SameLine();
								strcpy(txt[i], OscSenderThread->oscSenderIp[i].c_str());
								ID = "##senderIP" + ofToString(i); // ID = ##senderIP{0-3} FOR ALL INSTANCES!
								ImGui::PushItemWidth(112);
								if (ImGui::InputText(ID.c_str(), txt[i], IM_ARRAYSIZE(txt[i]), ImGuiInputTextFlags_EnterReturnsTrue)) {
									OscSenderThread->oscSenderIp[i] = ofToString(txt[i]);
									if (appDebug) cout << "New IP for sender#" << i << ": " << OscSenderThread->oscSenderIp[i].c_str() << endl;
								}
								ImGui::PopItemWidth();
							}
							// Port
							{
								ImGui::SameLine();
								in[i] = OscSenderThread->oscSenderPort[i];
								ImGui::Text("Port:"); ImGui::SameLine();
								ID = "##senderPort" + ofToString(i); // ID = ##senderPort{0-3} FOR ALL INSTANCES!
								ImGui::PushItemWidth(100);
								if (ImGui::InputInt(ID.c_str(), &in[i], 1, 1, ImGuiInputTextFlags_EnterReturnsTrue)) {
									OscSenderThread->oscSenderPort[i] = in[i];
									if (appDebug) printf("New port: %d\n", OscSenderThread->oscSenderPort[i]);
								}
								ImGui::PopItemWidth();
							}
							// Enable
							{
								ImGui::SameLine();
								en[i] = OscSenderThread->oscSenderActive[i];
								ImGui::Text("En:"); ImGui::SameLine();
								ID = "##senderEn" + ofToString(mod) + ofToString(i); // ID = ##senderEn{0-3} CURRENTLY SAME FOR ALL INSTANCE!
								if (ImGui::Checkbox(ID.c_str(), &en[i])) {
									OscSenderThread->oscSenderActive[i] = en[i];
									if (appDebug) cout << "Sender activated: " << ((en[i] == 1) ? "YES" : "NO") << endl;
								}
							}
						}
					}
				}

				// Accelerometer header
				{
					if (ImGui::CollapsingHeader("Accelerometer")) {
						static float accel[4];
						static ImVector<float> accelPlot[4];
						static int accelPlotOffset[4] = { 0, 0, 0, 0 };
						// Fill the 4 accelerometer values
						for (int i = 0; i < 4; i++) {
							if (accelPlot[i].empty()) {
								accelPlot[i].resize(50);
								memset(accelPlot[i].Data, 0, accelPlot[i].Size * sizeof(float));
							}
							accel[i] = OscSenderThread->sendData[mod].accel[i];
							accelPlot[i][accelPlotOffset[i]] = accel[i];
							accelPlotOffset[i] = (accelPlotOffset[i] + 1) % accelPlot[i].Size;
						}
						// X
						{
							ImGui::Text("X"); ImGui::SameLine(40);
							ImGui::PushItemWidth(140);
							string id = "##accelX" + ofToString(mod);
							ImGui::SliderFloat(id.c_str(), &accel[0], 0.0f, 1.0f); ImGui::SameLine();
							string idPlot = "##accelXPlot" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), accelPlot[0].Data, accelPlot[0].Size, 0, "", 0.0f, 1.0f, ImVec2(0, 20));
							ImGui::PopItemWidth();
						}
						// Y
						{
							ImGui::Text("Y"); ImGui::SameLine(40);
							ImGui::PushItemWidth(140);
							string id = "##accelY" + ofToString(mod);
							ImGui::SliderFloat(id.c_str(), &accel[1], 0.0f, 1.0f); ImGui::SameLine();
							string idPlot = "##accelYPlot" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), accelPlot[1].Data, accelPlot[1].Size, 0, "", 0.0f, 1.0f, ImVec2(0, 20));
							ImGui::PopItemWidth();
						}
						// Z
						{
							ImGui::Text("Z"); ImGui::SameLine(40);
							ImGui::PushItemWidth(140);
							string id = "##accelZ" + ofToString(mod);
							ImGui::SliderFloat(id.c_str(), &accel[2], 0.0f, 1.0f); ImGui::SameLine();
							string idPlot = "##accelZPlot" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), accelPlot[2].Data, accelPlot[2].Size, 0, "", 0.0f, 1.0f, ImVec2(0, 20));
							ImGui::PopItemWidth();
						}
						// Sum
						{
							ImGui::Text("Sum"); ImGui::SameLine(40);
							ImGui::PushItemWidth(140);
							string id = "##accelSum" + ofToString(mod);
							ImGui::SliderFloat(id.c_str(), &accel[3], 0.0f, 1.0f); ImGui::SameLine();
							string idPlot = "##accelSumPlot" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), accelPlot[3].Data, accelPlot[3].Size, 0, "", 0.0f, 1.0f, ImVec2(0, 20));
							ImGui::PopItemWidth();
						}
					}
				}

				// Gyroscope header
				{
					if (ImGui::CollapsingHeader("Gyroscope")) {
						static float gyro[4];
						static ImVector<float> gyroPlot[4];
						static int gyroPlotOffset[4] = { 0, 0, 0, 0 };
						// Fill the 4 gyroscope values
						for (int i = 0; i < 4; i++) {
							if (gyroPlot[i].empty()) {
								gyroPlot[i].resize(50);
								memset(gyroPlot[i].Data, 0, gyroPlot[i].Size * sizeof(float));
							}
							gyro[i] = OscSenderThread->sendData[mod].gyro[i];
							gyroPlot[i][gyroPlotOffset[i]] = gyro[i];
							gyroPlotOffset[i] = (gyroPlotOffset[i] + 1) % gyroPlot[i].Size;
						}
						// X
						{
							ImGui::Text("X"); ImGui::SameLine(40);
							ImGui::PushItemWidth(140);
							string id = "##gyroX" + ofToString(mod);
							ImGui::SliderFloat(id.c_str(), &gyro[0], 0.0f, 1.0f); ImGui::SameLine();
							string idPlot = "##gyroPlot" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), gyroPlot[0].Data, gyroPlot[0].Size, 0, "", 0.0f, 1.0f, ImVec2(0, 20));
							ImGui::PopItemWidth();
						}
						// Y
						{
							ImGui::Text("Y"); ImGui::SameLine(40);
							ImGui::PushItemWidth(140);
							string id = "##gyroY" + ofToString(mod);
							ImGui::SliderFloat(id.c_str(), &gyro[1], 0.0f, 1.0f); ImGui::SameLine();
							string idPlot = "##gyroYPlot" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), gyroPlot[1].Data, gyroPlot[1].Size, 0, "", 0.0f, 1.0f, ImVec2(0, 20));
							ImGui::PopItemWidth();
						}
						// Z
						{
							ImGui::Text("Z"); ImGui::SameLine(40);
							ImGui::PushItemWidth(140);
							string id = "##gyroZ" + ofToString(mod);
							ImGui::SliderFloat(id.c_str(), &gyro[2], 0.0f, 1.0f); ImGui::SameLine();
							string idPlot = "##gyroZPlot" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), gyroPlot[2].Data, gyroPlot[2].Size, 0, "", 0.0f, 1.0f, ImVec2(0, 20));
							ImGui::PopItemWidth();
						}
						// Sum
						{
							ImGui::Text("Sum"); ImGui::SameLine(40);
							ImGui::PushItemWidth(140);
							string id = "##gyroSum" + ofToString(mod);
							ImGui::SliderFloat(id.c_str(), &gyro[3], 0.0f, 1.0f); ImGui::SameLine();
							string idPlot = "##gyroSumPlo" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), gyroPlot[3].Data, gyroPlot[3].Size, 0, "", 0.0f, 1.0f, ImVec2(0, 20));
							ImGui::PopItemWidth();
						}
					}
				}

				// Heading/tilt header
				{
					if (ImGui::CollapsingHeader("Heading/tilt")) {

					}
				}

				// AHRS header
				{
					if (ImGui::CollapsingHeader("AHRS")) {
					}
				}

				// Buttons header
				{
					if (ImGui::CollapsingHeader("Buttons")) {
						ImGui::Text(""); ImGui::SameLine(80);
						string l0 = "##but0" + ofToString(mod);
						ImGui::Checkbox(l0.c_str(), &OscSenderThread->sendData[mod].button[SMSDATA_BUTTON_B0_POS]); ImGui::SameLine(200);
						string l1 = "##but1" + ofToString(mod);
						ImGui::Checkbox(l1.c_str(), &OscSenderThread->sendData[mod].button[SMSDATA_BUTTON_B1_POS]);
						ImGui::Text(""); ImGui::SameLine(85);
						ImGui::Text("1"); ImGui::SameLine(205);
						ImGui::Text("2");
					}
				}

				// Pressure header
				{
					if (ImGui::CollapsingHeader("Pressure")) {
						static float press;
						static ImVector<float> pVals;
						static int pValsOffset = 0;
						if (pVals.empty()) {
							pVals.resize(100);
							memset(pVals.Data, 0, pVals.Size * sizeof(float));
						}
						press = OscSenderThread->sendData[0].pressure;
						pVals[pValsOffset] = 0.;
						pValsOffset = (pValsOffset + 1) % pVals.Size;
						ImGui::BeginGroup();
						{
							ImGui::BeginGroup();
							{
								ImGui::Text("Pressure:");
								ImGui::Text("%.0f mbar", press);
							}
							ImGui::EndGroup(); ImGui::SameLine(80);
							string id = "##pressSlider" + ofToString(mod);
							ImGui::VSliderFloat(id.c_str(), ImVec2(12, 80), &press, -200.0f, 200.0f, ""); ImGui::SameLine(92);
							string idPlot = "##pressPlot" + ofToString(mod);
							ImGui::PlotLines(idPlot.c_str(), pVals.Data, pVals.Size, 0, "Pressure (mbar)", -200.0f, 200.0f, ImVec2(252, 80));
						}
						ImGui::EndGroup();
					}
				}

				// Temperature header
				{
					if (ImGui::CollapsingHeader("Temperature")) {
						// Temp @ pressure
						{
							static ImVector<float> tpVals;
							static int tpValsOffset = 0;
							if (tpVals.empty()) {
								tpVals.resize(100);
								memset(tpVals.Data, 0, tpVals.Size * sizeof(float));
							}
							tpVals[tpValsOffset] = OscSenderThread->sendData[0].temperature[0];
							tpValsOffset = (tpValsOffset + 1) % tpVals.Size;
							ImGui::BeginGroup();
							{
								ImGui::BeginGroup();
								{
									ImGui::Text("Temp #1:");
									ImGui::Text("%.2f °C", tpVals[tpValsOffset]);
								}
								ImGui::EndGroup(); ImGui::SameLine(80);
								string id = "##temp_p" + ofToString(mod);
								ImGui::PlotLines(id.c_str(), tpVals.Data, tpVals.Size, 0, "Temperature (°C)", 20.0f, 32.0f, ImVec2(264, 80));
							}
							ImGui::EndGroup();
						}

						// Temp @ mpu
						{
							static ImVector<float> tmVals;
							static int tmValsOffset = 0;
							if (tmVals.empty()) {
								tmVals.resize(100);
								memset(tmVals.Data, 0, tmVals.Size * sizeof(float));
							}
							tmVals[tmValsOffset] = OscSenderThread->sendData[0].temperature[1];
							tmValsOffset = (tmValsOffset + 1) % tmVals.Size;
							ImGui::BeginGroup();
							{
								ImGui::BeginGroup();
								{
									ImGui::Text("Temp #2:");
									ImGui::Text("%.2f °C", tmVals[tmValsOffset]);
								}
								ImGui::EndGroup(); ImGui::SameLine(80);
								string id = "##temp_m" + ofToString(mod);
								ImGui::PlotLines(id.c_str(), tmVals.Data, tmVals.Size, 0, "Temperature (°C)", 20.0f, 32.0f, ImVec2(264, 80));
							}
							ImGui::EndGroup();
						}
					}
				}

				// Packet transmition header
				{
					if (ImGui::CollapsingHeader("Packets transmition")) {
						static float plotRange = 200.;
						static float plotDiv = plotRange / 5.f;

						// Delta @ pressure
						{
							static ImVector<float> dPressVals;
							static int dPressValsOff = 0;
							static float dPressSum = 0.;
							static float dPressAvg = 0;
							if (dPressVals.empty()) {
								dPressVals.resize(100);
								memset(dPressVals.Data, 0., dPressVals.Size * sizeof(float));
							}
							if (oscSenderRunning) {
								dPressSum = dPressSum - dPressVals[dPressValsOff];
								dPressVals[dPressValsOff] = ((float)OscSenderThread->sendData[0].delta[SMSDATA_DELTA_PRESS_POS] / 1.);
								dPressSum = dPressSum + dPressVals[dPressValsOff];
								dPressValsOff = (dPressValsOff + 1) % dPressVals.Size;
								dPressAvg = dPressSum / dPressVals.Size;
							}

							ImGui::BeginGroup();
							{
								ImGui::BeginGroup();
								{
									ImGui::Text("Delta:");
									ImGui::Text("%.1f ms", dPressVals[((dPressValsOff-1) + dPressVals.Size) % dPressVals.Size]);
									ImGui::Text("Avg:");
									ImGui::Text("%.1f ms", dPressAvg);
								}
								ImGui::EndGroup();

								ImGui::SameLine(80);
								string id = "##deltaPress" + ofToString(mod);
								ImGui::PlotHistogram(id.c_str(), dPressVals.Data, dPressVals.Size, 0, "Delta press (ms)", 0.0f, plotRange, ImVec2(0, 80));

								ImGui::SameLine();

								ImGui::PushFont(fontScale);
								ImGui::BeginGroup();
								{
									ImGui::Text("");
									ImGui::Text("- %.0f", (4 * plotDiv));
									ImGui::Text("- %.0f", (3 * plotDiv));
									ImGui::Text("- %.0f", (2 * plotDiv));
									ImGui::Text("- %.0f", plotDiv);
									ImGui::Text("- %.0f", 0.f);
								}
								ImGui::EndGroup();
								ImGui::PopFont();
							}
							ImGui::EndGroup();
						}

						ImGui::Spacing();
						ImGui::Spacing();

						// Delta @ gyro
						{
							static ImVector<float> dGyroVals;
							static int dGyroValsOff = 0;
							static float dGyroSum = 0.;
							static float dGyroAvg = 0.;
							if (dGyroVals.empty()) {
								dGyroVals.resize(100);
								memset(dGyroVals.Data, 0, dGyroVals.Size * sizeof(float));
							}
							if (oscSenderRunning) {
								dGyroSum = dGyroSum - dGyroVals[dGyroValsOff];
								dGyroVals[dGyroValsOff] = ((float)OscSenderThread->sendData[0].delta[SMSDATA_DELTA_GYRO_POS] / 1.);
								dGyroSum = dGyroSum + dGyroVals[dGyroValsOff];
								dGyroValsOff = (dGyroValsOff + 1) % dGyroVals.Size;
								dGyroAvg = dGyroSum / dGyroVals.Size;
							}
							ImGui::BeginGroup();
							{
								ImGui::BeginGroup();
								{
									ImGui::Text("Delta:");
									ImGui::Text("%.1f ms", (dGyroVals[((dGyroValsOff-1) + dGyroVals.Size) % dGyroVals.Size]));
									ImGui::Text("Avg:");
									ImGui::Text("%.1f ms", dGyroAvg);
								}
								ImGui::EndGroup();

								ImGui::SameLine(80);
								string id = "##deltaGyro" + ofToString(mod);
								ImGui::PlotHistogram(id.c_str(), dGyroVals.Data, dGyroVals.Size, 0, "Delta gyro (ms)", 0.0f, plotRange, ImVec2(0, 80));
								ImGui::SameLine();

								ImGui::PushFont(fontScale);

								ImGui::BeginGroup();
								{
									ImGui::Text("");
									ImGui::Text("- %.0f", (4 * plotDiv));
									ImGui::Text("- %.0f", (3 * plotDiv));
									ImGui::Text("- %.0f", (2 * plotDiv));
									ImGui::Text("- %.0f", plotDiv);
									ImGui::Text("- %.0f", 0.f);
								}
								ImGui::EndGroup();

								ImGui::PopFont();
							}
							ImGui::EndGroup();
						}

						ImGui::Spacing();
						ImGui::Spacing();

						// Delta @ compass
						{
							static ImVector<float> dCompVals;
							static int dCompValsOff = 0;
							static float dCompSum = 0.;
							static float dCompAvg = 0.;
							if (dCompVals.empty()) {
								dCompVals.resize(100);
								memset(dCompVals.Data, 0, dCompVals.Size * sizeof(float));
							}
							if (oscSenderRunning) {
								dCompVals[dCompValsOff] = ((float)OscSenderThread->sendData[0].delta[SMSDATA_DELTA_GYRO_POS] / 1.);
								for (int i = 0; i < dCompVals.Size; i++) {
									dCompSum += dCompVals[i];
								}
								dCompAvg = dCompSum / dCompVals.Size;
								dCompSum = 0;
								dCompValsOff = (dCompValsOff + 1) % dCompVals.Size;
							}
							ImGui::BeginGroup();
							{
								ImGui::BeginGroup();
								{
									ImGui::Text("Delta:");
									ImGui::Text("%.1f ms", (dCompVals[((dCompValsOff-1) + dCompVals.Size) % dCompVals.Size]));
									ImGui::Text("Avg:");
									ImGui::Text("%.1f ms", dCompAvg);
								}
								ImGui::EndGroup();

								ImGui::SameLine(80);
								string id = "##deltaComp" + ofToString(mod);
								ImGui::PlotHistogram(id.c_str(), dCompVals.Data, dCompVals.Size, 0, "Delta comp (ms)", 0.0f, plotRange, ImVec2(0, 80));
								ImGui::SameLine();

								ImGui::PushFont(fontScale);

								ImGui::BeginGroup();
								{
									ImGui::Text("");
									ImGui::Text("- %.0f", (4 * plotDiv));
									ImGui::Text("- %.0f", (3 * plotDiv));
									ImGui::Text("- %.0f", (2 * plotDiv));
									ImGui::Text("- %.0f", plotDiv);
									ImGui::Text("- %.0f", 0.f);
								}
								ImGui::EndGroup();

								ImGui::PopFont();
							}
							ImGui::EndGroup();
						}
					}
				}

				ImGui::End();
			}
		}
	}
	//gui.end();	//In between gui.begin() and gui.end() you can use ImGui as you would anywhere else

	//////////////////////////////////////////////////////////////////////////////////////////
	//gui.begin();
	 //1. Show a simple window
	{
		ImGui::Text("Hello, world!");
		ImGui::SliderFloat("Float", &floatValue, 0.0f, 1.0f);

		//this will change the app background color
		ImGui::ColorEdit3("Background Color", (float*)&backgroundColor);
		if (ImGui::Button("Test Window"))
		{
			show_test_window = !show_test_window;
		}

		if (ImGui::Button("Another Window"))
		{
			//bitwise OR
			show_another_window ^= 1;

		}
		ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
	}
	//2. Show another window, this time using an explicit ImGui::Begin and ImGui::End
	if (show_another_window)
	{
		//note: ofVec2f and ImVec2f are interchangeable
		ImGui::SetNextWindowSize(ofVec2f(200, 100), ImGuiSetCond_FirstUseEver);
		ImGui::Begin("Another Window", &show_another_window);
		ImGui::Text("Hello");
		ImGui::End();
	}

	//3. Show the ImGui test window. Most of the sample code is in ImGui::ShowTestWindow()
	if (show_test_window)
	{
		ImGui::SetNextWindowPos(ofVec2f(650, 20), ImGuiSetCond_FirstUseEver);
		ImGui::ShowTestWindow(&show_test_window);
	}


	bool pressed = ImGui::ImageButton((ImTextureID)(uintptr_t)imageButtonID, ImVec2(200, 200));
	pressed = ImGui::ImageButton((ImTextureID)(uintptr_t)pixelsButtonID, ImVec2(200, 200));
	pressed = ImGui::ImageButton((ImTextureID)(uintptr_t)textureSourceID, ImVec2(200, 200));


	if (doThemeColorsWindow)
	{
		gui.openThemeColorWindow();

	}

	//required to call this at end
	gui.end();

	//if (textureSource.isAllocated())
	//{
	//	//textureSource.draw(ofRandom(200), ofRandom(200));
	//}
}

//--------------------------------------------------------------
void ofApp::remapData(int p)
{
	// BLE button service
	if (OscReceiverThread->rcvButton[p].newData) {
		OscSenderThread->sendData[p].button[SMSDATA_BUTTON_B0_POS] = false;
		OscSenderThread->sendData[p].button[SMSDATA_BUTTON_B1_POS] = false;
		if ((OscReceiverThread->rcvButton[p].button & 0x80) == 0x80) {
			OscSenderThread->sendData[p].button[SMSDATA_BUTTON_B1_POS] = true;
		}
		if ((OscReceiverThread->rcvButton[p].button & 0x7f) != 0x00) {
			OscSenderThread->sendData[p].button[SMSDATA_BUTTON_B0_POS] = true;
		}
		OscSenderThread->sendData[p].timestamp[SMSDATA_TS_BUT_POS] = OscReceiverThread->rcvButton[p].curTs;
		OscSenderThread->sendData[p].battery = (float)OscReceiverThread->rcvButton[p].battery / 256;
		OscReceiverThread->rcvButton[p].newData = false;
	}

	// BLE pressure service
	if (OscReceiverThread->rcvPressure[p].newData) {
		OscSenderThread->sendData[p].pressure = (float)OscReceiverThread->rcvPressure[p].pressure / 100;
		OscSenderThread->sendData[p].temperature[SMSDATA_TEMP_PRESS_POS] = (float)OscReceiverThread->rcvPressure[p].temperature / 100;
		OscSenderThread->sendData[p].timestamp[SMSDATA_TS_PRESS_POS] = OscReceiverThread->rcvPressure[p].curTs;
		OscSenderThread->sendData[p].battery = (float)OscReceiverThread->rcvPressure[p].battery / 256;

		calcDelta(p);

		OscReceiverThread->rcvPressure[p].newData = false;
	}

	// BLE MPU service
	if (OscReceiverThread->rcvMpu[p].newData) {
		int gyroInt[3];
		int accelInt[3];
		int compassInt[3];
		float gyroFloat[4];
		float accelFloat[4];
		float compassFloat[4];
		// gyro
		gyroInt[SMSDATA_MPU_X_POS] = OscReceiverThread->rcvMpu[p].gyro[SMSDATA_MPU_X_POS];
		gyroFloat[SMSDATA_MPU_X_POS] = (float)gyroInt[SMSDATA_MPU_X_POS] / 32768.;
		OscSenderThread->sendData[p].gyro[SMSDATA_MPU_X_POS] = gyroFloat[SMSDATA_MPU_X_POS];
		gyroInt[SMSDATA_MPU_Y_POS] = OscReceiverThread->rcvMpu[p].gyro[SMSDATA_MPU_Y_POS];
		gyroFloat[SMSDATA_MPU_Y_POS] = (float)gyroInt[SMSDATA_MPU_Y_POS] / 32768.;
		OscSenderThread->sendData[p].gyro[SMSDATA_MPU_Y_POS] = gyroFloat[SMSDATA_MPU_Y_POS];
		gyroInt[SMSDATA_MPU_Z_POS] = OscReceiverThread->rcvMpu[p].gyro[SMSDATA_MPU_Z_POS];
		gyroFloat[SMSDATA_MPU_Z_POS] = (float)gyroInt[SMSDATA_MPU_Z_POS] / 32768.;
		OscSenderThread->sendData[p].gyro[SMSDATA_MPU_Z_POS] = gyroFloat[SMSDATA_MPU_Z_POS];
		OscSenderThread->sendData[p].gyro[SMSDATA_MPU_SUM_POS] = (fabs(gyroFloat[SMSDATA_MPU_X_POS]) + fabs(gyroFloat[SMSDATA_MPU_Y_POS]) + fabs(gyroFloat[SMSDATA_MPU_Z_POS])) / 3.;
		redraw[p].gyro = true;
		// accel
		accelInt[SMSDATA_MPU_X_POS] = OscReceiverThread->rcvMpu[p].accel[SMSDATA_MPU_X_POS];
		accelFloat[SMSDATA_MPU_X_POS] = (float)accelInt[SMSDATA_MPU_X_POS] / 32768.;
		OscSenderThread->sendData[p].accel[SMSDATA_MPU_X_POS] = accelFloat[SMSDATA_MPU_X_POS];
		accelInt[SMSDATA_MPU_Y_POS] = OscReceiverThread->rcvMpu[p].accel[SMSDATA_MPU_Y_POS];
		accelFloat[SMSDATA_MPU_Y_POS] = (float)accelInt[SMSDATA_MPU_Y_POS] / 32768.;
		OscSenderThread->sendData[p].accel[SMSDATA_MPU_Y_POS] = accelFloat[SMSDATA_MPU_Y_POS];
		accelInt[SMSDATA_MPU_Z_POS] = OscReceiverThread->rcvMpu[p].accel[SMSDATA_MPU_Z_POS];
		accelFloat[SMSDATA_MPU_Z_POS] = (float)accelInt[SMSDATA_MPU_Z_POS] / 32768.;
		OscSenderThread->sendData[p].accel[SMSDATA_MPU_Z_POS] = accelFloat[SMSDATA_MPU_Z_POS];
		OscSenderThread->sendData[p].accel[SMSDATA_MPU_SUM_POS] = (fabs(accelFloat[SMSDATA_MPU_X_POS]) + fabs(accelFloat[SMSDATA_MPU_Y_POS]) + fabs(accelFloat[SMSDATA_MPU_Z_POS])) / 3.;
		redraw[p].accel = true;
		// timestamp
		OscSenderThread->sendData[p].timestamp[SMSDATA_TS_GYRO_POS] = OscReceiverThread->rcvMpu[p].curTs[MPUDATA_TS_GYRO_POS];

		if (OscReceiverThread->rcvMpu[p].newExtData) {
			// compass
			compassInt[SMSDATA_MPU_X_POS] = OscReceiverThread->rcvMpu[p].compass[SMSDATA_MPU_X_POS];
			compassFloat[SMSDATA_MPU_X_POS] = (float)compassInt[SMSDATA_MPU_X_POS] / 32768.;
			OscSenderThread->sendData[p].compass[SMSDATA_MPU_X_POS] = compassFloat[SMSDATA_MPU_X_POS];
			compassInt[SMSDATA_MPU_Y_POS] = OscReceiverThread->rcvMpu[p].compass[SMSDATA_MPU_Y_POS];
			compassFloat[SMSDATA_MPU_Y_POS] = (float)compassInt[SMSDATA_MPU_Y_POS] / 32768.;
			OscSenderThread->sendData[p].compass[SMSDATA_MPU_Y_POS] = compassFloat[SMSDATA_MPU_Y_POS];
			compassInt[SMSDATA_MPU_Z_POS] = OscReceiverThread->rcvMpu[p].compass[SMSDATA_MPU_Z_POS];
			compassFloat[SMSDATA_MPU_Z_POS] = (float)compassInt[SMSDATA_MPU_Z_POS] / 32768.;
			OscSenderThread->sendData[p].compass[SMSDATA_MPU_Z_POS] = compassFloat[SMSDATA_MPU_Z_POS];
			OscSenderThread->sendData[p].compass[SMSDATA_MPU_SUM_POS] = (fabs(compassFloat[SMSDATA_MPU_X_POS]) + fabs(compassFloat[SMSDATA_MPU_Y_POS]) + fabs(compassFloat[SMSDATA_MPU_Z_POS])) / 3.;
			// temperature
			OscSenderThread->sendData[p].temperature[SMSDATA_TEMP_MPU_POS] = (float)OscReceiverThread->rcvMpu[p].temperature / 100;
			// timestamp
			OscSenderThread->sendData[p].timestamp[SMSDATA_TS_COMP_POS] = OscReceiverThread->rcvMpu[p].curTs[MPUDATA_TS_COMP_POS];
			// battery
			OscSenderThread->sendData[p].battery = (float)OscReceiverThread->rcvMpu[p].battery / 256;
		}

		calcDelta(p);
		calcJoystick(p);
		calcAhrs(p);

		OscReceiverThread->rcvMpu[p].newData = false;
		OscReceiverThread->rcvMpu[p].newExtData = false;
	}
}

//--------------------------------------------------------------
void ofApp::calcDelta(int p)
{
	// pressure
	if (OscReceiverThread->rcvPressure[p].newData) {
		OscSenderThread->sendData[p].delta[SMSDATA_DELTA_PRESS_POS] = OscReceiverThread->rcvPressure[p].curTs - OscReceiverThread->rcvPressure[p].oldTs;
	}
	// gyro
	if (OscReceiverThread->rcvMpu[p].newData) {
		OscSenderThread->sendData[p].delta[SMSDATA_DELTA_GYRO_POS] = OscReceiverThread->rcvMpu[p].curTs[MPUDATA_TS_GYRO_POS] - OscReceiverThread->rcvMpu[p].oldTs[MPUDATA_TS_GYRO_POS];
		if (OscReceiverThread->rcvMpu[p].newExtData) {
			// compass/temp
			OscSenderThread->sendData[p].delta[SMSDATA_DELTA_COMP_POS] = OscReceiverThread->rcvMpu[p].curTs[MPUDATA_TS_COMP_POS] - OscReceiverThread->rcvMpu[p].oldTs[MPUDATA_TS_COMP_POS];
		}
	}
}

//--------------------------------------------------------------
long ofApp::getWordClock()
{
	long now = ofGetSystemTime();
	return now - wordClockBase;
}

//--------------------------------------------------------------
void ofApp::calcJoystick(int p)
{
	double x, y; // z;
	double ax, ay, bx, by;
	double headTemp, pitchTemp;
	static double xOld = 0;
	static double yOld = 0;

	// Working in radian
	x = OscSenderThread->sendData[p].accel[SMSDATA_MPU_X_POS] * DEG_TO_RAD;
	y = OscSenderThread->sendData[p].accel[SMSDATA_MPU_Y_POS] * DEG_TO_RAD;

	// Ponderate immediate value to reduce jittering
	x = xOld + ((x - xOld) * 0.2);
	y = yOld + ((y - yOld) * 0.2);
	xOld = x;
	yOld = y;

	// Heading/pich calculation steps
	ax = sin(x);
	ay = sin(y);
	bx = tan(x);
	bx = bx * bx;
	by = tan(y);
	by = by * by;

	headTemp = ((59 * DEG_TO_RAD) + atan2(ax, ay)) * RAD_TO_DEG;
	if (headTemp > 180.0) {
		headTemp = -180.0 + (headTemp - 180.0);
	}
	else if (headTemp < -180.0) {
		headTemp = 180 + (headTemp + 180.0);
	}
	pitchTemp = CLAMP((atan(sqrt(by + by)) * RAD_TO_DEG * 8.0), 0.0, 1.0);

	OscSenderThread->sendData[p].joystick[SMSDATA_JOY_HEAD_POS] = headTemp;
	OscSenderThread->sendData[p].joystick[SMSDATA_JOY_PICTH_POS] = pitchTemp;
}

//--------------------------------------------------------------
void ofApp::calcAhrs(int p)
{

}

//--------------------------------------------------------------
void ofApp::BLEdidDisconnect() {
    
}

//--------------------------------------------------------------
void ofApp::BLEdidConnect() {
    
}

//--------------------------------------------------------------
void ofApp::BLEdidRecieveData(unsigned char *data, int length) {
    
}

//--------------------------------------------------------------
void ofApp::BLEdidUpdateRSSI(int rssi) {
    
}


//--------------------------------------------------------------
void ofApp::keyPressed(int key) {

	ofLogVerbose(__FUNCTION__) << key;
	switch (key)
	{
	case 't':
	{
		doThemeColorsWindow = !doThemeColorsWindow;
		break;
	}
	case 'c':
	{
		doSetTheme = !doSetTheme;
		break;
	}
	case 's':
	{
		break;
	}
	}

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key) {
	ofLogVerbose(__FUNCTION__) << key;

}

//--------------------------------------------------------------
void ofApp::mouseScrolled(float x, float y) {
	ofLogVerbose(__FUNCTION__) << "x: " << x << " y: " << y;
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h) {

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg) {

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo) {

}
