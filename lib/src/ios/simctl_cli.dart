import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:virtual_device/src/cli_adapter.dart';
import 'package:virtual_device/src/virtual_device.dart';

/// A helper class to parse commandline output from `simctl`
class SimctlCli extends CliAdapter {
  static const SimctlCli instance = SimctlCli._();

  const SimctlCli._();

  @override
  Future<Iterable<Map<String, dynamic>>> availableDevices() async {
    final cliOutput =
        await runWithError('xcrun', ['simctl', 'list', '--json', 'devices']);
    return parseDevicesOutput(cliOutput);
  }

  /// Segment available devices by `humanizedDeviceName: deviceTypeId`
  Future<Map<String, String>> availableDeviceTypes() async {
    final cliOutput = await runWithError(
        'xcrun', ['simctl', 'list', '--json', 'devicetypes']);
    return parseDeviceTypesOutput(cliOutput);
  }

  /// Segment available OS versions by `os: { verionNumber: runtimeId }`
  Future<Map<String, Map<String, String>>> availableRuntimes() async {
    final cliOutput =
        await runWithError('xcrun', ['simctl', 'list', '--json', 'runtimes']);
    return parseRuntimesOutput(cliOutput);
  }

  /// Extracted for testing from [availableDevices]
  @visibleForTesting
  static Iterable<Map<String, dynamic>> parseDevicesOutput(String cliOutput) {
    final Map asJson = jsonDecode(cliOutput)['devices'];
    return asJson.entries
        .map((entry) {
          final os = OperatingSystem.values.firstWhere(
              (o) =>
                  o.toString().split('.').last ==
                  entry.key.replaceAll(RegExp(r'[\s\.\d]+'), ''),
              orElse: () => null);
          if (os == null) return null;

          return entry.value.map((device) {
            if (!device['isAvailable']) return null;

            return {
              'model': device['name'].replaceAll(RegExp(r':[\d\.]*'), ''),
              'name': device['name'],
              'os': os,
              'osVersion': entry.key.replaceAll(RegExp(r'[^\d\.]+'), ''),
              'status': device['state'],
              'uuid': device['udid'],
            };
          }).where((e) => e != null);
        })
        .where((e) => e != null)
        .expand((e) => e)
        .toList()
        .cast<Map<String, dynamic>>();
  }

  /// Extracted for testing from [availableDeviceTypes]
  @visibleForTesting
  static Map<String, String> parseDeviceTypesOutput(String cliOutput) {
    final Iterable asJson = jsonDecode(cliOutput)['devicetypes'];
    return asJson.fold<Map<String, String>>({}, (acc, deviceType) {
      acc[deviceType['name']] = deviceType['identifier'];
      return acc;
    });
  }

  /// Extracted for testing from [availableRuntimes]
  @visibleForTesting
  static Map<String, Map<String, String>> parseRuntimesOutput(
      String cliOutput) {
    final Iterable asJson = jsonDecode(cliOutput)['runtimes'];
    return asJson.fold<Map<String, Map<String, String>>>({}, (acc, runtime) {
      final os = runtime['name'].replaceAll(RegExp(r'[\s\d\.]+'), '');
      acc[os] ??= <String, String>{};
      acc[os][runtime['version']] = runtime['identifier'];
      return acc;
    });
  }
}
