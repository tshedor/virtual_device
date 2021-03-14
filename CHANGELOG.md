## Unreleased

## 1.0.0

* Null safety is stable

## 1.0.0-nullsafety.0

* Migrate to sound null safety

## 0.0.5+1

* Fix iOS simulator discovery when runtime is specified by `simctl` instead of a humanized OS/version

## 0.0.5

* Fix device naming incrementor in `CliAdapter`
* Remove `AndroidEmulator#emulatorId` in favor of assigning a running emulator ID to `AndroidEmulator#uuid`
* Improve CLI documentation. Throw errors for missing, required options.
* Rename `create --osVersion` to `create --os-version` for naming consistency with other options

## 0.0.4

* Reassign UUID in `IosSimulator` when starting
* Format new availableRuntimes output
* Parse simctl with JSON

## 0.0.3+1

* Expose `FlutterCli` in `virtual_device.dart`
* Revise `IosSimulator.availableRuntimes` to return a nested map: `{ os: {osVersion: runtime} }`

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
