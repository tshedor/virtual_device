import 'package:virtual_device/virtual_device.dart';
import 'package:args/args.dart';

Future<VirtualDevice> deviceFromName({bool isIOS = true, String name}) async {
  List<VirtualDevice> devices;
  if (isIOS) {
    devices = await IosSimulator.availableDevices();
  } else {
    devices = await AndroidEmulator.availableDevices();
  }

  return devices.firstWhere(
    (d) => d.name == name,
    orElse: () => throw StateError('Device named $name not found'),
  );
}

final platformParser = ArgParser()
  ..addOption(
    'platform',
    allowed: ['ios', 'android'],
    abbr: 'p',
    defaultsTo: 'ios',
    allowedHelp: {
      'ios': 'Start an iOS device',
      'android': 'Start an Android device'
    },
  );

final nameParser = platformParser
  ..addOption(
    'name',
    defaultsTo: null,
    help:
        'The device name. When creating, it is recommended to leave this option blank',
  );
final parser = ArgParser()
  ..addCommand(
    'create',
    nameParser
      ..addOption(
        'model',
        abbr: 'm',
        help: 'The device model, such as "iPad Air 2"',
      )
      ..addOption(
        'osVersion',
        abbr: 'v',
        help: 'The OS version, such as "14.2"',
      )
      ..addOption(
        'os',
        abbr: 'o',
        defaultsTo: 'iOS',
        allowed: ['iOS', 'watchOS', 'tvOS'],
        help:
            'The OS, such as "iOS". This is only available for Apple simulators.',
      ),
  )
  ..addCommand('delete', nameParser)
  ..addCommand(
    'list',
    platformParser
      ..addCommand('devices')
      ..addCommand('models')
      ..addCommand('versions'),
  )
  ..addCommand('start', nameParser)
  ..addCommand('stop', nameParser)
  ..addCommand('wipe', nameParser);

void main(List<String> args) async {
  final results = parser.parse(args);

  switch (results.command.name) {
    case 'create':
      VirtualDevice device;
      if (results.command['platform'] == 'ios') {
        final os = OperatingSystem.values.firstWhere(
            (e) => e.toString().split('.').last == results.command['os']);
        device = IosSimulator(
          model: results.command['model'],
          name: results.command['name'],
          os: os,
          osVersion: results.command['osVersion'],
        );
      }
      if (results.command['platform'] == 'android') {
        device = AndroidEmulator(
          model: results.command['model'],
          name: results.command['name'],
          osVersion: results.command['osVersion'],
        );
      }

      return print(await device.create());

    case 'delete':
      final device = await deviceFromName(
        isIOS: results.command['platform'] == 'ios',
        name: results.command['name'],
      );
      return await device.delete();

    case 'list':
      if (results.command['platform'] == 'ios') {
        if (results.command.command.name == 'devices') {
          final devices = await IosSimulator.availableDevices();
          return print(devices.join('\n'));
        }
        if (results.command.command.name == 'models') {
          final models = await IosSimulator.availableDeviceTypes();
          return print(models.keys.join('\n'));
        }
        if (results.command.command.name == 'versions') {
          final versions = await IosSimulator.availableRuntimes();
          return print(versions.keys.join('\n'));
        }
      }

      break;

    case 'start':
      final device = await deviceFromName(
        isIOS: results.command['platform'] == 'ios',
        name: results.command['name'],
      );
      return await device.start();

    case 'stop':
      final device = await deviceFromName(
        isIOS: results.command['platform'] == 'ios',
        name: results.command['name'],
      );
      return await device.stop();

    case 'wipe':
      final device = await deviceFromName(
        isIOS: results.command['platform'] == 'ios',
        name: results.command['name'],
      );
      return await device.wipe();
  }
}
