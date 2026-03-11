import 'package:criteria/chips/chip_controllers.dart';
import 'package:flutter_test/flutter_test.dart';

class MockChipController extends ChipItemController {
  MockChipController()
    : super(chipType: ChipType.text, avatar: null, name: 'test');

  @override
  void clean() {}
  @override
  bool hasValue() => false;
  @override
  Null get value => null;
  @override
  set value(dynamic newValue) {}
  @override
  Map<String, dynamic> get toJson => {};
}

void main() {
  group('ChipItemController assertions', () {
    test(
      'Should throw assertion if setting chipWidth when expandable is true',
      () {
        final controller = MockChipController()..expandable = true;
        expect(
          () => controller.chipWidth = 100,
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'Should throw assertion if setting editingWidth when expandable is true',
      () {
        final controller = MockChipController()..expandable = true;
        expect(
          () => controller.editingWidth = 100,
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'Should throw assertion if setting expandable to true when chipWidth is set',
      () {
        final controller = MockChipController()..chipWidth = 100;
        expect(
          () => controller.expandable = true,
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'Should throw assertion if setting expandable to true when editingWidth is set',
      () {
        final controller = MockChipController()..editingWidth = 100;
        expect(
          () => controller.expandable = true,
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('Should allow setting widths when expandable is false', () {
      final controller = MockChipController()
        ..expandable = false
        ..chipWidth = 100
        ..editingWidth = 120;
      expect(controller.chipWidth, 100);
      expect(controller.editingWidth, 120);
    });

    test('Should allow setting expandable when widths are null', () {
      final controller = MockChipController()..expandable = true;
      expect(controller.expandable, true);
    });
  });
}
