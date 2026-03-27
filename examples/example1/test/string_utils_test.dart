import 'package:flutter_test/flutter_test.dart';
import 'package:criteria/utils/string_extensions.dart';

void main() {
  group('StringSearchExtension tests', () {
    test('toSearchable removes common French accents', () {
      expect('Léo'.toSearchable(), equals('leo'));
      expect('Chloé'.toSearchable(), equals('chloe'));
      expect('Inès'.toSearchable(), equals('ines'));
      expect('Léa'.toSearchable(), equals('lea'));
      expect('Zoé'.toSearchable(), equals('zoe'));
      expect('Français'.toSearchable(), equals('francais'));
    });

    test('toSearchable is case-insensitive', () {
      expect('LÉO'.toSearchable(), equals('leo'));
      expect('CHLOÉ'.toSearchable(), equals('chloe'));
    });

    test('toSearchable handles strings with no accents', () {
      expect('Lucas'.toSearchable(), equals('lucas'));
      expect('Sophie'.toSearchable(), equals('sophie'));
    });

    test('contains check works with common search terms', () {
      var source = 'FONTAINE Léo'.toSearchable();
      expect(source.contains('léo'.toSearchable()), isTrue);
      expect(source.contains('leo'.toSearchable()), isTrue);
      expect(source.contains('font'.toSearchable()), isTrue);
    });
  });
}
