import 'dart:io';
import 'dart:async';

enum OperatingSystem {
  iOS,
  android,
  tvOS,
  watchOS,
}

abstract class VirtualDevice {
  /// Example: "iPad Air 2"
  String? get model;

  /// The humanized name of the device.
  /// Implementers of [VirtualDevice] should generate the name in a way that increments
  /// prior creations of the [model] and [osVersion].
  String? get name;

  OperatingSystem get os;

  /// Example: "14.2"
  String get osVersion;

  /// A unique identifier used to communicate with the platform.
  String? get uuid;

  /// Creates a new version of the device. [uuid] is usually assigned
  /// by the platform within this method.
  Future<void> create();

  /// If the device already exists, [start] it instead of [create]ing it.
  /// If all devices of the [model], [os], and [osVersion] type are already running,
  /// a new virtual device will be [create]d and then [start]ed.
  Future<void> createOrStart();

  /// Permanently delete the device. For removing data only, see [wipe].
  Future<void> delete();

  /// Boots the device
  Future<void> start();

  /// Turns off the device
  Future<void> stop();

  @override
  String toString() => '$name / $model / ${os.toString().split(".").last} $osVersion / $uuid';

  /// Remove all data from the device. To permanently remove the device, see [delete].
  Future<void> wipe();
}

/// If the command line execution returns an exception, throw it in Dart.
Future<String> runWithError(String cmd, List<String> args) async {
  final processOutput = await Process.run(cmd, args);

  if (processOutput.stderr != null && processOutput.stderr.toString().isNotEmpty) {
    throw StateError(processOutput.stderr);
  }

  return processOutput.stdout;
}
