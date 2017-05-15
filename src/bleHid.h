//#pragma once
///****************************************************************************
//* Copyright (c) 2016 Zurich University of the Arts. All Rights Reserved.
//*
//* This file is part of sabreServer
//*
//*
//* Redistribution and use in source and binary forms, with or without
//* modification, are permitted provided that the following conditions are met:
//*
//* 1. Redistributions of source code must retain the above copyright notice,
//* this list of conditions and the following disclaimer.
//*
//* 2. Redistributions in binary form must reproduce the above copyright
//* notice, this list of conditions and the following disclaimer in the
//* documentation and/or other materials provided with the distribution.
//*
//* 3. The name of the author may not be used to endorse or promote products
//* derived from this software without specific prior written permission.
//*
//* THIS SOFTWARE IS PROVIDED BY [LICENSOR] "AS IS" AND ANY EXPRESS OR IMPLIED
//* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
//* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
//* EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//*
//****************************************************************************/
//
///**
//* \file ofxRawHID.h
//
//* \author Jan Schacher
//* \author Sebastien Schiesser
//
//* \date 2 March 2016
//
//* \version 0.99
//
//*/
//
//
///* --------------------------------------------------------------
//*     INCLUDES
//* -------------------------------------------------------------- */
//#include "ofMain.h"
//#include <stdio.h>
//#include <string>
//#include <fileapi.h>
//#include <windows.h>
//#include <setupapi.h>
//#include <devguid.h>
//#include <regstr.h>
//#include <bthdef.h>
////#include <bthledef.h>
//#include <Bluetoothleapis.h>
//#pragma comment(lib, "SetupAPI")
//#pragma comment(lib, "BluetoothApis.lib")
//#pragma comment(lib, "Kernel32.lib")
//
//#include "ofApp.h"
//#include "threadedOscSender.h"
//
//
///* OS-specific includes */
//extern "C" {
//#ifdef _WIN64 // windows (64-bit)
//#include "bleapi.h"
//#elif _WIN32 // windows (32-bit)
//#include "bleapi.h"
//#elif __APPLE__ // apple
//#include "bleapi.h"
//
////#if TARGET_OS_IPHONE && TARGET_IPHONE_SIMULATOR
////#elif TARGET_OS_IPHONE
////#else
////#define TARGET_OS_OSX 1
////#endif
//
//#elif __linux // linux
//#elif __unix // all unices not caught above
//#elif __posix // POSIX
//#endif
//}
//
//
///* --------------------------------------------------------------
//*     MACROS
//* -------------------------------------------------------------- */
//#define HID_BUFFERSIZE 64 // max buffer size for read & write
//#define HID_MAXNUMDEVICES 32 // max number of device to be enumerated
//
//#define TO_SEARCH_DEVICE_UUID		L"{00001C57-1212-efde-1523-785feabcd123}" //SABRE_SMS SMSS service UUID
//
//#define SMSS_BUTTON_CHAR_SIZE		2
//#define SMSS_PRESS_CHAR_SIZE		8
//#define SMSS_IMU_CHAR_SIZE			16
//
//void cbFunction(BTH_LE_GATT_EVENT_TYPE EventType, PVOID EventOutParameter, PVOID Context);
//
///* --------------------------------------------------------------
//*     CLASS DECLARATIONS
//* -------------------------------------------------------------- */
///**
//* \brief ofxBLEDeviceInfo class
//*        Wrapper for the hid_device_info struct
//*
//* Class properties:
//* - inherits hid_device_info struct
//* - adds some operators to allow sorting
//* - adds device index and handle pointer
//*/
//class ofxBLEDeviceInfo : public ble_device_info {
//public:
//	friend bool operator<(const ble_device_info& c1, const ble_device_info& c2) {
//		return c1.product_id < c2.product_id;
//	}
//
//	friend bool operator==(const ble_device_info& c1, const ble_device_info& c2) {
//		return c1.product_id == c2.product_id;
//	}
//
//	ble_device *handle; // pointer to a hid_device item
//	int index; // device index set during enumeration
//};
//
//
///**
//* \brief bleHid class
//*        Contains attributes of the connected HID devices
//*
//* Class components:
//* - functions to handle with devices
//* - vector of all enumerated devices
//* - information about selected device (ofxHIDDeviceInfo)
//* - read/write data buffer
//* - flags to device status
//*/
//class bleHid
//{
//private:
//
//public:
//	bleHid();
//	~bleHid();
//
//	bool openDevice(GUID AGuid);
//	bool closeDevice();
//	bool isOpen();
//	int sendPacket();
//	int listDevices();
//	bool clearDeviceList();
//	HANDLE GetBLEHandle(GUID AGuid);
//
//	vector <ofxBLEDeviceInfo> BLEdevices; // vector of all enumerated HID devices
//	ofxBLEDeviceInfo selectedDeviceInfo; // information for one device
//	unsigned char buf[HID_BUFFERSIZE]; // data buffer for HID read & write transactions
//	bool deviceSelected; // (flag) one device found in the list and selected
//	bool deviceOpen; // (flag) selected device open
//	bool deviceUnplugged; // (flag) device unplugged
//	bool newBleVal;
//
//	//void receiveBleValues(BTH_LE_GATT_EVENT_TYPE EventType, PVOID EventOutParameter, PVOID Context);
//	void *receiveBleValues;
//
//	union f2b {
//		float val;
//		uint8_t b[4];
//	};
//
//	typedef struct smsBleChars {
//		uint8_t button[2];
//		int32_t pressure;
//		int32_t temperature;
//		union f2b quaternion[4];
//	}smsBleChars_t;
//
//	smsBleChars_t smsBleValues;
//
//	BLUETOOTH_GATT_EVENT_HANDLE bleEventHandle;
//};
//
////void receiveBleValues(BTH_LE_GATT_EVENT_TYPE EventType, PVOID EventOutParameter, PVOID Context);