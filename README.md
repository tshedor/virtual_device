# Virtual Device

Manage/Create iOS simulators and Android emulators

## Setup

This package expects several commands to be in the shell:
* `xcrun` for iOS
* `adb`, `avdmanager`, and `emulator` for Android

Command Line Tools installs `xcrun`, but Android requires updating the PATH:

```shell
# your ANDROID_HOME may vary; this is usually the install path on Mac machines
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"
```

## Usage

```dart
import 'package:virtual_device/virtual_device.dart';

final simulators = await IosSimulator.availableDevices();
await simulators.first.start();

final newSimulator = IosSimulator(
  model: 'iPad Air 2',
  os: OperatingSystem.iOS,
  osVersion: '14.2',
);
final createdSimulator = await newSimulator.create();
await createdSimulator.start();

// shutdown
await createdSimulator.stop();

// clean
await createdSimulator.wipe();

// start again
await createdSimulator.start();
await createdSimulator.stop();

// destroy
await createdSimulator.delete();
```

### Command Line

Make the command globally available:

```shell
pub global activate virtual_device
```

And use it to create or run simulators:

```shell
virtual_device create -p ios -v 14.2 -m "iPad Air 2"
virtual_device start -p ios -n "iPad Air 2:14.2:1"
```

For a complete list of models and versions available on the machine, run `virtual_device list models` or `virtual_device list versions`.
