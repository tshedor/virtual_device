import 'package:meta/meta.dart';

abstract class CliAdapter {
  const CliAdapter();

  /// Parse a list of all available simulators. Unavailable run times and simulators with
  /// missing runtimes will not be included.
  Future<Iterable<Map<String, dynamic>>> availableDevices();

  /// Generate a name based on existing simulators in the format `model:osVersion:incrementor`.
  /// If a device has already been generated with the name, increment the trailing number.
  Future<String> generateName({required String model, required String osVersion}) async {
    final createdName = '$model:$osVersion';
    final existingDevices = await availableDevices();
    final existingModels = existingDevices
        .where((d) => d['name'].contains(createdName))
        .toList()
        .cast<Map<String, dynamic>>();

    final version = incrementForName(existingModels);

    return '$createdName:$version';
  }

  /// Returns the incremented number, e.g. `3` if two previous devices exist.
  /// Increments are only valid for names Virtual Device recognizes. If no previously
  /// created devices exist, returns `1`.
  @visibleForTesting
  static int incrementForName(List<Map<String, dynamic>> existingModels) {
    final appendedVersionRegEx = RegExp(r':(\d+)$');
    // Sort ASC (1, 2, 3)
    existingModels.sort((a, b) {
      final appendedVersionARaw = appendedVersionRegEx.firstMatch(a['name'])?.group(1);
      final appendedVersionBRaw = appendedVersionRegEx.firstMatch(b['name'])?.group(1);
      final appendedVersionA = int.tryParse(appendedVersionARaw ?? '0')!;
      final appendedVersionB = int.tryParse(appendedVersionBRaw ?? '0')!;
      return appendedVersionA.compareTo(appendedVersionB);
    });

    if (existingModels.isEmpty) {
      return 1;
    }

    final appendedVersion = appendedVersionRegEx.firstMatch(existingModels.last['name']);
    final version = int.tryParse(appendedVersion?.group(1) ?? '0')!;
    return version + 1;
  }
}
