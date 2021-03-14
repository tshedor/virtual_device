import 'package:virtual_device/src/ios/simctl_cli.dart';

import 'package:virtual_device/src/virtual_device.dart';
import 'package:virtual_device/src/virtual_device_utils.dart';
import 'package:virtual_device/virtual_device.dart';

class IosSimulator extends VirtualDevice {
  @override
  final String? model;

  @override
  final String? name;

  @override
  final OperatingSystem os;

  @override
  final String osVersion;

  final String? status;

  /// A unique identifier used to communicate with the platform.
  /// This is the `udid` (simctl CLI) or `identifier` (Xcode GUI).
  @override
  String? uuid;

  IosSimulator({
    this.model,
    this.name,
    required this.osVersion,
    required this.os,
    this.status,
    this.uuid,
  });

  @override
  Future<void> create() async {
    final deviceTypes = await SimctlCli.instance.availableDeviceTypes();
    final deviceType = deviceTypes[model];
    if (deviceType == null) {
      throw StateError('$model is not available in ${deviceTypes.keys.join(", ")}');
    }

    final runtimes = await SimctlCli.instance.availableRuntimes();
    final runtimesForOs = runtimes[os.toString().split('.').last];
    if (runtimesForOs?.isEmpty ?? true) {
      throw StateError('No runtimes available for $osVersion');
    }

    final runtimeKey = runtimesForOs!.keys.firstWhere((e) => e == osVersion,
        orElse: () =>
            throw StateError('$osVersion is not available from ${runtimesForOs.keys.join(", ")}'));
    final runtime = runtimesForOs[runtimeKey]!;
    final deviceName =
        name ?? (await SimctlCli.instance.generateName(model: model!, osVersion: osVersion));

    final createdOutput =
        await runWithError('xcrun', ['simctl', 'create', deviceName, deviceType, runtime]);
    uuid = createdOutput.trim();
  }

  /// Start an existing simulator or create a new one
  ///
  /// [showAfterStart] - when `false`, the simulator is booted in the background
  /// and not rendered by the GUI. Defaults `true`.
  @override
  Future<void> createOrStart({bool showAfterStart = true}) async {
    if (uuid != null) {
      await runWithError('xcrun', ['simctl', 'boot', uuid!]);
      return;
    }

    final devices = await availableDevices();
    final device = firstWhereOrNull<IosSimulator>(
      devices,
      (d) => d.os == os && d.osVersion == osVersion && d.status == 'Shutdown' && d.model == model,
    );
    if (device != null) {
      uuid = device.uuid;
      await device.start();
    } else {
      await create();
      await start();
    }

    if (showAfterStart) {
      await runWithError('open', ['-a', 'Simulator', '--args', uuid!]);
    }
  }

  @override
  Future<void> delete() => runWithError('xcrun', ['simctl', 'delete', uuid!]);

  @override
  Future<void> start() => runWithError('xcrun', ['simctl', 'boot', uuid!]);

  @override
  Future<void> stop() => runWithError('xcrun', ['simctl', 'shutdown', uuid!]);

  @override
  Future<void> wipe() => runWithError('xcrun', ['simctl', 'erase', uuid!]);

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

  /// Segment available OS versions by `os: { verionNumber: runtimeId }`. See [SimctlCli#availableRuntimes]
  static Future<Map<String, Map<String, String>>> availableRuntimes() =>
      SimctlCli.instance.availableRuntimes();

  static Future<void> stopAll() => runWithError('xcrun', ['simctl', 'shutdown', 'all']);

  /// Wipe data from all simulators
  static Future<void> wipeAll() => runWithError('xcrun', ['simctl', 'erase', 'all']);
}
