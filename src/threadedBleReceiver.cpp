/* --------------------------------------------------------------
*     INCLUDES
* -------------------------------------------------------------- */
#include "ofApp.h"
#include "threadedBleReceiver.h"


/* --------------------------------------------------------------
*     FUNCTIONS
* -------------------------------------------------------------- */
threadedBleReceiver::threadedBleReceiver()
{
}

//--------------------------------------------------------------
threadedBleReceiver::~threadedBleReceiver()
{

}

//--------------------------------------------------------------
void threadedBleReceiver::setup()
{

}

//--------------------------------------------------------------
/* try to open a selected HID device */
bool threadedBleReceiver::openDevice(GUID AGuid)
{
	HANDLE hLEDevice = GetBLEHandle(AGuid);

	USHORT serviceBufferCount;
	////////////////////////////////////////////////////////////////////////////
	// Determine Services Buffer Size
	////////////////////////////////////////////////////////////////////////////
	HRESULT hr = BluetoothGATTGetServices(hLEDevice, 0, NULL,
		&serviceBufferCount, BLUETOOTH_GATT_FLAG_NONE);

	if (HRESULT_FROM_WIN32(ERROR_MORE_DATA) != hr) {
		printf("BluetoothGATTGetServices - Buffer Size %d", hr);
	}

	PBTH_LE_GATT_SERVICE pServiceBuffer = (PBTH_LE_GATT_SERVICE)
		malloc(sizeof(BTH_LE_GATT_SERVICE) * serviceBufferCount);

	if (NULL == pServiceBuffer) {
		printf("pServiceBuffer out of memory\r\n");
	}
	else {
		RtlZeroMemory(pServiceBuffer,
			sizeof(BTH_LE_GATT_SERVICE) * serviceBufferCount);
	}

	////////////////////////////////////////////////////////////////////////////
	// Retrieve Services
	////////////////////////////////////////////////////////////////////////////
	USHORT numServices;
	hr = BluetoothGATTGetServices(hLEDevice, serviceBufferCount,
		pServiceBuffer, &numServices, BLUETOOTH_GATT_FLAG_NONE);

	if (S_OK != hr) {
		printf("BluetoothGATTGetServices - Buffer Size %d", hr);
	}


	////////////////////////////////////////////////////////////////////////////
	// Determine Characteristic Buffer Size
	////////////////////////////////////////////////////////////////////////////
	USHORT charBufferSize;
	hr = BluetoothGATTGetCharacteristics(hLEDevice, pServiceBuffer, 0,
		NULL, &charBufferSize, BLUETOOTH_GATT_FLAG_NONE);

	if (HRESULT_FROM_WIN32(ERROR_MORE_DATA) != hr) {
		printf("BluetoothGATTGetCharacteristics - Buffer Size %d", hr);
	}

	PBTH_LE_GATT_CHARACTERISTIC pCharBuffer = NULL;
	if (charBufferSize > 0) {
		pCharBuffer = (PBTH_LE_GATT_CHARACTERISTIC)
			malloc(charBufferSize * sizeof(BTH_LE_GATT_CHARACTERISTIC));

		if (NULL == pCharBuffer) {
			printf("pCharBuffer out of memory\r\n");
		}
		else {
			RtlZeroMemory(pCharBuffer,
				charBufferSize * sizeof(BTH_LE_GATT_CHARACTERISTIC));
		}

		////////////////////////////////////////////////////////////////////////////
		// Retrieve Characteristics
		////////////////////////////////////////////////////////////////////////////
		USHORT numChars;
		hr = BluetoothGATTGetCharacteristics(hLEDevice, pServiceBuffer,
			charBufferSize, pCharBuffer, &numChars, BLUETOOTH_GATT_FLAG_NONE);

		if (S_OK != hr) {
			printf("BluetoothGATTGetCharacteristics - Actual Data %d", hr);
		}

		if (numChars != charBufferSize) {
			printf("buffer size and buffer size actual size mismatch\r\n");
		}
	}


	PBTH_LE_GATT_CHARACTERISTIC currGattChar;
	for (int ii = 0; ii <charBufferSize; ii++) {
		currGattChar = &pCharBuffer[ii];
		USHORT charValueDataSize;
		PBTH_LE_GATT_CHARACTERISTIC_VALUE pCharValueBuffer;

		///////////////////////////////////////////////////////////////////////////
		// Determine Descriptor Buffer Size
		////////////////////////////////////////////////////////////////////////////
		USHORT descriptorBufferSize;
		hr = BluetoothGATTGetDescriptors(hLEDevice, currGattChar, 0,
			NULL, &descriptorBufferSize, BLUETOOTH_GATT_FLAG_NONE);

		if (HRESULT_FROM_WIN32(ERROR_MORE_DATA) != hr) {
			printf("BluetoothGATTGetDescriptors - Buffer Size %d", hr);
		}

		PBTH_LE_GATT_DESCRIPTOR pDescriptorBuffer;
		if (descriptorBufferSize > 0) {
			pDescriptorBuffer = (PBTH_LE_GATT_DESCRIPTOR)
				malloc(descriptorBufferSize * sizeof(BTH_LE_GATT_DESCRIPTOR));

			if (NULL == pDescriptorBuffer) {
				printf("pDescriptorBuffer out of memory\r\n");
			}
			else {
				RtlZeroMemory(pDescriptorBuffer, descriptorBufferSize);
			}

			////////////////////////////////////////////////////////////////////////////
			// Retrieve Descriptors
			////////////////////////////////////////////////////////////////////////////

			USHORT numDescriptors;
			hr = BluetoothGATTGetDescriptors(hLEDevice, currGattChar,
				descriptorBufferSize, pDescriptorBuffer, &numDescriptors,
				BLUETOOTH_GATT_FLAG_NONE);

			if (S_OK != hr) {
				printf("BluetoothGATTGetDescriptors - Actual Data %d", hr);
			}

			if (numDescriptors != descriptorBufferSize) {
				printf("buffer size and buffer size actual size mismatch\r\n");
			}

			for (int kk = 0; kk<numDescriptors; kk++) {
				PBTH_LE_GATT_DESCRIPTOR  currGattDescriptor = &pDescriptorBuffer[kk];
				////////////////////////////////////////////////////////////////////////////
				// Determine Descriptor Value Buffer Size
				////////////////////////////////////////////////////////////////////////////
				USHORT descValueDataSize;
				hr = BluetoothGATTGetDescriptorValue(hLEDevice, currGattDescriptor, 0,
					NULL, &descValueDataSize, BLUETOOTH_GATT_FLAG_NONE);

				if (HRESULT_FROM_WIN32(ERROR_MORE_DATA) != hr) {
					printf("BluetoothGATTGetDescriptorValue - Buffer Size %d", hr);
				}

				PBTH_LE_GATT_DESCRIPTOR_VALUE pDescValueBuffer =
					(PBTH_LE_GATT_DESCRIPTOR_VALUE)malloc(descValueDataSize);

				if (NULL == pDescValueBuffer) {
					printf("pDescValueBuffer out of memory\r\n");
				}
				else {
					RtlZeroMemory(pDescValueBuffer, descValueDataSize);
				}

				////////////////////////////////////////////////////////////////////////////
				// Retrieve the Descriptor Value
				////////////////////////////////////////////////////////////////////////////
				hr = BluetoothGATTGetDescriptorValue(hLEDevice, currGattDescriptor,
					(ULONG)descValueDataSize, pDescValueBuffer, NULL,
					BLUETOOTH_GATT_FLAG_NONE);
				if (S_OK != hr) {
					printf("BluetoothGATTGetDescriptorValue - Actual Data %d", hr);
				}
				//you may also get a descriptor that is read (and not notify) andi am guessing the attribute handle is out of limits
				// we set all descriptors that are notifiable to notify us via IsSubstcibeToNotification
				if (currGattDescriptor->AttributeHandle < 255) {
					BTH_LE_GATT_DESCRIPTOR_VALUE newValue;

					RtlZeroMemory(&newValue, sizeof(newValue));

					newValue.DescriptorType = ClientCharacteristicConfiguration;
					newValue.ClientCharacteristicConfiguration.IsSubscribeToNotification = TRUE;

					hr = BluetoothGATTSetDescriptorValue(hLEDevice, currGattDescriptor,
						&newValue, BLUETOOTH_GATT_FLAG_NONE);
					if (S_OK != hr) {
						printf("BluetoothGATTGetDescriptorValue - Actual Data %d", hr);
					}
					else {
						printf("setting notification for serivice handle %d\n",
							currGattDescriptor->ServiceHandle);
					}

				}

			}
		}


		//set the appropriate callback function when the descriptor change value
		//BLUETOOTH_GATT_EVENT_HANDLE bleEventHandle;
		if (currGattChar->IsNotifiable) {
			printf("Setting Notification for ServiceHandle %d\n", currGattChar->ServiceHandle);
			BTH_LE_GATT_EVENT_TYPE EventType = CharacteristicValueChangedEvent;
			//PFNBLUETOOTH_GATT_EVENT_CALLBACK cbFunction = (PFNBLUETOOTH_GATT_EVENT_CALLBACK)receiveBleValues;
			BLUETOOTH_GATT_VALUE_CHANGED_EVENT_REGISTRATION EventParameterIn;
			EventParameterIn.Characteristics[0] = *currGattChar;
			EventParameterIn.NumCharacteristics = 1;
			hr = BluetoothGATTRegisterEvent(hLEDevice, EventType, &EventParameterIn,
				(PFNBLUETOOTH_GATT_EVENT_CALLBACK)getNotification, NULL,
				&bleEventHandle, BLUETOOTH_GATT_FLAG_NONE);

			if (S_OK != hr) {
				printf("BluetoothGATTRegisterEvent - Actual Data %d", hr);
			}
		}

		//if (currGattChar->IsIndicatable) {
		//	printf("Setting Indication for ServiceHandle %d\n", 
		//		currGattChar->ServiceHandle);
		//	BTH_LE_GATT_EVENT_TYPE EventType = CharacteristicValueChangedEvent;

		//	BLUETOOTH_GATT_VALUE_CHANGED_EVENT_REGISTRATION EventParameterIn;
		//	EventParameterIn.Characteristics[0] = *currGattChar;
		//	EventParameterIn.NumCharacteristics = 1;
		//	hr = BluetoothGATTRegisterEvent(hLEDevice, EventType, &EventParameterIn, 
		//		(PFNBLUETOOTH_GATT_EVENT_CALLBACK)receiveBleValues, NULL, 
		//		&bleEventHandle, BLUETOOTH_GATT_FLAG_NONE);

		//	if (S_OK != hr) {
		//		printf("BluetoothGATTRegisterEvent - Actual Data %d", hr);
		//	}
		//}

		if (currGattChar->IsReadable) {//currGattChar->IsReadable
									   ////////////////////////////////////////////////////////////////////////////
									   // Determine Characteristic Value Buffer Size   
									   ////////////////////////////////////////////////////////////////////////////
			hr = BluetoothGATTGetCharacteristicValue(hLEDevice, currGattChar, 0,
				NULL, &charValueDataSize, BLUETOOTH_GATT_FLAG_NONE);

			if (HRESULT_FROM_WIN32(ERROR_MORE_DATA) != hr) {
				printf("BluetoothGATTGetCharacteristicValue - Buffer Size %d", hr);
			}

			pCharValueBuffer = (PBTH_LE_GATT_CHARACTERISTIC_VALUE)
				malloc(charValueDataSize);

			if (NULL == pCharValueBuffer) {
				printf("pCharValueBuffer out of memory\r\n");
			}
			else {
				RtlZeroMemory(pCharValueBuffer, charValueDataSize);
			}

			////////////////////////////////////////////////////////////////////////////
			// Retrieve the Characteristic Value
			////////////////////////////////////////////////////////////////////////////
			hr = BluetoothGATTGetCharacteristicValue(hLEDevice, currGattChar,
				(ULONG)charValueDataSize, pCharValueBuffer, NULL,
				BLUETOOTH_GATT_FLAG_NONE);

			if (S_OK != hr) {
				printf("BluetoothGATTGetCharacteristicValue - Actual Data %d", hr);
			}

			//print the characeteristic Value
			//for an HR monitor this might be the body sensor location
			printf("\n Printing a read (not notifiable) characterstic (maybe) body sensor value");
			for (int iii = 0; iii< pCharValueBuffer->DataSize; iii++) {
				// ideally check ->DataSize before printing
				printf("%d", pCharValueBuffer->Data[iii]);
			}
			printf("\n");


			// Free before going to next iteration, or memory leak.
			free(pCharValueBuffer);
			pCharValueBuffer = NULL;
		}
	}
	return true;
}


