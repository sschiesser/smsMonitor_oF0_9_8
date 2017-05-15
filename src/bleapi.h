#ifndef BLEAPI_H__
#define BLEAPI_H__

#include <wchar.h>

#define BLE_API_EXPORT __declspec(dllexport)
#define BLE_API_CALL

#define BLE_API_EXPORT_CALL BLE_API_EXPORT BLE_API_CALL

#ifdef __cplusplus
extern "C" {
#endif
	struct ble_device_;
	typedef struct ble_device_ ble_device;

	struct ble_device_info {
		/** Platform-specific device path */
		char *path;
		/** Device Vendor ID */
		unsigned short vendor_id;
		/** Device Product ID */
		unsigned short product_id;
		/** Serial Number */
		wchar_t *serial_number;
		/** Device Release Number in binary-coded decimal,
		also known as Device Version Number */
		unsigned short release_number;
		/** Manufacturer String */
		wchar_t *manufacturer_string;
		/** Product string */
		wchar_t *product_string;
		/** Usage Page for this Device/Interface
		(Windows/Mac only). */
		unsigned short usage_page;
		/** Usage for this Device/Interface
		(Windows/Mac only).*/
		unsigned short usage;
		/** The USB interface which this logical device
		represents. Valid on both Linux implementations
		in all cases, and valid on the Windows implementation
		only if the device contains more than one interface. */
		int interface_number;

		/** Pointer to the next device */
		struct ble_device_info *next;
	};

	int BLE_API_EXPORT BLE_API_CALL ble_init(void);

	int BLE_API_EXPORT BLE_API_CALL ble_exit(void);

	struct ble_device_info BLE_API_EXPORT * BLE_API_CALL ble_enumerate(unsigned short vendor_id, unsigned short product_id);

	void BLE_API_EXPORT BLE_API_CALL ble_free_enumeration(struct ble_device_info *devs);

	BLE_API_EXPORT ble_device * BLE_API_CALL ble_open(unsigned short vendor_id, unsigned short product_id, const wchar_t *serial_number);

	BLE_API_EXPORT ble_device * BLE_API_CALL ble_open_path(const char *path);

	int  BLE_API_EXPORT BLE_API_CALL ble_write(ble_device *device, const unsigned char *data, size_t length);

	int BLE_API_EXPORT BLE_API_CALL ble_read_timeout(ble_device *dev, unsigned char *data, size_t length, int milliseconds);

	int BLE_API_EXPORT BLE_API_CALL ble_read(ble_device *device, unsigned char *data, size_t length);

	int BLE_API_EXPORT BLE_API_CALL ble_set_nonblocking(ble_device *device, int nonblock);

	int BLE_API_EXPORT BLE_API_CALL ble_send_feature_report(ble_device *device, const unsigned char *data, size_t length);

	int BLE_API_EXPORT BLE_API_CALL ble_get_feature_report(ble_device *device, unsigned char *data, size_t length);

	void BLE_API_EXPORT BLE_API_CALL ble_close(ble_device *device);

	int BLE_API_EXPORT_CALL ble_get_manufacturer_string(ble_device *device, wchar_t *string, size_t maxlen);

	int BLE_API_EXPORT_CALL ble_get_product_string(ble_device *device, wchar_t *string, size_t maxlen);

	int BLE_API_EXPORT_CALL ble_get_serial_number_string(ble_device *device, wchar_t *string, size_t maxlen);

	int BLE_API_EXPORT_CALL ble_get_indexed_string(ble_device *device, int string_index, wchar_t *string, size_t maxlen);

	BLE_API_EXPORT const wchar_t* BLE_API_CALL ble_error(ble_device *device);

#ifdef __cplusplus
}
#endif


#endif // BLEAPI_H__