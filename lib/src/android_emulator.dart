import 'dart:io';

import 'package:virtual_device/virtual_device.dart';

class AndroidEmulator implements VirtualDevice {
  @override
  final String model;

  @override
  final String name;

  @override
  final os = OperatingSystem.android;

  @override
  final String osVersion;

  @override
  final String uuid;

  AndroidEmulator({
    this.model,
    this.name,
    this.osVersion,
    this.uuid = '',
  });

  @override
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
      ]);

  @override
  Future<void> stop() =>
      VirtualDevice.runWithError('adb', ['-s', name, 'emu', 'kill']);

  @override
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
