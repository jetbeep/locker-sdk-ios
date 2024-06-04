![Jetbeep Logo](assets/jetbeep-logo-v2-blue.svg)

# Jetbeep Locker SDK for iOS **v.1.0.2** {#_jetbeep_locker_sdk_for_ios_v_1_0_2}

## Introduction {#_introduction}

The Jetbeep Locker SDK for iOS provides developers with the tools to
integrate locker functionality into their iOS applications via bluettoth
communication. This document serves as a comprehensive guide to help
developers understand and utilize the features of the Locker SDK.

## History {#_history}

+-----------------+-----------------+-----------------+-----------------+
| Date            | Author          | Description     | Version         |
+=================+=================+=================+=================+
| 11/04/2024      | Max Tymchii     | Initial commit  | v.1.0.0         |
+-----------------+-----------------+-----------------+-----------------+
| 11/04/2024      | Max Tymchii     | Add logger      | v.1.0.1         |
+-----------------+-----------------+-----------------+-----------------+
| 29/04/2024      | Max Tymchii     | Method renames. | v.1.0.2         |
+-----------------+-----------------+-----------------+-----------------+

## Key Features {#_key_features}

-   Find devices nearby;

-   Connect to a locker device;

-   Retrieve the status of a locker;

-   Get device info.

-   Encrypted communication.

-   Open locker.

-   Disconnect from a locker device.

## System Requirements {#_system_requirements}

Current SDK version is compatible with iOS 13.0 and later.

## Integration Guide {#_integration_guide}

To integrate the Jetbeep Locker SDK into your iOS application, follow
these steps:

### Step 1: Add the SDK to Your Project {#_step_1_add_the_sdk_to_your_project}

Add the following line to your `Podfile`:

``` ruby
pod 'JetbeepLockerSDK'
```

Then, run `pod install` to install the SDK.

### Step 2: Import the SDK {#_step_2_import_the_sdk}

In your Swift file, import the SDK:

``` swift
import JetbeepLockerSDK
```

### Step 3: Initialize the SDK {#_step_3_initialize_the_sdk}

Initialize the SDK with the following code:

``` swift
let projectID = <your personal value provided by Jetbeep team for you>
let configuaration = try LockerSDKConfiguration()
                .addProjectId(projetcID)
                .build()

LockerSDK.shared = .instantiate(with: configuaration)
```

### Step 4: Bluetooth Permissions {#_step_4_bluetooth_permissions}

Add bluetooth permissions at your `Info.plist`:

``` xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>$(PRODUCT_NAME) uses Bluetooth to connect to lockers</string>
```

## API Reference {#_api_reference}

The Locker SDK provides the following classes and methods:

### LockerSDK {#_lockersdk}

After initializing the SDK, you can start working with `LockerFlow`.
First of all you need to create an instance of `LockerFlow` class:

``` swift
let lockerFlow = LockerFlow()
```

After that you can use the following methods:

-   `start` - starts the locker flow and find nearby devices.

``` swift
try lockerFlow.start()
```

-   `stop` - stops the locker flow.

``` swift
lockerFlow.stop()
```

-   `deviceStatusPublishers` - publisher that emits the status of the
    locker devices.

Available statuses:

-   `found` - when a new device is found.

-   `update` - when the status of the device is updated.

-   `lost` - when the device is lost.

``` swift
lockerFlow.deviceStatusPublishers.sink
    .receive(on: DispatchQueue.main)
    .sink { status in
        switch status {
        case .found(let device):
            print("Device found: \(device)")
        case .update(let device):
            print("Device updated: \(device)")
        case .lost(let device):
            print("Device lost: \(device)")
        }
    }
```

-   `nearbyDevices` - an `LockerDevice` array of nearby devices.

``` swift
flow.nearbyDevices
```

-   `connect` - connects to the locker device.

``` swift
try await lockerFlow.connect(to: lockerDevice)
```

-   `disconnect` - disconnects from the locker device.

``` swift
try await lockerFlow.disconnect(from: lockerDevice)
```

Available commands:

-   `enableEncryption` - enables encryption for the locker device
    communication.

``` swift
try await lockerFlow.enableEncryption()
```

-   `getDeviceInfoRequest` - fetch a device info request. There is an
    optional parameter `requestType` that can be used to specify the
    type of request. The default value is `.projectDeviceKey`.

Options that could be used as a parameter:

-   `.none` - empty request.

-   `.projectKey` - request with project key.

-   `.projectDeviceKey` - request with device key.

``` swift
try await lockerFlow.getDeviceInfoRequest(requestType: .projectDeviceKey)
```

-   `openLock` - sends an open lock request with a password.

``` swift
try await lockerFlow.openLock(with: password)
```

### Loggs {#_loggs}

The SDK provides a logger that can be used to log messages. The logger
is a singleton instance of the `Logger` class. It provides publisher tht
emits log events. Level of the log events can be set in the
configuration.

``` swift
logger.publisher.sink { event in
                print("Event \(event)")
            }.store(in: &cancelable)
```

### LockerSDKConfiguration {#_lockersdkconfiguration}

The `LockerSDKConfiguration` class is used to configure the SDK. It
provides the following methods:

-   `addProjectId` - sets the project ID.

``` swift
let configuaration = try LockerSDKConfiguration()
                .addProjectId(projetcID)
                .build()
```

-   `addEnvironment` - sets the environment. The default value is
    `.production`.

Options that could be used as a parameter:

-   `.production` - production environment.

-   `.development` - development environment.

``` swift
let configuaration = try LockerSDKConfiguration()
                .addEnvironment(.development)
                .build()
```

-   `addTimeUntilLoseDevice` - sets the timeout interval for device
    lost. The default value is 30 seconds.

``` swift
let configuaration = try LockerSDKConfiguration()
                .addTimeUntilLoseDevice(60)
                .build()
```

-   `addConnectionRetryCount` - sets the connection retry count. The
    default value is 3.

``` swift
let configuaration = try LockerSDKConfiguration()
                .addConnectionRetryCount(5)
                .build()
```

-   `addLogLevel` - sets the log level. The default value is `.info`.

Options that could be used as a parameter:

-   `.error` - only error logs.

-   `.warning` - error and warning logs.

-   `.info` - error, warning, and info logs.

-   `.debug` - error, warning, info, and debug logs.

-   `.verbose` - all logs.

Don't forget to call `build` method to get the configuration object.

### LockerDevice {#_lockerdevice}

The `LockerDevice` struct represents a locker device. It provides the
following properties:

-   `deviceId` - the device ID.

-   `projectId` - the project ID.

-   `userData` - the user data.

-   `isConnectable`- the connectable status.

### OpenLock {#_openlock}

The `OpenLock` struct represents an open lock response. It provides the
following properties:

-   `name` - the name of the locker.

-   `lockIndex` - the lock index.

-   `address` - the address of the locker.

## Conclusion {#_conclusion}

This document has provided a comprehensive guide to integrating the
Jetbeep Locker SDK into your iOS application. If you have any questions
or need further assistance, please contact us email at
<max.tymchii@jetbeep.com> or visit our website at <https://jetbeep.com>.
