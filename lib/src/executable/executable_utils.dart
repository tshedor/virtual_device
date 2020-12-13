import 'package:virtual_device/virtual_device.dart';

Future<VirtualDevice> deviceFromName({bool isIOS = true, String name}) async {
  List<VirtualDevice> devices;
  if (isIOS) {
    devices = await IosSimulator.availableDevices();
  } else {
    devices = await AndroidEmulator.availableDevices();
  }

  return devices.firstWhere(
    (d) => d.name == name,
    orElse: () => throw StateError('Device named $name not found'),
  );
}
