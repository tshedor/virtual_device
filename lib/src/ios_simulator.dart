import 'dart:io';
import 'package:meta/meta.dart';

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
  final String uuid;

  IosSimulator({
    @required this.model,
    this.name,
    @required this.osVersion,
    @required this.os,
    this.status,
    this.uuid,
  });

  @override
  Future<IosSimulator> create() async {
    final deviceTypes = await availableDeviceTypes();
    final deviceType = deviceTypes[model];
    if (deviceType == null) {
      throw StateError(
          '$model is not available in ${deviceTypes.keys.join(", ")}');
    }

    final runtimes = await availableRuntimes();
    final runtimeKey = runtimes.keys.firstWhere(
        (k) => k.startsWith('${os.toString().split(".").last} $osVersion'),
        orElse: () => throw StateError(
            '$osVersion is not available from ${runtimes.keys.join(", ")}'));
    final runtime = runtimes[runtimeKey];
    final deviceName =
        name ?? (await generateName(model: model, osVersion: osVersion));
    final uuid = await VirtualDevice.runWithError(
        'xcrun', ['simctl', 'create', deviceName, deviceType, runtime]);

    return IosSimulator(
      model: model,
      name: deviceName,
      os: os,
      osVersion: osVersion,
      status: status,
      uuid: uuid.trim(),
    );
  }

  @override
  Future<void> delete() => Process.run('xcrun', ['simctl', 'delete', uuid]);

  @override
  Future<void> start() => Process.run('xcrun', ['simctl', 'boot', uuid]);

  @override
  Future<void> stop() => Process.run('xcrun', ['simctl', 'shutdown', uuid]);

  @override
  Future<void> wipe() => Process.run('xcrun', ['simctl', 'erase', uuid]);

  /// Parse a list of all available simulators. Unavailable run times and simulators with
  /// missing runtimes will not be included.
  static Future<List<IosSimulator>> availableDevices() async {
    final processOutput = await VirtualDevice.runWithError(
        'xcrun', ['simctl', 'list', 'devices']);

    final matches = RegExp(r'^-- (.*) --$', multiLine: true)
        .allMatches(processOutput)
        .toList()
        .cast<RegExpMatch>();

    return matches
        .map((match) {
          // Ignore unavailable simulators
          if (match.group(1).contains('Unavailable')) return null;

          final runtimeString =
              match.group(1).replaceAll(RegExp(r'[\d\.\s\-]*'), '').trim();
          final osVersion =
              match.group(1).replaceAll(RegExp(r'[^\d\.]*'), '').trim();
          final runtime = OperatingSystem.values
              .firstWhere((e) => e.toString().split('.').last == runtimeString);
          final devices = _simulatorsFromSimctl(processOutput, match, matches)
              .replaceAll(RegExp(r'^ --', multiLine: true), '')
              .replaceAll(RegExp(r'-- $', multiLine: true), '')
              .replaceAll(RegExp('^\s*', multiLine: true), '')
              .trim()
              .split('\n');

          return devices.map((device) {
            return _deviceFromString(
              device,
              runtime: runtime,
              osVersion: osVersion,
            );
          }).where((e) => e != null);
        })
        .where((e) => e != null)
        .expand((e) => e)
        .toList()
        .cast<IosSimulator>();
  }

  /// Segment available devices by `humanizedDeviceName: deviceTypeId`
  static Future<Map<String, String>> availableDeviceTypes() async {
    final processOutput = await VirtualDevice.runWithError(
        'xcrun', ['simctl', 'list', 'devicetypes']);

    final matches =
        RegExp(r'(.*)\(([^\s]+)\)$', multiLine: true).allMatches(processOutput);
    return matches.fold<Map<String, String>>({}, (acc, match) {
      acc[match.group(1).trim()] = match.group(2).trim();
      return acc;
    });
  }

  /// Segment available OS versions by `verionNumber: runtimeId`
  static Future<Map<String, String>> availableRuntimes() async {
    final processOutput = await VirtualDevice.runWithError(
        'xcrun', ['simctl', 'list', 'runtimes']);

    final matches = RegExp(r'(.*) - (.*)$', multiLine: true)
        .allMatches(processOutput.trim());
    return matches.fold<Map<String, String>>({}, (acc, match) {
      acc[match.group(1).trim()] = match.group(2).trim();
      return acc;
    });
  }

  /// Generate a name based on existing simulators in the format `model:osVersion:incrementor`.
  /// If a device has already been generated with the name, increment the trailing number.
  static Future<String> generateName({String model, String osVersion}) async {
    final createdName = '$model:$osVersion';
    final existingDevices = await availableDevices();
    final existingDevice = existingDevices
        .firstWhere((d) => d.name.contains(createdName), orElse: () => null);
    if (existingDevice != null) {
      final appendedVersion =
          RegExp(r':(\d+)$').firstMatch(existingDevice.name);
      final version = int.tryParse(appendedVersion?.group(1) ?? '0');
      return '$createdName:${version + 1}';
    }

    return '$createdName:1';
  }

  /// Wipe data from all simulators
  static Future<void> wipeAll() async {
    await VirtualDevice.runWithError('xcrun', ['simctl', 'erase', 'all']);
  }

  static Future<void> shutdownAll() =>
      VirtualDevice.runWithError('xcrun', ['simctl', 'shutdown', 'all']);
}

IosSimulator _deviceFromString(
  String deviceLine, {
  OperatingSystem runtime,
  String osVersion,
}) {
  if (deviceLine.contains('(unavailable')) return null;

  final deviceMatch =
      RegExp(r'\(([A-Za-z0-9\-]+)\) \(([\w\s]+)\)(?:\s\(.*\))?$')
          .firstMatch(deviceLine.trim());
  final name =
      deviceLine.trim().replaceAll(deviceMatch.group(0).trim(), '').trim();
  return IosSimulator(
    model: name.replaceAll(RegExp(r':[\d\.]*'), ''),
    name: name,
    os: runtime,
    osVersion: osVersion,
    status: deviceMatch.group(2).trim(),
    uuid: deviceMatch.group(1).trim(),
  );
}

String _simulatorsFromSimctl(
  String simctlOuput,
  RegExpMatch match,
  List<RegExpMatch> matches,
) {
  final indexOfMatch = matches.indexOf(match);
  final runTimePosition =
      simctlOuput.indexOf(match.group(1)) + match.group(1).length;
  if (indexOfMatch != matches.length - 1) {
    final startOfNextRuntimePosition =
        simctlOuput.indexOf(matches[indexOfMatch + 1].group(1));
    return simctlOuput.substring(runTimePosition, startOfNextRuntimePosition);
  }

  return simctlOuput.substring(runTimePosition);
}
