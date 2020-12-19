import 'package:test/test.dart';
import 'package:virtual_device/src/cli_adapter.dart';

void main() {
  group('CliAdapter', () {
    group('.incrementNumber', () {
      test('no exsiting models', () {
        expect(CliAdapter.incrementForName([]), 1);
      });

      test('one exsiting model', () {
        final increment = CliAdapter.incrementForName([
          {'name': 'iPad Air 2:12.1:1'}
        ]);
        expect(increment, 2);
      });

      test('many exsiting models', () {
        final increment = CliAdapter.incrementForName([
          {'name': 'iPad Air 2:12.1:2'},
          {'name': 'iPad Air 2:12.1:1'},
          {'name': 'iPad Air 2:12.1:4'},
          {'name': 'iPad Air 2:12.1:3'},
        ]);
        expect(increment, 5);
      });
    });
  });
}
