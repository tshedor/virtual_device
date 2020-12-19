import 'package:args/command_runner.dart';
import 'package:virtual_device/src/executable/executable_utils.dart';
import 'package:virtual_device/src/executable/virtual_device_command.dart';

class DeleteCommand extends VirtualDeviceCommand {
  @override
  final name = 'delete';

  @override
  final description = 'Permanently remove a virtual device';

  @override
  final usage =
      'Specify device names to permanently remove in a space-separated list';

  @override
  Future<void> run() async {
    if (argResults.rest?.isEmpty ?? true) {
      throw UsageException(
        'The name of the device(s) is required',
        'Ex. virtual_device delete "iPad Air 2:12.1:1"',
      );
    }

    for (final name in argResults.rest) {
      final device = await deviceFromName(
        isIOS: isIos,
        name: name,
      );
      await device.delete();
    }
  }
}
