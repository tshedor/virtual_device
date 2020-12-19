import 'package:meta/meta.dart';
import 'package:virtual_device/src/virtual_device.dart';
import 'package:virtual_device/virtual_device.dart';

/// This class only interprets the output from the `flutter` CLI.
/// [IosSimulator]s and [AndroidEmulator]s are always valid devices for Flutter to use
class FlutterCli {
  /// The equivalent of `flutter devices`, this returns a list of all [VirtualDevice]s
  /// that Flutter considers running and accessible. Detached devices are not reported.
  ///
  /// The information from the Flutter CLI is incomplete and may not include model
  /// or name.
  static Future<List<VirtualDevice>> availableDevices() async {
    final cliOutput = await runWithError('flutter', ['devices']);
    return parseAvailableDevices(cliOutput);
  }

  @visibleForTesting
  static List<VirtualDevice> parseAvailableDevices(String cliOutput) {
    return cliOutput
        .split('\n')
        .map((device) {
          if (device.toLowerCase().contains('error')) return null;
          if (!device.contains('•')) return null;

          final parts = device.split('•');

          if (device.toLowerCase().contains('android')) {
            final osVersionMatch =
                RegExp(r'\(API (\d+)\)').firstMatch(parts[3]);

            return AndroidEmulator(
              uuid: parts[1].trim(),
              osVersion: osVersionMatch?.group(1),
            );
          }

          final os = OperatingSystem.values.firstWhere(
            (v) => v.toString().split('.').last.toLowerCase() == parts[2],
            orElse: () => OperatingSystem.iOS,
          );
          final osVersionMatch = RegExp(r'(\d+)-(\d+)').firstMatch(parts[3]);
          final osVersion = osVersionMatch?.group(0)?.replaceAll('-', '.');

          final generatedByVirtualDevice =
              RegExp(r'(.*):([\d\.]+):\d+').firstMatch(parts[0]);
          return IosSimulator(
            model: generatedByVirtualDevice?.group(1),
            name: parts[0].trim(),
            os: os,
            osVersion: generatedByVirtualDevice?.group(2) ?? osVersion,
            uuid: parts[1].trim(),
          );
        })
        .where((d) => d != null)
        .toList()
        .cast<VirtualDevice>();
  }
}
