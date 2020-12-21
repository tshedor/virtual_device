import 'package:test/test.dart';
import 'package:virtual_device/src/ios/simctl_cli.dart';
import 'package:virtual_device/src/virtual_device.dart';

void main() {
  group('SimctlCli', () {
    test('.parseDevicesOutput', () {
      final result = SimctlCli.parseDevicesOutput(listDevices).toList();
      expect(result, hasLength(7));
      expect(result[2], {
        'model': 'iPhone 5s',
        'name': 'iPhone 5s',
        'os': OperatingSystem.iOS,
        'osVersion': '12.1',
        'status': 'Shutdown',
        'uuid': '09F9F55E-D9ED-4FA5-9F13-67BB8874A3FE'
      });
      expect(result.first, {
        'model': 'iPhone 5s',
        'name': 'iPhone 5s',
        'os': OperatingSystem.iOS,
        'osVersion': '12.0',
        'status': 'Shutdown',
        'uuid': '09F9F55E-D9ED-4FA5-9F13-67BB8874A3FE'
      });
      expect(result.last, {
        'model': 'Apple TV 4K (at 1080p)',
        'name': 'Apple TV 4K (at 1080p)',
        'os': OperatingSystem.tvOS,
        'osVersion': '12.1',
        'status': 'Shutdown',
        'uuid': '466B9432-32F2-444F-8BB3-AF022C7A071F'
      });
    });

    test('.parseDeviceTypesOutput', () {
      final result = SimctlCli.parseDeviceTypesOutput(listDeviceTypes);
      expect(result, hasLength(9));
      expect(result['iPad Pro (9.7-inch)'],
          'com.apple.CoreSimulator.SimDeviceType.iPad-Pro--9-7-inch-');
      expect(result['Apple Watch - 42mm'],
          'com.apple.CoreSimulator.SimDeviceType.Apple-Watch-42mm');
    });

    test('.parseRuntimesOutput', () {
      final result = SimctlCli.parseRuntimesOutput(listRuntimesOutput);
      expect(result, hasLength(3));
      expect(result['iOS'], hasLength(2));
      expect(
          result['iOS']['8.4'], 'com.apple.CoreSimulator.SimRuntime.iOS-8-4');
      expect(result['watchOS']['5.1'],
          'com.apple.CoreSimulator.SimRuntime.watchOS-5-1');
    });
  });
}

const listRuntimesOutput = '''{
  "runtimes" : [
    {
      "bundlePath" : "\/Library\/Developer\/CoreSimulator\/Profiles\/Runtimes\/iOS 8.4.simruntime",
      "availabilityError" : "",
      "buildversion" : "12H141",
      "availability" : "(available)",
      "isAvailable" : true,
      "identifier" : "com.apple.CoreSimulator.SimRuntime.iOS-8-4",
      "version" : "8.4",
      "name" : "iOS 8.4"
    },
    {
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/iPhoneOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/Runtimes\/iOS.simruntime",
      "availabilityError" : "",
      "buildversion" : "16B91",
      "availability" : "(available)",
      "isAvailable" : true,
      "identifier" : "com.apple.CoreSimulator.SimRuntime.iOS-12-1",
      "version" : "12.1",
      "name" : "iOS 12.1"
    },
    {
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/AppleTVOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/Runtimes\/tvOS.simruntime",
      "availabilityError" : "",
      "buildversion" : "16J602",
      "availability" : "(available)",
      "isAvailable" : true,
      "identifier" : "com.apple.CoreSimulator.SimRuntime.tvOS-12-1",
      "version" : "12.1",
      "name" : "tvOS 12.1"
    },
    {
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/WatchOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/Runtimes\/watchOS.simruntime",
      "availabilityError" : "",
      "buildversion" : "16R591",
      "availability" : "(available)",
      "isAvailable" : true,
      "identifier" : "com.apple.CoreSimulator.SimRuntime.watchOS-5-1",
      "version" : "5.1",
      "name" : "watchOS 5.1"
    }
  ]
}
''';

