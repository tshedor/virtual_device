import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:virtual_device/src/executable/create_command.dart';
import 'package:virtual_device/src/executable/delete_command.dart';
import 'package:virtual_device/src/executable/list_command.dart';
import 'package:virtual_device/src/executable/start_command.dart';
import 'package:virtual_device/src/executable/stop_command.dart';
import 'package:virtual_device/src/executable/wipe_command.dart';

void main(List<String> args) async {
  final runner = CommandRunner(
    'virtual_device',
    'Manage iOS simulators and Android emulators from the command line',
  )
    ..addCommand(CreateCommand())
    ..addCommand(DeleteCommand())
    ..addCommand(ListCommand())
    ..addCommand(StartCommand())
    ..addCommand(StopCommand())
    ..addCommand(WipeCommand());

  await runner.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64);
  });
}
