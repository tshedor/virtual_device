import 'package:uuid/uuid.dart';
import 'package:virtual_device/src/android/adb_cli.dart';
import 'package:virtual_device/src/android/avdmanager_cli.dart';
import 'package:virtual_device/src/virtual_device.dart';
import 'package:virtual_device/src/virtual_device_utils.dart';
import 'package:virtual_device/virtual_device.dart';

class AndroidEmulator extends VirtualDevice {
  /// Discovers the emulator id if the emulator is running and assigns it
  /// to [uuid].
  Future<String?> get asyncUuid async {
    if (uuid != null) return uuid!;
    final uuidAndEmulatorId = await AdbCli.instance.internalIdentifierAndEmulatorId;
    if (uuidAndEmulatorId == null) return null;
    return uuid = uuidAndEmulatorId[_internalIdentifier]!;
  }

  /// Whether to build an image with Google APIs. Defaults `true`
  final bool googleApis;

  @override
  final String model;

  @override
  final String? name;

  @override
  final os = OperatingSystem.android;

  /// Maps to the Android API Level
  @override
  final String osVersion;

  /// A unique identifier used to communicate with the platform.
  /// This is the `emulatorId`, e.g. `emulator-5554`.
  @override
  String? uuid;

  /// Used to discover the emulator ID after start.
  /// Emulator IDs are difficult to determine because starting
  /// an emulator spawns a process instead of returning the ID or even
  /// printing it at start. Therefore, a generated ID is required to associate
  /// started emulators. See [asyncUuid] and [start]
  final String _internalIdentifier = Uuid().v1();

  AndroidEmulator({
    this.googleApis = true,
    required this.model,
    this.name,
    required this.osVersion,
    this.uuid,
  });

  @override
  Future<void> create({bool verbose = false}) async {
    final availableVersions = await AvdmanagerCli.instance.availableRuntimes();
    final discoveredVersion = availableVersions.firstWhere(
      (v) => v['apiLevel'].toString() == osVersion,
      orElse: () {
        final versions = availableVersions.map((v) => v['apiLevel']).join(', ');
        throw StateError('$osVersion is not available in $versions');
      },
    );

    if (discoveredVersion['googleApis'] != googleApis) {
      throw StateError('$osVersion does not have a compatible Google APIs ($googleApis) image');
    }

    final imageName = ['system-images' 'android-$osVersion'];
    if (googleApis) imageName.add('google_apis');
    imageName.add('x86');

    final deviceName =
        name ?? (await AvdmanagerCli.instance.generateName(model: model, osVersion: osVersion));

    await runWithError('avdmanager', [
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
    final device = firstWhereOrNull<AndroidEmulator>(
      devices,
      (d) => d.os == os && d.osVersion == osVersion && d.model == model,
    );
    if (device != null) {
      return await device.start();
    }

    await create();
    await start();
  }

  @override
  Future<void> delete() => runWithError('emulator', ['delete', 'avd', '-n', name!]);

  @override
  Future<void> start({
    bool bootAnimation = false,
    bool snapshot = false,
    bool wipeData = true,
  }) =>
      runWithError('emulator', [
        '-avd',
        name!,
        if (!bootAnimation) '-no-boot-anim',
        if (!snapshot) '-no-snapshot',
        if (wipeData) '-wipe-data',
        '-prop',
        'emu.uuid=$_internalIdentifier',
        '>',
        '/dev/null',
        '2>&1',
      ]);

  @override
  Future<void> stop() async {
    final emulatorId = await asyncUuid;
    if (emulatorId != null) return AdbCli.instance.stop(emulatorId!);
  }

  @override
  Future<void> wipe() => runWithError('emulator', ['avd', name!, '-wipe-data']);

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
}
