import 'package:virtual_device/src/executable/executable_utils.dart';
import 'package:virtual_device/src/executable/virtual_device_command.dart';

class DeleteCommand extends VirtualDeviceCommand {
  @override
  final name = 'delete';

  @override
  final description = 'Permanently remove a virtual device';

  DeleteCommand() {
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
    return await device.delete();
  }
}