//--------------------------------------------------------------
HANDLE threadedBleReceiver::GetBLEHandle(GUID AGuid) {
	HDEVINFO hDI;
	SP_DEVICE_INTERFACE_DATA did;
	SP_DEVINFO_DATA dd;
	GUID BluetoothInterfaceGUID = AGuid;
	HANDLE hComm = NULL;

	hDI = SetupDiGetClassDevs(&BluetoothInterfaceGUID, NULL, NULL, DIGCF_DEVICEINTERFACE | DIGCF_PRESENT);

	if (hDI == INVALID_HANDLE_VALUE) return NULL;

	did.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);
	dd.cbSize = sizeof(SP_DEVINFO_DATA);

	for (DWORD i = 0; SetupDiEnumDeviceInterfaces(hDI, NULL, &BluetoothInterfaceGUID, i, &did); i++)
	{
		SP_DEVICE_INTERFACE_DETAIL_DATA DeviceInterfaceDetailData;

		DeviceInterfaceDetailData.cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);

		DWORD size = 0;

		if (!SetupDiGetDeviceInterfaceDetail(hDI, &did, NULL, 0, &size, 0))
		{
			int err = GetLastError();

			if (err == ERROR_NO_MORE_ITEMS) break;

			PSP_DEVICE_INTERFACE_DETAIL_DATA pInterfaceDetailData = (PSP_DEVICE_INTERFACE_DETAIL_DATA)GlobalAlloc(GPTR, size);

			pInterfaceDetailData->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);

			if (!SetupDiGetDeviceInterfaceDetail(hDI, &did, pInterfaceDetailData, size, &size, &dd))
				break;

			hComm = CreateFile(
				pInterfaceDetailData->DevicePath,
				GENERIC_WRITE | GENERIC_READ,
				FILE_SHARE_READ | FILE_SHARE_WRITE,
				NULL,
				OPEN_EXISTING,
				0,
				NULL);

			GlobalFree(pInterfaceDetailData);
		}
	}

	SetupDiDestroyDeviceInfoList(hDI);
	return hComm;
}


