import 'package:uuid/uuid.dart';
import 'package:virtual_device/src/android/avdmanager_cli.dart';
import 'package:virtual_device/src/virtual_device.dart';
import 'package:virtual_device/virtual_device.dart';

class AndroidEmulator extends VirtualDevice {
  /// Whether to build an image with Google APIs. Defaults `true`
  final bool googleApis;

  @override
  final String model;

  @override
  final String name;

  @override
  final os = OperatingSystem.android;

  @override
  final String osVersion;

  Future<String> get emulatorId async {
    final runningAdbEmulators =
        await VirtualDevice.runWithError('adb', ['devices']);
    final adbMatches = RegExp(r'^emulator-\d+', multiLine: true)
        .allMatches(runningAdbEmulators);
    if (adbMatches == null || adbMatches.isEmpty) return null;

    // inspired by https://stackoverflow.com/a/42038655
    final uuidAndEmulatorId = {};
    for (final match in adbMatches) {
      final emulatorId = match.group(0).trim();
      final adbUuid = await VirtualDevice.runWithError('adb', [
        '-s',
        emulatorId,
        'wait-for-device',
        'shell',
        'getprop',
        'emu.uuid'
      ]);
      uuidAndEmulatorId[adbUuid.trim()] = emulatorId;
    }

    return uuidAndEmulatorId[uuid];
  }

  @override
  final String uuid;

  AndroidEmulator({
    this.googleApis = true,
    this.model,
    this.name,
    this.osVersion,
    String uuid,
  }) : uuid = uuid ?? Uuid().v1();

  @override
  Future<void> create({bool verbose = false}) async {
    final availableVersions = await AvdmanagerCli.instance.availableRuntimes();
    final discoveredVersion = availableVersions.firstWhere(
      (v) => v['apiLevel'].toString() == osVersion,
      orElse: () => throw StateError(
          '$osVersion is not available in ${availableVersions.map((v) => v["apiLevel"]).join(", ")}'),
    );

    if (discoveredVersion['googleApis'] != googleApis) {
      throw StateError(
          '$osVersion does not have a compatible Google APIs ($googleApis) image');
    }

    final imageName = ['system-images' 'android-$osVersion'];
    if (googleApis) imageName.add('google_apis');
    imageName.add('x86');

    final deviceName = name ??
        (await AvdmanagerCli.instance
            .generateName(model: model, osVersion: osVersion));

    await VirtualDevice.runWithError('avdmanager', [
      if (verbose) '--verbose',
      'create',
      'avd',
      '--force',
      '--name',
      deviceName,
      '--device',
      model,
      '--package',
      imageName.join(';'),
    ]);
  }

  @override
  Future<void> createOrStart() async {
    final devices = await availableDevices();
    final device = devices.firstWhere(
        (d) => d.os == os && d.osVersion == osVersion && d.model == model,
        orElse: () => null);
    if (device != null) {
      return await device.start();
    }

    await create();
    await start();
  }

  @override
  Future<void> delete() =>
      VirtualDevice.runWithError('emulator', ['delete', 'avd', '-n', name]);

  @override
  Future<void> start({
    bool bootAnimation = false,
    bool snapshot = false,
    bool wipeData = true,
  }) =>
      VirtualDevice.runWithError('emulator', [
        '-avd',
        name,
        if (!bootAnimation) '-no-boot-anim',
        if (!snapshot) '-no-snapshot',
        if (wipeData) '-wipe-data',
        '-prop',
        'emu.uuid=$uuid'
            '>',
        '/dev/null',
        '2>&1',
      ]);

  @override
  Future<void> stop() async => await VirtualDevice.runWithError('adb', [
        '-s',
        (await emulatorId),
        'wait-for-device',
        'emu',
        'kill',
      ]);

  @override
  Future<void> wipe() =>
      VirtualDevice.runWithError('emulator', ['avd', name, '-wipe-data']);

  /// Created and available emulators
  static Future<List<AndroidEmulator>> availableDevices() async {
    final rawDevices = await AvdmanagerCli.instance.availableDevices();
    return rawDevices
        .map((device) {
          return AndroidEmulator(
            googleApis: device['googleApis'],
            model: device['device'],
            name: device['name'],
            osVersion: device['apiLevel'].toString(),
          );
        })
        .toList()
        .cast<AndroidEmulator>();
  }

  /// Segment available emulator types into digestible Maps. See [AvdmanagerCli#availableDeviceTypes]
  static Future<Iterable<Map<String, String>>> availableDeviceTypes() =>
      AvdmanagerCli.instance.availableDeviceTypes();

  /// Segment available Android versions into digestible Maps. See [AvdmanagerCli#availableRuntimes]
  static Future<Iterable<Map<String, String>>> availableRuntimes() =>
      AvdmanagerCli.instance.availableRuntimes();

  static Future<void> stopAll() =>
      VirtualDevice.runWithError('adb', ['emu', 'kill']);
}
