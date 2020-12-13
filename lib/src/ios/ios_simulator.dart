import 'package:meta/meta.dart';
import 'package:virtual_device/src/ios/simctl_cli.dart';

import 'package:virtual_device/src/virtual_device.dart';
import 'package:virtual_device/virtual_device.dart';

class IosSimulator extends VirtualDevice {
  @override
  final String model;

  @override
  final String name;

  @override
  final OperatingSystem os;

  @override
  final String osVersion;

  final String status;

  @override
  String uuid;

  IosSimulator({
    @required this.model,
    this.name,
    @required this.osVersion,
    @required this.os,
    this.status,
    this.uuid,
  });

  @override
  Future<void> create() async {
    final deviceTypes = await SimctlCli.instance.availableDeviceTypes();
    final deviceType = deviceTypes[model];
    if (deviceType == null) {
      throw StateError(
          '$model is not available in ${deviceTypes.keys.join(", ")}');
    }

    final runtimes = await SimctlCli.instance.availableRuntimes();
    final runtimeKey = runtimes.keys.firstWhere(
        (k) => k.startsWith('${os.toString().split(".").last} $osVersion'),
        orElse: () => throw StateError(
            '$osVersion is not available from ${runtimes.keys.join(", ")}'));
    final runtime = runtimes[runtimeKey];
    final deviceName = name ??
        (await SimctlCli.instance
            .generateName(model: model, osVersion: osVersion));
    uuid = await VirtualDevice.runWithError(
        'xcrun', ['simctl', 'create', deviceName, deviceType, runtime]);
  }

  @override
  Future<void> createOrStart() async {
    if (uuid != null) {
      return await VirtualDevice.runWithError(
          'xcrun', ['simctl', 'boot', uuid]);
    }

    final devices = await availableDevices();
    final device = devices.firstWhere(
        (d) =>
            d.os == os &&
            d.osVersion == osVersion &&
            d.status == 'Shutdown' &&
            d.model == model,
        orElse: () => null);
    if (device != null) {
      return await device.start();
    }

    await create();
    await start();
  }

  @override
  Future<void> delete() =>
      VirtualDevice.runWithError('xcrun', ['simctl', 'delete', uuid]);

  @override
  Future<void> start() =>
      VirtualDevice.runWithError('xcrun', ['simctl', 'boot', uuid]);

  @override
  Future<void> stop() =>
      VirtualDevice.runWithError('xcrun', ['simctl', 'shutdown', uuid]);

  @override
  Future<void> wipe() =>
      VirtualDevice.runWithError('xcrun', ['simctl', 'erase', uuid]);

  /// Created and available simulators
  static Future<List<IosSimulator>> availableDevices() async {
    final rawDevices = await SimctlCli.instance.availableDevices();
    return rawDevices
        .map((device) {
          return IosSimulator(
            model: device['model'],
            name: device['name'],
            os: device['os'],
            osVersion: device['osVersion'],
            status: device['status'],
            uuid: device['uuid'],
          );
        })
        .toList()
        .cast<IosSimulator>();
  }

  /// Segment available devices by `humanizedDeviceName: deviceTypeId`. See [SimctlCli#availableDeviceTypes]
  static Future<Map<String, String>> availableDeviceTypes() =>
      SimctlCli.instance.availableDeviceTypes();

  /// Segment available OS versions by `verionNumber: runtimeId`. See [SimctlCli#availableRuntimes]
  static Future<Map<String, String>> availableRuntimes() =>
      SimctlCli.instance.availableRuntimes();

  static Future<void> stopAll() =>
      VirtualDevice.runWithError('xcrun', ['simctl', 'shutdown', 'all']);

  /// Wipe data from all simulators
  static Future<void> wipeAll() =>
      VirtualDevice.runWithError('xcrun', ['simctl', 'erase', 'all']);
}