//--------------------------------------------------------------
bool threadedBleReceiver::closeDevice()
{
	HRESULT hr = BluetoothGATTUnregisterEvent(bleEventHandle, BLUETOOTH_GATT_FLAG_NONE);
	return true;
}


//--------------------------------------------------------------
void threadedBleReceiver::start()
{
	startThread(true);
	if (appDebug) printf("[threaderBleReceiver] starting BLE receiver thread...\n");
}

//--------------------------------------------------------------
void threadedBleReceiver::stop()
{
	if (appDebug) printf("[threadedBleReceiver::stop] stopping thread...\n");
	stopThread();
}

//--------------------------------------------------------------
void threadedBleReceiver::threadedFunction()
{

}

//--------------------------------------------------------------
int threadedBleReceiver::parseInput()
{
	return 0;
}


//--------------------------------------------------------------
//void threadedBleReceiver::getNotification(BTH_LE_GATT_EVENT_TYPE EventType, PVOID EventOutParameter, PVOID Context)
void threadedBleReceiver::getNotification(BTH_LE_GATT_EVENT_TYPE EventType, PVOID EventOutParameter, PVOID Context, threadedBleReceiver *val)
{
	//printf("Receiving notification\n");
	PBLUETOOTH_GATT_VALUE_CHANGED_EVENT ValueChangedEventParameters = (PBLUETOOTH_GATT_VALUE_CHANGED_EVENT)EventOutParameter;

	threadedBleReceiver *tempThread = new(threadedBleReceiver);

	HRESULT hr;
	uint8_t CharSize = ValueChangedEventParameters->CharacteristicValue->DataSize;
	if (0 == CharSize) {
		hr = E_FAIL;
		if(appDebug) printf("[bleHid::receiveBleValue] Warning: datasize 0\n");
	}
	else if (SMSS_BUTTON_CHAR_SIZE == CharSize) {
		uint8_t b1 = ValueChangedEventParameters->CharacteristicValue->Data[0];
		uint8_t b2 = ValueChangedEventParameters->CharacteristicValue->Data[1];
		if(appDebug) printf("[bleHid::receiveBleValues] Button:\t%#x %#x\n", b1, b2);

		//tempThread->sensVal.button[0] = b1;
		//tempThread->sensVal.button[1] = b2;
		//tempThread->newVal = true;
		val->sensVal.button[0] = b1;
		val->sensVal.button[1] = b2;
		val->newVal = true;
	}
	else if (SMSS_PRESS_CHAR_SIZE == CharSize) {
		int32_t press = 0;
		int32_t temp = 0;
		for (uint8_t i = 0; i < 4; i++) {
			press |= (ValueChangedEventParameters->CharacteristicValue->Data[i] << (8 * i));
			temp |= (ValueChangedEventParameters->CharacteristicValue->Data[i + 4] << (8 * i));
		}
		float press_f = (float)press / 100;
		float temp_f = (float)temp / 100;
		if(appDebug) printf("[bleHid::receiveBleValues] P @ T:\t%0.2f mbar @ %0.2f C\n", press_f, temp_f);

		tempThread->sensVal.pressure = press;
		tempThread->sensVal.temperature = temp;
		tempThread->newVal = true;
	}
	else if (SMSS_IMU_CHAR_SIZE == CharSize) {
		union threadedBleReceiver::f2b quat[4] = { 0 };
		for (uint8_t i = 0; i < 4; i++) {
			quat[0].b[i] = ValueChangedEventParameters->CharacteristicValue->Data[i];
			quat[1].b[i] = ValueChangedEventParameters->CharacteristicValue->Data[i + 4];
			quat[2].b[i] = ValueChangedEventParameters->CharacteristicValue->Data[i + 8];
			quat[3].b[i] = ValueChangedEventParameters->CharacteristicValue->Data[i + 12];
		}
		if(appDebug) printf("[bleHid::receiveBleValues] quat:\t%0.2f %0.2f %0.2f %0.2f\n", quat[0].val, quat[1].val, quat[2].val, quat[3].val);

		tempThread->sensVal.quaternions[0] = quat[0];
		tempThread->sensVal.quaternions[1] = quat[1];
		tempThread->sensVal.quaternions[2] = quat[2];
		tempThread->sensVal.quaternions[3] = quat[3];
		tempThread->newVal = true;
	}
	else {
		printf("size %d,\t", ValueChangedEventParameters->CharacteristicValue->DataSize);
		for (int i = 0; i<ValueChangedEventParameters->CharacteristicValue->DataSize; i++) {
			printf("%0x", ValueChangedEventParameters->CharacteristicValue->Data[i]);
		}
		printf("\n");
	}

	delete(tempThread);
}
