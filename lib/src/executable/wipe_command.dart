import 'package:args/command_runner.dart';
import 'package:virtual_device/src/executable/executable_utils.dart';
import 'package:virtual_device/src/executable/virtual_device_command.dart';
import 'package:virtual_device/virtual_device.dart';

class WipeCommand extends VirtualDeviceCommand {
  @override
  final name = 'wipe';

  @override
  final description = 'Erase data from a virtual device';

  WipeCommand() {
    argParser.addFlag(
      'all',
      abbr: 'a',
      defaultsTo: false,
      negatable: false,
      help: 'Erase all data from devices for the platform.',
    );
  }

  @override
  Future<void> run() async {
    if (argResults?['all'] ?? false) {
      if (isIos) return await IosSimulator.wipeAll();
      if (isAndroid) {
        throw UsageException(
          'Wipe -all is not supported currently for Android',
          'Ex. --platform ios',
        );
      }
    }

    if (argResults?.rest.isEmpty ?? true) {
      throw UsageException(
        'Name(s) must be included when --all is false',
        'Ex. virtual_device wipe "iPad Air 2:12.1:1"',
      );
    }

    for (final name in argResults?.rest ?? []) {
      final device = await deviceFromName(
        isIOS: isIos,
        name: name,
      );
      await device.wipe();
    }
  }
}
