import 'package:args/command_runner.dart';
import 'package:virtual_device/src/executable/executable_utils.dart';
import 'package:virtual_device/src/executable/virtual_device_command.dart';
import 'package:virtual_device/virtual_device.dart';

class StopCommand extends VirtualDeviceCommand {
  @override
  final name = 'stop';

  @override
  final description = 'Pause a running virtual device';

  StopCommand() {
    argParser.addOption(
      'name',
      defaultsTo: null,
      help: 'The device name.',
    );
    argParser.addFlag(
      'all',
      abbr: 'a',
      defaultsTo: false,
      help: 'Stop all running devices for the platform',
    );
  }

  @override
  Future<void> run() async {
    if (argResults['all']) {
      if (isIos) return await IosSimulator.stopAll();
      if (isAndroid) return await AndroidEmulator.stopAll();
    }

    if (argResults['name'] == null) {
      throw UsageException(
          'Name must be included when --all is false', '--name "Device Name"');
    }

    final device = await deviceFromName(
      isIOS: isIos,
      name: argResults['name'],
    );
    return await device.stop();
  }
}
