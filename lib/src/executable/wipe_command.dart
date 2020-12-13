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
    argParser.addOption(
      'name',
      defaultsTo: null,
      help: 'The device name.',
    );
    argParser.addFlag(
      'all',
      abbr: 'a',
      defaultsTo: false,
      help: 'Erase all data from devices for the platform. ',
    );
  }

  @override
  Future<void> run() async {
    if (argResults['all']) {
      if (isIos) return await IosSimulator.wipeAll();
      if (isAndroid) {
        throw UsageException('Wipe All is not supported currently for Android',
            '--platform ios');
      }
    }

    if (argResults['name'] == null) {
      throw UsageException(
          'Name must be included when --all is false', '--name "Device Name"');
    }

    final device = await deviceFromName(
      isIOS: isIos,
      name: argResults['name'],
    );
    return await device.wipe();
  }
}
