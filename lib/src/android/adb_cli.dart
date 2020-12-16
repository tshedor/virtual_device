import 'package:virtual_device/virtual_device.dart';

class AdbCli {
  /// Given a running simulator, associate the generated UUID from [AndroidEmulator]
  Future<Map<String, String>> get uuidAndEmulatorId async {
    final runningAdbEmulators = await runWithError('adb', ['devices']);
    final adbMatches = RegExp(r'^emulator-\d+', multiLine: true)
        .allMatches(runningAdbEmulators);
    if (adbMatches == null || adbMatches.isEmpty) return null;

    // inspired by https://stackoverflow.com/a/42038655
    final _uuidAndEmulatorId = {};
    for (final match in adbMatches) {
      final emulatorId = match.group(0).trim();
      final adbUuid = await runWithError('adb', [
        '-s',
        emulatorId,
        'wait-for-device',
        'shell',
        'getprop',
        'emu.uuid'
      ]);
      _uuidAndEmulatorId[adbUuid.trim()] = emulatorId;
    }

    return _uuidAndEmulatorId;
  }

  static const AdbCli instance = AdbCli._();

  const AdbCli._();

  Future<void> setProp(String emulatorId, {String prop, String value}) =>
      runWithError('adb', [
        '-s',
        emulatorId,
        'wait-for-device',
        'shell',
        'setprop',
        prop,
        value
      ]);

  Future<void> stop(String emulatorId) async => await runWithError('adb', [
        '-s',
        emulatorId,
        'wait-for-device',
        'emu',
        'kill',
      ]);

  Future<void> stopAll() => runWithError('adb', ['emu', 'kill']);
}
