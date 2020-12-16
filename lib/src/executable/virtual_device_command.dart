import 'package:args/command_runner.dart';

abstract class VirtualDeviceCommand extends Command {
  bool get isAndroid => argResults['platform'] == 'android';

  bool get isIos => argResults['platform'] == 'ios';

  VirtualDeviceCommand();
}
