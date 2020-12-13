import 'package:meta/meta.dart';
import 'package:virtual_device/src/cli_adapter.dart';
import 'package:virtual_device/src/virtual_device.dart';

/// A helper class to parse commandline output from `simctl`
class SimctlCli extends CliAdapter {
  const SimctlCli._();

  static const SimctlCli instance = SimctlCli._();

  @override
  Future<Iterable<Map<String, dynamic>>> availableDevices() async {
    final cliOutput = await VirtualDevice.runWithError(
        'xcrun', ['simctl', 'list', 'devices']);
    return parseDevicesOutput(cliOutput);
  }

  /// Segment available devices by `humanizedDeviceName: deviceTypeId`
  Future<Map<String, String>> availableDeviceTypes() async {
    final cliOutput = await VirtualDevice.runWithError(
        'xcrun', ['simctl', 'list', 'devicetypes']);
    return parseDeviceTypesOutput(cliOutput);
  }

  /// Segment available OS versions by `verionNumber: runtimeId`
  Future<Map<String, String>> availableRuntimes() async {
    final cliOutput = await VirtualDevice.runWithError(
        'xcrun', ['simctl', 'list', 'runtimes']);
    return parseRuntimesOutput(cliOutput);
  }

  /// Extracted for testing from [availableDevices]
  @visibleForTesting
  static Iterable<Map<String, dynamic>> parseDevicesOutput(String cliOutput) {
    final matches = RegExp(r'^-- (.*) --$', multiLine: true)
        .allMatches(cliOutput)
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
          final devices = _simulatorsFromSimctl(cliOutput, match, matches)
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
        .expand((e) => e);
  }

  /// Extracted for testing from [availableDeviceTypes]
  @visibleForTesting
  static Map<String, String> parseDeviceTypesOutput(String cliOutput) {
    final matches =
        RegExp(r'(.*)\(([^\s]+)\)$', multiLine: true).allMatches(cliOutput);
    return matches.fold<Map<String, String>>({}, (acc, match) {
      acc[match.group(1).trim()] = match.group(2).trim();
      return acc;
    });
  }

  /// Extracted for testing from [availableRuntimes]
  @visibleForTesting
  static Map<String, String> parseRuntimesOutput(String cliOutput) {
    final matches =
        RegExp(r'(.*) - (.*)$', multiLine: true).allMatches(cliOutput.trim());
    return matches.fold<Map<String, String>>({}, (acc, match) {
      acc[match.group(1).trim()] = match.group(2).trim();
      return acc;
    });
  }
}

Map<String, dynamic> _deviceFromString(
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
  return {
    'model': name.replaceAll(RegExp(r':[\d\.]*'), ''),
    'name': name,
    'os': runtime,
    'osVersion': osVersion,
    'status': deviceMatch.group(2).trim(),
    'uuid': deviceMatch.group(1).trim(),
  };
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
