import 'package:virtual_device/src/executable/executable_utils.dart';
import 'package:virtual_device/src/executable/virtual_device_command.dart';

class StartCommand extends VirtualDeviceCommand {
  @override
  final name = 'start';

  @override
  final description = 'Boot an existing virtual device';

  StartCommand() {
    argParser.addOption(
      'name',
      help: 'The device name.',
    );
  }

  @override
  Future<void> run() async {
    final device = await deviceFromName(
      isIOS: isIos,
      name: argResults['name'],
    );
    return await device.start();
  }
}
