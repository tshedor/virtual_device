## Unreleased

## 0.0.3+1

* Expose `FlutterCli` in `virtual_device.dart`

## 0.0.3

* Added `FlutterCli` to parse running simulators as reported by `flutter devices`
* Added utils class `AdbCli` to abstract adb calls from `AndroidEmulator`
* Moved `--platform` to be a global option for all commands instead of a subcommand-level option

## 0.0.2

* Fix command line executable and improve help documentation
* Add `VirtualDevice#createOrStart` method to avoid duplicating existing simulators
* Add Android commands to the CLI tool
* Add `AvdmanagerCli` and `SimctlCli` to segment logic
* Add testing

## 0.0.1+1

* Better documentation and linted code

## 0.0.1

* Support iOS creation and retrieval from the command line