const listDeviceTypes = '''{
  "devicetypes" : [
    {
      "name" : "iPhone 4s",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/iPhoneOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/iPhone 4s.simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-4s"
    },
    {
      "name" : "iPhone 5",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/iPhoneOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/iPhone 5.simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-5"
    },
    {
      "name" : "iPad (5th generation)",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/iPhoneOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/iPad (5th generation).simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.iPad--5th-generation-"
    },
    {
      "name" : "iPad Pro (9.7-inch)",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/iPhoneOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/iPad Pro (9.7-inch).simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.iPad-Pro--9-7-inch-"
    },
    {
      "name" : "Apple TV",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/AppleTVOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/Apple TV.simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.Apple-TV-1080p"
    },
    {
      "name" : "Apple TV 4K",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/AppleTVOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/Apple TV 4K.simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-4K"
    },
    {
      "name" : "Apple TV 4K (at 1080p)",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/AppleTVOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/Apple TV 4K (at 1080p).simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.Apple-TV-4K-1080p"
    },
    {
      "name" : "Apple Watch - 38mm",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/WatchOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/Apple Watch - 38mm.simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.Apple-Watch-38mm"
    },
    {
      "name" : "Apple Watch - 42mm",
      "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/WatchOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/DeviceTypes\/Apple Watch - 42mm.simdevicetype",
      "identifier" : "com.apple.CoreSimulator.SimDeviceType.Apple-Watch-42mm"
    }
  ]
}
''';

const listDevices = '''{
  "devices" : {
    "com.apple.CoreSimulator.SimRuntime.iOS-12-0" : [
      {
        "availability" : "(unavailable, runtime profile not found)",
        "state" : "Shutdown",
        "isAvailable" : false,
        "name" : "iPhone 5s",
        "udid" : "3ACF3FA8-CA90-490E-B177-6C96827B26AB",
        "availabilityError" : "runtime profile not found"
      }
    ],
    "iOS 12.1" : [
      {
        "availability" : "(available)",
        "state" : "Shutdown",
        "isAvailable" : true,
        "name" : "iPhone 5s",
        "udid" : "09F9F55E-D9ED-4FA5-9F13-67BB8874A3FE",
        "availabilityError" : ""
      },
      {
        "availability" : "(available)",
        "state" : "Shutdown",
        "isAvailable" : true,
        "name" : "iPhone 6",
        "udid" : "25130F1E-E829-413E-A57F-C5FB000BF812",
        "availabilityError" : ""
      }
    ],
    "com.apple.CoreSimulator.SimRuntime.iOS-12-0" : [
      {
        "availability" : "(available)",
        "state" : "Shutdown",
        "isAvailable" : true,
        "name" : "iPhone 5s",
        "udid" : "09F9F55E-D9ED-4FA5-9F13-67BB8874A3FE",
        "availabilityError" : ""
      },
      {
        "availability" : "(available)",
        "state" : "Shutdown",
        "isAvailable" : true,
        "name" : "iPhone 6",
        "udid" : "25130F1E-E829-413E-A57F-C5FB000BF812",
        "availabilityError" : ""
      }
    ],
    "com.apple.CoreSimulator.SimRuntime.tvOS-9-2" : [
      {
        "availability" : "(unavailable, runtime profile not found)",
        "state" : "Shutdown",
        "isAvailable" : false,
        "name" : "Apple TV 1080p",
        "udid" : "B7EBA2D0-6220-4519-BE03-EF6ED88FE4C1",
        "availabilityError" : "runtime profile not found"
      }
    ],
    "tvOS 12.1" : [
      {
        "availability" : "(available)",
        "state" : "Shutdown",
        "isAvailable" : true,
        "name" : "Apple TV",
        "udid" : "0154B31D-41E9-40A0-85C9-9A9E72FC136A",
        "availabilityError" : ""
      },
      {
        "availability" : "(available)",
        "state" : "Shutdown",
        "isAvailable" : true,
        "name" : "Apple TV 4K",
        "udid" : "0A721045-1FC7-447A-8201-B337FC0A7BBA",
        "availabilityError" : ""
      },
      {
        "availability" : "(available)",
        "state" : "Shutdown",
        "isAvailable" : true,
        "name" : "Apple TV 4K (at 1080p)",
        "udid" : "466B9432-32F2-444F-8BB3-AF022C7A071F",
        "availabilityError" : ""
      }
    ],
    "com.apple.CoreSimulator.SimRuntime.iOS-9-2" : [
      {
        "availability" : "(unavailable, runtime profile not found)",
        "state" : "Shutdown",
        "isAvailable" : false,
        "name" : "iPhone 4s",
        "udid" : "30AEBD15-2864-4852-BEA1-E535B7BD9254",
        "availabilityError" : "runtime profile not found"
      },
      {
        "availability" : "(unavailable, runtime profile not found)",
        "state" : "Shutdown",
        "isAvailable" : false,
        "name" : "iPhone 5",
        "udid" : "F7AC90A6-C50D-4188-A14E-06555CC611A4",
        "availabilityError" : "runtime profile not found"
      }
    ]
  }
}
''';
