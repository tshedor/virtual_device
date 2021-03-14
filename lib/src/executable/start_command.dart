import 'package:args/command_runner.dart';
import 'package:virtual_device/src/executable/executable_utils.dart';
import 'package:virtual_device/src/executable/virtual_device_command.dart';

class StartCommand extends VirtualDeviceCommand {
  @override
  final name = 'start';

  @override
  final description = 'Boot an existing virtual device';

  @override
  final usage = 'Specify device names to start in a space-separated list';

  @override
  Future<void> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      throw UsageException(
        'The name of the device(s) is required',
        'Ex. virtual_device start "iPad Air 2:12.1:1"',
      );
    }

    for (final name in argResults?.rest ?? []) {
      final device = await deviceFromName(
        isIOS: isIos,
        name: name,
      );
      await device.start();
    }
  }
}
