import 'package:virtual_device/virtual_device.dart';

void main() async {
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
}
