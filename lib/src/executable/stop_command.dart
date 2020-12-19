import 'package:args/command_runner.dart';
import 'package:virtual_device/src/android/adb_cli.dart';
import 'package:virtual_device/src/executable/executable_utils.dart';
import 'package:virtual_device/src/executable/virtual_device_command.dart';
import 'package:virtual_device/virtual_device.dart';

class StopCommand extends VirtualDeviceCommand {
  @override
  final name = 'stop';

  @override
  final description = 'Pause a running virtual device';

  StopCommand() {
    argParser.addFlag(
      'all',
      abbr: 'a',
      defaultsTo: false,
      negatable: false,
      help: 'Stop all running devices for the platform',
    );
  }

  @override
  Future<void> run() async {
    if (argResults['all']) {
      if (isIos) return await IosSimulator.stopAll();
      if (isAndroid) return await AdbCli.instance.stopAll();
    }

    if (argResults.rest?.isEmpty ?? true) {
      throw UsageException(
        'Name(s) must be included when --all is false',
        'Ex. virtual_device stop "iPad Air 2:12.1:1"',
      );
    }

    for (final name in argResults.rest) {
      final device = await deviceFromName(
        isIOS: isIos,
        name: name,
      );
      await device.stop();
    }
  }
}
