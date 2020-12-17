import 'package:args/command_runner.dart';

abstract class VirtualDeviceCommand extends Command {
  bool get isAndroid => argResults['platform'] == 'android';

  bool get isIos => argResults['platform'] == 'ios';

  VirtualDeviceCommand() {
    argParser.addOption(
      'platform',
      allowed: ['ios', 'android'],
      abbr: 'p',
      defaultsTo: 'ios',
      allowedHelp: {
        'ios': 'Start an iOS device',
        'android': 'Start an Android device'
      },
    );
  }
}
