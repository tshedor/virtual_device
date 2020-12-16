import 'package:test/test.dart';
import 'package:virtual_device/src/ios/simctl_cli.dart';
import 'package:virtual_device/src/virtual_device.dart';

void main() {
  group('SimctlCli', () {
    test('.parseDevicesOutput', () {
      final result = SimctlCli.parseDevicesOutput(listDevices);
      expect(result, hasLength(9));
      expect(result.first, {
        'model': 'iPad Retina',
        'name': 'iPad Retina',
        'os': OperatingSystem.iOS,
        'osVersion': '8.4',
        'status': 'Shutdown',
        'uuid': 'A1283403-6CBC-43EA-A69A-2FA1167337DC'
      });
      expect(result.last, {
        'model': 'Apple Watch Series 2 - 42mm',
        'name': 'Apple Watch Series 2 - 42mm',
        'os': OperatingSystem.watchOS,
        'osVersion': '5.1',
        'status': 'Shutdown',
        'uuid': '77943022-94F7-4E7D-9406-1CA874D82F55'
      });
    });

    test('.parseDeviceTypesOutput', () {
      final result = SimctlCli.parseDeviceTypesOutput(listDeviceTypes);
      expect(result, hasLength(39));
      expect(result['iPad Prod (12.9-inch) (3rd generation)'],
          'com.apple.CoreSimulator.SimDeviceType.iPad-Pro--12-9-inch---3rd-generation-');
      expect(result['Apple Watch - 42mm'],
          'com.apple.CoreSimulator.SimDeviceType.Apple-Watch-42mm');
    });

    test('.parseRuntimesOutput', () {
      final result = SimctlCli.parseRuntimesOutput(listRuntimesOutput);
      expect(result, hasLength(4));
      expect(result['iOS 8.4 (8.4 - 12H141)'],
          'com.apple.CoreSimulator.SimRuntime.iOS-8-4');
      expect(result['watchOS 5.1 (5.1 - 16R591)'],
          'com.apple.CoreSimulator.SimRuntime.watchOS-5-1');
    });
  });
}

const listRuntimesOutput = '''== Runtimes ==
iOS 8.4 (8.4 - 12H141) - com.apple.CoreSimulator.SimRuntime.iOS-8-4
iOS 12.1 (12.1 - 16B91) - com.apple.CoreSimulator.SimRuntime.iOS-12-1
tvOS 12.1 (12.1 - 16J602) - com.apple.CoreSimulator.SimRuntime.tvOS-12-1
watchOS 5.1 (5.1 - 16R591) - com.apple.CoreSimulator.SimRuntime.watchOS-5-1
''';

