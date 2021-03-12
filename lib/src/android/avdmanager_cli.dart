import 'package:meta/meta.dart';
import 'package:virtual_device/src/cli_adapter.dart';
import 'package:virtual_device/src/virtual_device.dart';

class AvdmanagerCli extends CliAdapter {
  static const AvdmanagerCli instance = AvdmanagerCli._();

  const AvdmanagerCli._();

  @override
  Future<Iterable<Map<String, dynamic>>> availableDevices() async {
    final cliOutput = await runWithError('avdmanager', ['list', 'avd']);
    return parseDevicesOutput(cliOutput);
  }

  Future<Iterable<Map<String, dynamic>>> availableDeviceTypes() async {
    final cliOutput = await runWithError('avdmanager', ['list', 'device']);
    return parseDeviceTypesOutput(cliOutput);
  }

  Future<Iterable<Map<String, dynamic>>> availableRuntimes() async {
    final cliOutput = await runWithError('avdmanager', ['list', 'target']);
    return parseRuntimesOutput(cliOutput);
  }

  @visibleForTesting
  static Iterable<Map<String, dynamic>> parseDevicesOutput(String cliOutput) {
    final availableDeviceOutput =
        cliOutput.split('The following Android Virtual Devices could not be loaded:').first;
    final output = availableDeviceOutput.split('---------').map<Map<String, dynamic>?>((device) {
      String? target;
      String? apiLevel;
      var googleApis = false;
      if (device.contains('Target: Google APIs')) {
        final targetMatch =
            RegExp(r'^\s+Based on: Android API (\d+).*$', multiLine: true).firstMatch(device);
        target = targetMatch?.group(0)?.replaceAll('Based on: ', '').trim();
        apiLevel = targetMatch?.group(1)!;
        googleApis = true;
      } else {
        final targetMatch =
            RegExp(r'^\s+Target: (.*) \(API level (\d+)\)\s*$', multiLine: true).firstMatch(device);
        target = targetMatch?.group(1);
        apiLevel = targetMatch?.group(2);
      }
      final name = RegExp(r'^\s+Name: (.*)\s*$', multiLine: true).firstMatch(device);
      final deviceName = RegExp(r'^\s+Device: (.*)\s*$', multiLine: true).firstMatch(device);

      if (target == null) return null;

      return {
        'apiLevel': int.tryParse(apiLevel ?? ''),
        'name': name?.group(1),
        'device': deviceName?.group(1),
        'target': target,
        'googleApis': googleApis,
      };
    });
    return output.where((d) => d != null).cast<Map<String, dynamic>>();
  }

  @visibleForTesting
  static Iterable<Map<String, dynamic>> parseDeviceTypesOutput(
    String cliOutput,
  ) {
    return cliOutput.split('---------').map((type) {
      final id = RegExp(r'^id: (\d+) or "(.+)"', multiLine: true).firstMatch(type);
      final name = RegExp(r'^\s+Name: (.*)\s*$', multiLine: true).firstMatch(type);
      final oem = RegExp(r'^\s+OEM : (.*)\s*$', multiLine: true).firstMatch(type);
      return {
        'id': int.tryParse(id?.group(1) ?? ''),
        'idHumanized': id?.group(2),
        'name': name?.group(1),
        'oem': oem?.group(1),
      };
    });
  }

  @visibleForTesting
  static Iterable<Map<String, dynamic>> parseRuntimesOutput(String cliOutput) {
    final output = cliOutput.split('----------').map<Map<String, dynamic>?>((runtime) {
      final id = RegExp(r'^id: (\d+) or "([\w\-\d\:\.\s]+)"', multiLine: true).firstMatch(runtime);
      final name = RegExp(r'^\s+Name: (.*)\s*$', multiLine: true).firstMatch(runtime);
      final apiLevel = RegExp(r'^\s+API level: (\d+)\s*$', multiLine: true).firstMatch(runtime);
      if (id == null) return null;

      final result = {
        'id': int.tryParse(id.group(1) ?? ''),
        'idHumanized': id.group(2),
        'googleApis': false,
      };

      if (name?.group(1) == 'Google APIs') {
        final description =
            RegExp(r'^\s+Description: (.*)(\d+)\s*$', multiLine: true).firstMatch(runtime)!;
        result['name'] = '${description.group(1)}${description.group(2)}';
        result['apiLevel'] = int.tryParse(description.group(2) ?? '');
        result['googleApis'] = true;
      } else {
        result['name'] = name?.group(1);
        result['apiLevel'] = int.tryParse(apiLevel?.group(1) ?? '');
      }

      return result;
    });
    return output.where((r) => r != null).cast<Map<String, dynamic>>();
  }
}
