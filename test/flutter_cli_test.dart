import 'package:test/test.dart';
import 'package:virtual_device/src/flutter_cli.dart';
import 'package:virtual_device/virtual_device.dart';

void main() {
  group('FlutterDevice', () {
    group('.availableDevices', () {
      test('no devices', () {
        final results = FlutterCli.parseAvailableDevices(noDevices);
        expect(results, isEmpty);
      });

      group('one device', () {
        test('without generated name', () {
          final results = FlutterCli.parseAvailableDevices(oneDevice);
          expect(results.first.model, isNull);
          expect(results.first.name, 'iPad Air 2 (mobile)');
          expect(results.first.uuid, 'ABDJ29301-1B3H-JD93-BF12-12J2J2J2J48S');
          expect(results.first.os, OperatingSystem.iOS);
          expect(results.first.osVersion, '12.1');
        });

        test('created by VirtualDevice', () {
          final results = FlutterCli.parseAvailableDevices(withGeneratedName);
          expect(results.first.model, 'iPad Air 2');
          expect(results.first.osVersion, '12.1');
        });
      });

      test('multiple devices', () {
        final results = FlutterCli.parseAvailableDevices(multiDevices);
        expect(results.first.osVersion, '25');
        expect(results.first.uuid, 'emulator-5554');
        expect(results.last.uuid, 'ABDJ29301-1B3H-JD93-BF12-12J2J2J2J48S');
      });
    });
  });
}

const multiDevices = '''2 connected devices:

Android SDK built for x86 (mobile) • emulator-5554                         • android-x86 • Android 7.1.0 (API 25) (emulator)
iPad Air 2 (mobile)                • ABDJ29301-1B3H-JD93-BF12-12J2J2J2J48S • ios         • com.apple.CoreSimulator.SimRuntime.iOS-12-1 (simulator)

• Error: iPad Air 2:12.:1 is not connected. Xcode will continue when iPad Air 2:12.1:1 is connected. (code -13)
''';

const oneDevice = '''1 connected device:

iPad Air 2 (mobile) • ABDJ29301-1B3H-JD93-BF12-12J2J2J2J48S • ios • com.apple.CoreSimulator.SimRuntime.iOS-12-1 (simulator)

• Error: iPad Air 2:12.1:1 is not connected. Xcode will continue when iPad Air 2:12.1:1 is connected. (code -13)
''';

const withGeneratedName = '''1 connected device:

iPad Air 2:12.1:1 (mobile) • ABDJ29301-1B3H-JD93-BF12-12J2J2J2J48S • ios • com.apple.CoreSimulator.SimRuntime.iOS-12-1 (simulator)

• Error: iPad Air 2:14.1:1 is not connected. Xcode will continue when iPad Air 2:12.1:1 is connected. (code -13)
''';

const noDevices = '''No devices detected.

Run "flutter emulators" to list and start any available device emulators.

If you expected your device to be detected, please run "flutter doctor" to diagnose potential issues. You may also try increasing the time to wait for connected devices with the --device-timeout flag. Visit https://flutter.dev/setup/ for troubleshooting tips.
''';