const listDeviceTypes = '''== Device Types ==
iPhone 4s (com.apple.CoreSimulator.SimDeviceType.iPhone-4s)
iPhone 5 (com.apple.CoreSimulator.SimDeviceType.iPhone-5)
iPhone 5s (com.apple.CoreSimulator.SimDeviceType.iPhone-5s)
iPhone 6 (com.apple.CoreSimulator.SimDeviceType.iPhone-6)
iPhone 6 Plus (com.apple.CoreSimulator.SimDeviceType.iPhone-6-Plus)
iPhone 6s (com.apple.CoreSimulator.SimDeviceType.iPhone-6s)
iPhone 6s Plus (com.apple.CoreSimulator.SimDeviceType.iPhone-6s-Plus)
iPhone 7 (com.apple.CoreSimulator.SimDeviceType.iPhone-7)
iPhone 7 Plus (com.apple.CoreSimulator.SimDeviceType.iPhone-7-Plus)
iPhone 8 (com.apple.CoreSimulator.SimDeviceType.iPhone-8)
iPhone 8 Plus (com.apple.CoreSimulator.SimDeviceType.iPhone-8-Plus)
iPhone SE (com.apple.CoreSimulator.SimDeviceType.iPhone-SE)
iPhone X (com.apple.CoreSimulator.SimDeviceType.iPhone-X)
iPhone Xs (com.apple.CoreSimulator.SimDeviceType.iPhone-XS)
iPhone Xs Max (com.apple.CoreSimulator.SimDeviceType.iPhone-XS-Max)
iPhone Xʀ (com.apple.CoreSimulator.SimDeviceType.iPhone-XR)
iPad 2 (com.apple.CoreSimulator.SimDeviceType.iPad-2)
iPad Retina (com.apple.CoreSimulator.SimDeviceType.iPad-Retina)
iPad Air (com.apple.CoreSimulator.SimDeviceType.iPad-Air)
iPad Air 2 (com.apple.CoreSimulator.SimDeviceType.iPad-Air-2)
iPad (5th generation) (com.apple.CoreSimulator.SimDeviceType.iPad--5th-generation-)
iPad Pro (9.7-inch) (com.apple.CoreSimulator.SimDeviceType.iPad-Pro--9-7-inch-)
iPad Pro (12.9-inch) (com.apple.CoreSimulator.SimDeviceType.iPad-Pro)
iPad Pro (12.9-inch) (2nd generation) (com.apple.CoreSimulator.SimDeviceType.iPad-Pro--12-9-inch---2nd-generation-)
iPad Pro (10.5-inch) (com.apple.CoreSimulator.SimDeviceType.iPad-Pro--10-5-inch-)
iPad (6th generation) (com.apple.CoreSimulator.SimDeviceType.iPad--6th-generation-)
iPad Pro (11-inch) (com.apple.CoreSimulator.SimDeviceType.iPad-Pro--11-inch-)
iPad Pro (12.9-inch) (3rd generation) (com.apple.CoreSimulator.SimDeviceType.iPad-Pro--12-9-inch---3rd-generation-)
Apple TV (com.apple.CoreSimulator.SimDeviceType.Apple-TV-1080p)
Apple TV 4K (com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-4K)
Apple TV 4K (at 1080p) (com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-1080p)
Apple Watch - 38mm (com.apple.CoreSimulator.SimDeviceType.Apple-Watch-38mm)
Apple Watch - 42mm (com.apple.CoreSimulator.SimDeviceType.Apple-Watch-42mm)
Apple Watch Series 2 - 38mm (com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-2-38mm)
Apple Watch Series 2 - 42mm (com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-2-42mm)
Apple Watch Series 3 - 38mm (com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-3-38mm)
Apple Watch Series 3 - 42mm (com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-3-42mm)
Apple Watch Series 4 - 40mm (com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-4-40mm)
Apple Watch Series 4 - 44mm (com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-4-44mm)
''';

const listDevices = '''== Devices ==
-- iOS 8.4 --
    iPad Retina (A1283403-6CBC-43EA-A69A-2FA1167337DC) (Shutdown)
    Resizable iPad (2E8CAD70-8830-4D4A-9FA5-40F8AAFC0B16) (Shutdown) (unavailable, device type profile not found)
-- iOS 12.1 --
    iPhone 5s (09F9F55E-D9ED-4FA5-9F13-67BB8874A3FE) (Shutdown)
    iPad Pro (10.5-inch) (937AAB50-D28E-4721-A584-635A929E4DFD) (Shutdown)
    iPad (6th generation) (F62706D4-FE76-495C-A112-23672A2F1687) (Shutdown)
    iPad Pro (12.9-inch) (3rd generation) (FA5BCAA6-D179-43AD-BD8B-94E729E42ADC) (Shutdown)
    iPad Air 2:12.1:1 (FA5BCAA6-D179-43AD-BD8B-94E729E42ADC) (Shutdown)
-- tvOS 12.1 --
    Apple TV (0154B31D-41E9-40A0-85C9-9A9E72FC136A) (Shutdown)
    Apple TV 4K (at 1080p) (466B9432-32F2-444F-8BB3-AF022C7A071F) (Shutdown)
-- watchOS 5.1 --
    Apple Watch Series 2 - 42mm (77943022-94F7-4E7D-9406-1CA874D82F55) (Shutdown)
-- Unavailable: com.apple.CoreSimulator.SimRuntime.iOS-10-3 --
    iPad Air 2 (F702DE98-6759-4A48-A581-B9B139F2D098) (Shutdown) (unavailable, runtime profile not found)
    iPad (5th generation) (4ABC5E70-6707-48B4-A24B-E90FD19DC08C) (Shutdown) (unavailable, runtime profile not found)
    iPad Pro (9.7 inch) (61CAD829-6914-4579-8528-EEFE76DC5611) (Shutdown) (unavailable, runtime profile not found)
    iPad Pro (12.9-inch) (2nd generation) (BD8BCD43-306E-45D5-8163-1CC6BF989BCD) (Shutdown) (unavailable, runtime profile not found)
    iPad Pro (10.5-inch) (AD16D4B6-0A52-4E5D-95F4-0AE92982A568) (Shutdown) (unavailable, runtime profile not found)
''';
