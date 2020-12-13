import 'package:test/test.dart';
import 'package:virtual_device/src/android/avdmanager_cli.dart';

void main() {
  group('AvdmanagerCli', () {
    test('.parseDevicesOutput', () {
      final result = AvdmanagerCli.parseDevicesOutput(listAvd);
      expect(result, hasLength(2));
      expect(result.first, {
        'apiLevel': 28,
        'name': 'Pixel_API_28',
        'device': 'pixel (Google)',
        'target': 'Android API 28 Tag/ABI: google_apis/x86',
        'googleApis': true,
      });
      expect(result.last, {
        'apiLevel': 10,
        'name': 'Pixel_API_29',
        'device': 'pixel (Google)',
        'target': 'Android 2.3.3',
        'googleApis': false,
      });
    });

    test('.parseDeviceTypesOutput', () {
      final result = AvdmanagerCli.parseDeviceTypesOutput(listDevice);
      expect(result, hasLength(13));
      expect(result.first, {
        'id': 0,
        'idHumanized': 'tv_1080p',
        'name': 'Android TV (1080p)',
        'oem': 'Google',
      });
      expect(result.last, {
        'id': 34,
        'idHumanized': '10.1in WXGA (Tablet)',
        'name': '10.1" WXGA (Tablet)',
        'oem': 'Generic',
      });
    });

    test('.parseRuntimesOutput', () {
      final result = AvdmanagerCli.parseRuntimesOutput(listTargetOutput);
      expect(result.first, {
        'id': 1,
        'idHumanized': 'Google Inc.:Google APIs:15',
        'googleApis': true,
        'name': 'Google APIs, Android 15, rev 3',
        'apiLevel': 3,
      });
      expect(result.last, {
        'id': 9,
        'idHumanized': 'android-28',
        'googleApis': false,
        'name': 'Android API 28',
        'apiLevel': 28
      });
    });
  });
}

const listTargetOutput = '''Loading local repository...
[=========                              ] 25% Loading local repository...
[=========                              ] 25% Fetch remote repository...
[=========                              ] 25% Fetch remote repository...
[=========                              ] 25% Fetch remote repository...
[=======================================] 100% Fetch remote repository...
Available Android targets:
----------
id: 1 or "Google Inc.:Google APIs:15"
     Name: Google APIs
     Type: Add-On
     Vendor: Google Inc.
     Revision: 3
     Description: Google APIs, Android 15, rev 3
     Based on Android 4.0.3 (API level 15)
     Libraries:
      * com.google.android.media.effects (effects.jar)
          Collection of video effects
      * com.android.future.usb.accessory (usb.jar)
          API for USB Accessories
      * com.google.android.maps (maps.jar)
          API for Google Maps
----------
id: 2 or "android-15"
     Name: Android API 15
     Type: Platform
     API level: 15
     Revision: 5
----------
id: 3 or "android-19"
     Name: Android API 19
     Type: Platform
     API level: 19
     Revision: 4
----------
id: 4 or "android-21"
     Name: Android API 21
     Type: Platform
     API level: 21
     Revision: 2
----------
id: 5 or "Google Inc.:Google APIs:22"
     Name: Google APIs
     Type: Add-On
     Vendor: Google Inc.
     Revision: 1
     Description: Google APIs, Android 22
     Based on Android 5.1 (API level 22)
     Libraries:
      * com.google.android.media.effects (effects.jar)
          Collection of video effects
      * com.android.future.usb.accessory (usb.jar)
          API for USB Accessories
      * com.google.android.maps (maps.jar)
          API for Google Maps
----------
id: 6 or "android-22"
     Name: Android API 22
     Type: Platform
     API level: 22
     Revision: 2
----------
id: 7 or "android-23"
     Name: Android API 23
     Type: Platform
     API level: 23
     Revision: 3
----------
id: 8 or "android-27"
     Name: Android API 27
     Type: Platform
     API level: 27
     Revision: 3
----------
id: 9 or "android-28"
     Name: Android API 28
     Type: Platform
     API level: 28
     Revision: 6
''';

const listDevice =
    '''Parsing /Users/user/Library/Android/sdk/add-ons/addon-google_apis-google-15/package.xmlAvailable devices definitions:
id: 0 or "tv_1080p"
    Name: Android TV (1080p)
    OEM : Google
    Tag : android-tv
---------
id: 1 or "tv_720p"
    Name: Android TV (720p)
    OEM : Google
    Tag : android-tv
---------
id: 2 or "wear_round"
    Name: Android Wear Round
    OEM : Google
    Tag : android-wear
---------
id: 3 or "wear_round_chin_320_290"
    Name: Android Wear Round Chin
    OEM : Google
    Tag : android-wear
---------
id: 4 or "wear_square"
    Name: Android Wear Square
    OEM : Google
    Tag : android-wear
---------
id: 7 or "Nexus 4"
    Name: Nexus 4
    OEM : Google
---------
id: 22 or "3.2in HVGA slider (ADP1)"
    Name: 3.2" HVGA slider (ADP1)
    OEM : Generic
---------
id: 23 or "3.2in QVGA (ADP2)"
    Name: 3.2" QVGA (ADP2)
    OEM : Generic
---------
id: 24 or "3.3in WQVGA"
    Name: 3.3" WQVGA
    OEM : Generic
---------
id: 28 or "4in WVGA (Nexus S)"
    Name: 4" WVGA (Nexus S)
    OEM : Generic
---------
id: 29 or "4.65in 720p (Galaxy Nexus)"
    Name: 4.65" 720p (Galaxy Nexus)
    OEM : Generic
---------
id: 30 or "4.7in WXGA"
    Name: 4.7" WXGA
    OEM : Generic
---------
id: 34 or "10.1in WXGA (Tablet)"
    Name: 10.1" WXGA (Tablet)
    OEM : Generic
''';

const listAvd =
    '''Parsing /Users/user/Library/Android/sdk/add-ons/addon-google_apis-google-15/package.xmlAvailable Android Virtual Devices:
    Name: Pixel_API_28
  Device: pixel (Google)
    Path: /Users/user/.android/avd/Pixel_API_28.avd
  Target: Google APIs (Google Inc.)
          Based on: Android API 28 Tag/ABI: google_apis/x86
    Skin: pixel_silver
  Sdcard: 100M
---------
    Name: Pixel_API_29
  Device: pixel (Google)
    Path: /Users/user/.android/avd/Pixel_API_28.avd
  Target: Android 2.3.3 (API level 10)
    Skin: pixel_silver
  Sdcard: 100M

The following Android Virtual Devices could not be loaded:
    Name: Pixel_2_API_27
    Path: /Users/user/.android/avd/Pixel_2_API_27.avd
   Error: Google pixel_2 no longer exists as a device
---------
    Name: Pixel_2_API_28
    Path: /Users/user/.android/avd/Pixel_2_API_28.avd
   Error: Google pixel_2 no longer exists as a device
''';
