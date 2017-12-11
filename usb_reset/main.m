//
//  main.m
//  usb_reset
//
//  Created by Julien Faucher on 16-01-02.
//  Copyright © 2016-2017 Julien Faucher. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#include <IOKit/usb/USBSpec.h>

int main(int argc, const char * argv[]) {
    CFMutableDictionaryRef matchingDictionary = NULL;
    io_iterator_t iterator = 0;
    io_service_t usbRef;
    SInt32 score;
    IOCFPlugInInterface** plugin;
    IOUSBDeviceInterface300** usbDevice = NULL;
    IOReturn ret;
    
    //Gather input and convert text to hex
    SInt32 idVendor;
    SInt32 idProduct;

    //Values will be nil (and false) if there was no arg. If both contain something
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"v"] && [[NSUserDefaults standardUserDefaults] stringForKey:@"p"]) {
      //Convert hex string to int
      NSScanner* scanner;
      scanner = [NSScanner scannerWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"v"]];
      [scanner scanHexInt:&idVendor];
      scanner = [NSScanner scannerWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"p"]];
      [scanner scanHexInt:&idProduct];
        
      matchingDictionary = IOServiceMatching(kIOUSBDeviceClassName);
      CFDictionaryAddValue(matchingDictionary,
                           CFSTR(kUSBVendorID),
                           CFNumberCreate(kCFAllocatorDefault,
                                          kCFNumberSInt32Type, &idVendor));
      CFDictionaryAddValue(matchingDictionary,
                           CFSTR(kUSBProductID),
                           CFNumberCreate(kCFAllocatorDefault,
                                          kCFNumberSInt32Type, &idProduct));
      IOServiceGetMatchingServices(kIOMasterPortDefault,
                                   matchingDictionary, &iterator);
      usbRef = IOIteratorNext(iterator);
      if (usbRef == 0)
      {
        printf("Device not found\nPlease make sure the provided hex values are accurate.\n");
        return -1;
      } else {
        printf("Found device, attempting reset\n");
      }
      IOObjectRelease(iterator);
      IOCreatePlugInInterfaceForService(usbRef, kIOUSBDeviceUserClientTypeID,
                                        kIOCFPlugInInterfaceID, &plugin, &score);
      IOObjectRelease(usbRef);
      (*plugin)->QueryInterface(plugin,
                                CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID300),
                                (LPVOID)&usbDevice);
      (*plugin)->Release(plugin);
    
      (*usbDevice)->USBDeviceOpen(usbDevice);
        ret = (*usbDevice)->USBDeviceSuspend(usbDevice,TRUE);
      (*usbDevice)->USBDeviceClose(usbDevice);
      if (ret == kIOReturnSuccess) {
        printf("Successfully reset USB device\n");
      } else {
        printf("USB device was not reset successfully\n");
      }
    }
    //Otherwise, usage info
    else {
        NSLog(@"\n©Julien Faucher 2016-2017\nUtility that simulates a plug/unplug sequence for a USB device\nWill reset the USB device with the provided values of device vendor id and product id\nThose two flags are required. Any other flag or action will return this message\n\
Usage :\n\
  -v Device vendor id (ex: 0x046d)\n\
  -p Device product id (ex: 0x0825)\n\nPlease report issues at http://github.com/jufaua/usb_reset");
    }
    
    return 0;
}
