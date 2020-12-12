import 'dart:io';

import 'package:virtual_device/virtual_device.dart';

class AndroidEmulator implements VirtualDevice {
  final String model;

  final String name;

  final os = OperatingSystem.android;

  final String osVersion;

  final String uuid;

  AndroidEmulator({
    this.model,
    this.name,
    this.osVersion,
    this.uuid = '',
  });

  Future<AndroidEmulator> create({bool verbose = false}) async {
    await VirtualDevice.runWithError('avdmanager', [
      if (verbose) '--verbose',
      'create',
      'avd',
      '--force',
      '--name',
      name,
      '--device',
      model,
      '--package',
      'system-images;android-$osVersion;google_apis;x86',
    ]);

    return this;
  }

  Future<void> delete() =>
      VirtualDevice.runWithError('emulator', ['delete', 'avd', '-n', name]);

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
      ]);

  Future<void> stop() =>
      VirtualDevice.runWithError('adb', ['-s', name, 'emu', 'kill']);

  Future<void> wipe() =>
      VirtualDevice.runWithError('emulator', ['avd', name, '-wipe-data']);

  static Future<List<AndroidEmulator>> availableDevices() async {
    final processOutput = await Process.run('adb', ['devices']);

    if (processOutput.stderr != null) {
      throw StateError(processOutput.stderr);
    }
  }

  static Future<void> stopAll() =>
      VirtualDevice.runWithError('adb', ['emu', 'kill']);
}
