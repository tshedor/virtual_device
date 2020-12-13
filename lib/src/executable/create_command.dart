import 'package:virtual_device/src/executable/virtual_device_command.dart';
import 'package:virtual_device/virtual_device.dart';

class CreateCommand extends VirtualDeviceCommand {
  @override
  final name = 'create';

  @override
  final description = 'Create a new virtual device';

  CreateCommand() {
    argParser.addOption(
      'model',
      abbr: 'm',
      help: 'The device model, such as "iPad Air 2"',
    );
    argParser.addOption(
      'osVersion',
      abbr: 'v',
      help: 'The OS version, such as "14.2"',
    );
    argParser.addOption(
      'os',
      abbr: 'o',
      defaultsTo: 'iOS',
      allowed: ['iOS', 'watchOS', 'tvOS'],
      help:
          'The OS, such as "iOS". This is only available for Apple simulators.',
    );
  }

  @override
  Future<void> run() async {
    VirtualDevice device;

    if (isIos) {
      final os = OperatingSystem.values
          .firstWhere((e) => e.toString().split('.').last == argResults['os']);
      device = IosSimulator(
        model: argResults['model'],
        name: argResults['name'],
        os: os,
        osVersion: argResults['osVersion'],
      );
    }

    if (isAndroid) {
      device = AndroidEmulator(
        model: argResults['model'],
        name: argResults['name'],
        osVersion: argResults['osVersion'],
      );
    }

    await device.create();
    return print(device);
  }
}
