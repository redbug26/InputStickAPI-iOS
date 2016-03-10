# InputStickAPI for iOS

## About InputStick:
InputStick is an Android and iOS compatible USB receiver. It allows to use your smartphone as a wireless keyboard, mouse, multimedia and game controller. 

[![iOS API demo video](http://img.youtube.com/vi/GxqTSWtliRA/0.jpg)](http://www.youtube.com/watch?v=GxqTSWtliRA)

##How does it work?
InputStick acts as a proxy between USB host and iOS/Android device:
* USB host detects is as a generic HID device. It knows nothing about Bluetooth interface. As a result, in most cases, there is no need to install any drivers or configure anything.
* Android device knows only about Bluetooth interface. Everything works with stock OS: root is NOT required, there is also no need to install customized OS.

`iOS/Android device <-(Bluetooth)-> InputStick <-(USB)-> PC`

![alt text](http://inputstick.com/images/how_2.png "How does it work diagram")

InputStick is detected as a generic keyboard and mouse (USB HID), it makes it compatible with wide range of hardware:
* PC (Windows, Linux, OS X),
* embedded systems (RaspberryPi etc.),
* consoles (PS3, Xbox360, only as keyboard, NOT game controller!),
* any USB-HID compatible USB host.

Remember: InputStick behaves EXACTLY as a USB keyboard and mouse - nothing more and nothing less. It is not able to put text directly into system clipboard etc.

## More info:
[Visit inputstick.com](http://inputstick.com)

[Download section](http://inputstick.com/download)

## Project Setup

- Clone repository: `git clone git@github.com:InputStick/InputStickAPI-ios.git`

## Getting started:

### ISManager:
To start using the Input Stick you have to first create an instance of ISManager.
You also need to specify a delegate which implements protocol: `ISManagerDelegate`.

Create and setup an ISManager:

```
self.inputStickManager = [[ISManager alloc] init];
self.inputStickManager.delegate = self;
```

Establish a connection using:

```
- (void)connectToInputStickUsingStoredIdentifier:(BOOL)useStoredIdentifier;
```
 
You can monitor the device connection status by checking the `inputStickState` property of ISManager or register for connection notifications described later.
During the connection process the API uses a selection view controller (to select a proper BlueTooth device), which has to be presented using delegate method:

```
- (void)inputStickManager:(ISManager *)inputStickManager presentViewController:(UIViewController *)deviceSelectionViewController;
```

In order to use custom view controller you can implement:

```
- (UIViewController <ISDeviceSelectionViewControllerProtocol> *)selectionViewControllerForConnectionManager:(ISConnectionManager *)connectionManager withInputStickManager:(ISManager *)inputStickManager;
```

### HID Handlers
Normally all communication with an Input Stick device is done via device handlers (Keyboard, Mouse, Consumer or Gamepad).
Depending on the type of data, packages will be send in queues (keyboard, mouse, consumer) or all at once (gamepad).

A handler should be created using the default init method, i.e.:

```
- (instancetype)initWithInputStickManager:(ISManager *)manager;
```

#### Keyboard:
To write text use one of the methods:

```
- (void)sendText:(NSString *)text;
- (void)sendText:(NSString *)text withKeyboardLayout:(id <ISKeyboardLayoutProtocol>)keyboardLayout;
- (void)sendText:(NSString *)text withKeyboardLayout:(id <ISKeyboardLayoutProtocol>)keyboardLayout multiplier:(NSInteger)multiplier;
```

#### Mouse:

```
- (void)sendMoveToX:(SignedByte)x y:(SignedByte)y;
- (void)sendScroll:(SignedByte)scrollValue;
- (void)sendPressedButtons:(Byte)buttons numberOfPress:(NSInteger)numberOfPresses multiplier:(NSInteger)multiplier;
```

#### Consumer:

```
- (void)consumerActionWithUsage:(ISConsumerActions)usage;
- (void)systemActionWithUsage:(ISSystemActions)usage;
```

Definitions of consumer and system actions are available in `ISConsumerHandler.h`

#### Gamepad:
You can update the state of the gamepad using:

```
- (void)sendCustomReportWithButtons:(GamepadButtons)buttons axisX:(SignedByte)x axisY:(SignedByte)y axisZ:(SignedByte)z axisRX:(SignedByte)rx;
```

### Notifications
API offers basic notifications about the device connection and status updates.

Connection Status:
* ISWillStartConnectingPeripheralNotificationName
* ISDidFinishConnectingPeripheralNotificationName
* ISDidFinishConnectingInputStickNotificationName
* ISDidDisconnectInputStickNotificationName;

InputStick device status:
* ISDidUpdateDeviceBuffersNotificationName
* ISDidUpdateKeyboardLedsNotificationName

You can either register for specific notifications or use registration methods defined in categories of NSNotificationCenter:

* NSNotificationCenter+Connection.h

```
- (void)registerForConnectionNotificationsWithObserver:(id <ConnectionNotificationObserver>)observer;
```

* NSNotificationCenter+DeviceStatus.h

```
- (void)registerForDeviceStatusNotificationsWithObserver:(id <ResponseParsingNotificationObserver>)observer;
```

In both cases there are corresponding `unregister` methods. 

## Keyboard layouts:
Always make sure that selected layout matches layout used by USB host (PC). Due to limitations of USB-HID it is not possible for InputStick to know what layout is use by the USB host. This must be manually provided by the user.
List of currently available keyboard layouts:
* da-DK 			- Danish (Denmark),
* de-CH 			- German (Switzerland),
* de-DE 			- German (Germany),
* de-DE (MAC) 	- German (Germany), Mac compatible version,
* en-DV 			- English (United States), Dvorak layout,
* en-GB 			- English (United Kingdom),
* en-US 			- English (United States),
* es-ES 			- Spanish (Spain),
* fi-FI 			- Finnish (Finland),
* fr-CH 			- French (Switzerland),
* fr-FR 			- French (France),
* he-IL 			- Hebrew (Israel),
* it-IT 			- Italian (Italy),
* nb-NO 			- Norwegian, Bokmal (Norway),
* pl-PL 			- Polish (Poland),
* pt-BR 			- Portuguese (Brazil),
* ru-RU 			- Russian (Russia),
* sk-SK 			- Slovak (Slovakia),
* sv-SE 			- Swedish (Sweden).

## Requirements (BT4.0 version):
* InputStick BT4.0 receiver,
* iPhone 4S or newer, Android 4.3 or later, 
* Bluetooth 4.0 (Bluetooth Low Energy),

Note: Bluetooth 2.1 version is NOT supported by iOS devices.

## Technical limitations and things to consider:

USB device - InputStick
USB host - PC, game consoles, Raspberry Pi, etc.
HID - Human Interface Device (keyboard, mouse, gamepad, etc.)

InputStick communicates with USB host by sending HID reports for each interface (keyboard, mouse, consumer control).
HID report - data representing state or change of state of HID interface.

[Learn more: USB HID1.11 pdf](www.usb.org/developers/hidpage/HID1_11.pdf)


**Compatibility:**

USB host detects InputStick as a generic keyboard, mouse and consumer control composite device. It sees NO difference between physical keyboard/mouse and InputStick. Host does not know anything about Bluetooth interface.
In most cases, generic drivers for HID devices are used, there is no need to install any additional software or drivers.
If your USB host works with generic USB keyboard, it will most likely also work with InputStick. If necessary, you can make some adjustments to USB interface using InputStickUtility app (requires some knowledge about USB interface).


**NO feedback:**

In case of HID class devices, USB host does NOT provide any information about itself to USB device:
* type of hardware is unknown,
* OS is unknown,
* keyboard layout used by OS is unknown,
* there is no feedback whether characters were typed correctly.

Think of InputStick as of a blind person with en-US keyboard:
* you provide instructions, example: type "abC"
* InputStick executes the instruction by simulating user actions: press "A" key, release, press "B" key, release, press and hold "Shift" key, press "C" key, release all keys.
* InputStick has no way of knowing if these actions produced correct result

You (app user) must provide all necessary information and feedback!


**Typing speed:**

InputStick can type text way faster than any human. In some cases this can result in missing characters. Use slower typing speed when necessary (duplicate HID reports).
Example: when PC is experiencing have CPU load, it is possible that in sometimes characters will be skipped (same thing will happen when using regular USB keyboard).


**Consumer control interface.**

Multimedia keys: allows to control media playback, system volume, launch applications.
Unfortunately there are differences between OSes in how consumer control actions are interpreted.

Example 1: there are 100 volume levels in Windows OS and 10 levels on Ubuntu. Increasing system volume by 1 will have different effect on each of them.

Example 2: when audio output is muted, increasing system volume by 1 can have different effects: Windows - volume level is increased by 1, but audio output will remain muted. Linux - volume level is uncreased by 1, audio output is unmuted.


**Bluetooth:**

Time required to establish connection:
* BT2.1 - usually 1-3 seconds,
* BT4.0 - usually less than a second.

Latency:
Bluetooth introduces additional latency (several ms in most cases, in some conditions can increase to several hundreds).

Range:
Walls and other obstacles will decrease performance of Bluetooth link. BT4.0 devices are generally more sensitive to this (due to Low Energy approach).
