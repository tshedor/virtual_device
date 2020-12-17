import 'package:virtual_device/src/android/avdmanager_cli.dart';
import 'package:virtual_device/src/executable/virtual_device_command.dart';
import 'package:virtual_device/virtual_device.dart';

class ListCommand extends VirtualDeviceCommand {
  @override
  final name = 'list';

  @override
  final description = 'List created devices, models, or available OS versions';

  ListCommand() {
    addSubcommand(_Devices());
    addSubcommand(_Models());
    addSubcommand(_Versions());
  }
}

class _Devices extends VirtualDeviceCommand {
  @override
  final name = 'devices';

  @override
  final description = 'List created devices';

  @override
  Future<void> run() async {
    // print(argResults['platform']);
    if (isIos) {
      final devices = await IosSimulator.availableDevices();
      return print(devices.join('\n'));
    }

    if (isAndroid) {
      final devices = await AndroidEmulator.availableDevices();
      return print(devices.join('\n'));
    }
  }
}

class _Models extends VirtualDeviceCommand {
  @override
  final name = 'models';

  @override
  final description = 'List available models';

  @override
  Future<void> run() async {
    if (isIos) {
      final models = await IosSimulator.availableDeviceTypes();
      return print(models.keys.join('\n'));
    }

    if (isAndroid) {
      final models = await AvdmanagerCli.instance.availableDeviceTypes();
      return print(models.map((m) => m['name']).join('\n'));
    }
  }
}

class _Versions extends VirtualDeviceCommand {
  @override
  final name = 'versions';

  @override
  final description = 'List OS versions and runtimes';

  @override
  Future<void> run() async {
    if (isIos) {
      final versions = await IosSimulator.availableRuntimes();
      final output = versions.entries.map((entry) {
        return '${entry.key}: ${entry.value.keys.join(", ")}';
      });
      return print(output.join('\n'));
    }

    if (isAndroid) {
      final versions = await AvdmanagerCli.instance.availableRuntimes();
      final humanized = versions.map((v) {
        var output = v['apiLevel'];
        if (output['googleApis']) {
          output += ' (Google APIs available)';
        }
        return output;
      });

      return print(humanized.join('\n'));
    }
  }
}
