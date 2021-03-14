import 'package:args/command_runner.dart';
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
      'name',
      abbr: 'n',
      defaultsTo: null,
      help:
          'The name for the created virtual device. It is **strongly recommended** to leave this blank and allow Virtual Device to generate names.',
    );
    argParser.addOption(
      'os',
      abbr: 'o',
      defaultsTo: 'iOS',
      allowed: ['iOS', 'watchOS', 'tvOS'],
      help: 'The OS, such as "iOS". This is only available for Apple simulators.',
    );
    argParser.addOption(
      'os-version',
      abbr: 'v',
      help: 'The OS version, such as "14.2"',
    );
  }

  @override
  Future<void> run() async {
    VirtualDevice device;
    if (argResults?['model'] == null) {
      throw UsageException(
        '--model is required',
        'Ex. --model "iPad Air 2"',
      );
    }
    if (argResults?['os-version'] == null) {
      throw UsageException(
        '--os-version is required',
        'Ex. --os-version 12.1',
      );
    }

    if (isIos) {
      final os = OperatingSystem.values
          .firstWhere((e) => e.toString().split('.').last == argResults?['os']);
      device = IosSimulator(
        model: argResults?['model'],
        name: argResults?['name'],
        os: os,
        osVersion: argResults?['os-version'],
      );
    } else {
      // isAndroid
      if (argResults?['os'] != null) {
        print('--os is only available for Apple devices; ignoring ${argResults?["os"]}');
      }

      device = AndroidEmulator(
        model: argResults?['model'],
        name: argResults?['name'],
        osVersion: argResults?['os-version'],
      );
    }

    await device.create();
    return print(device);
  }
}
