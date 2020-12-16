import 'package:virtual_device/virtual_device.dart';

void main() async {
  final simulators = await IosSimulator.availableDevices();
  await simulators.first.start();

  final newSimulator = IosSimulator(
    model: 'iPad Air 2',
    os: OperatingSystem.iOS,
    osVersion: '14.2',
  );
  await newSimulator.createOrStart();

  // shutdown
  await newSimulator.stop();

  // clean
  await newSimulator.wipe();

  // start again
  await newSimulator.start();
  await newSimulator.stop();

  // destroy
  await newSimulator.delete();
}
