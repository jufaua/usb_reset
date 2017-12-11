##usb_reset

A simple macOS command line utility to re-enumerate a USB device. Essentially, this utility will simulate unplugging and replugging of a USB device. This is (somewhat) useful in the case of USB devices that become unresponsive, essentially forcing the OS to reload a device's driver. Note that this may not work under every circumstances (I once had an issue with a keyboard where nothing short of physically unplugging and replugging the device would bring it back to life), but can fix a somewhat wide variety of small issue.

This software is provided as-is, and I cannot be held responsible for any damage, either to your software or hardware, that might happen following your usage. But I've used extensively to force-reload the drivers of various USB devices and never encountered any damage. But your milleage may vary.

###Install

Compile through XCode. Put it wherever makes sense for you (ideally, in your PATH, I guess).

###Usage

Usage is pretty straightforward. The program expects to receive the vendor ID as well as the product ID. The ids can be gathered from System Information in the USB tab, or whatever other way you can get those values.

```
usb_reset -v 0x0000 -p 0x0000
```