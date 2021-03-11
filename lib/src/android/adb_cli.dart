import 'package:virtual_device/virtual_device.dart';

class AdbCli {
  /// Associate the emaultor ID by fetching the [AndroidEmulator#_internalIdentifier]
  /// from all running simulators
  Future<Map<String, String>?> get internalIdentifierAndEmulatorId async {
    final runningAdbEmulators = await runWithError('adb', ['devices']);
    final adbMatches = RegExp(r'^emulator-\d+', multiLine: true).allMatches(runningAdbEmulators);
    if (adbMatches.isEmpty) return null;

    // inspired by https://stackoverflow.com/a/42038655
    final uuidAndEmulatorId = <String, String>{};
    for (final match in adbMatches) {
      final emulatorId = match.group(0)!.trim();
      final adbUuid = await runWithError(
          'adb', ['-s', emulatorId, 'wait-for-device', 'shell', 'getprop', 'emu.uuid']);
      uuidAndEmulatorId[adbUuid.trim()] = emulatorId;
    }

    return uuidAndEmulatorId;
  }

  static const AdbCli instance = AdbCli._();

  const AdbCli._();

  Future<void> setProp(
    String emulatorId, {
    required String prop,
    required String value,
  }) =>
      runWithError('adb', ['-s', emulatorId, 'wait-for-device', 'shell', 'setprop', prop, value]);

  Future<void> stop(String emulatorId) async => await runWithError('adb', [
        '-s',
        emulatorId,
        'wait-for-device',
        'emu',
        'kill',
      ]);

  Future<void> stopAll() => runWithError('adb', ['emu', 'kill']);
}
