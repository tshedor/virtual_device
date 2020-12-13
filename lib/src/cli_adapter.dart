abstract class CliAdapter {
  const CliAdapter();

  /// Parse a list of all available simulators. Unavailable run times and simulators with
  /// missing runtimes will not be included.
  Future<Iterable<Map<String, dynamic>>> availableDevices();

  /// Generate a name based on existing simulators in the format `model:osVersion:incrementor`.
  /// If a device has already been generated with the name, increment the trailing number.
  Future<String> generateName({String model, String osVersion}) async {
    final createdName = '$model:$osVersion';
    final existingDevices = await availableDevices();
    final existingDevice = existingDevices
        .firstWhere((d) => d['name'].contains(createdName), orElse: () => null);
    if (existingDevice != null) {
      final appendedVersion =
          RegExp(r':(\d+)$').firstMatch(existingDevice['name']);
      final version = int.tryParse(appendedVersion?.group(1) ?? '0');
      return '$createdName:${version + 1}';
    }

    return '$createdName:1';
  }
}
