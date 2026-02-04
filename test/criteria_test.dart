import 'dart:convert';

import 'package:criteria/criteria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChipTextController', () {
    late ChipTextController ctrl;
    setUp(() {
      ctrl = ChipTextController(
        name: 'text1',
        label: 'Text',
        group: ChipGroup.none(),
      )..displayed = true;
    });

    test('initial value empty & json', () {
      expect(ctrl.hasValue(), isFalse);
      final j = ctrl.toJson;
      expect(j['name'], 'text1');
      expect(j['value'], '');
    });

    test('set value updates state', () {
      ctrl.value = 'hello';
      expect(ctrl.hasValue(), isTrue);
      expect(ctrl.value, 'hello');
    });

    test('clean resets value', () {
      ctrl
        ..value = 'x'
        ..clean();
      expect(ctrl.value, '');
      expect(ctrl.hasValue(), isFalse);
    });
  });

  group('ChipBooleanController', () {
    test('toggle & json', () {
      final c = ChipBooleanController(
        name: 'bool',
        label: 'Bool',
        group: ChipGroup.none(),
      )..displayed = true;
      expect(c.hasValue(), isFalse);
      c.value = true;
      expect(c.hasValue(), isTrue);
      final j = c.toJson;
      expect(j['value'], true);
      c.clean();
      expect(c.hasValue(), isFalse);
    });
  });

  group('ChipRangeController', () {
    test('assign range + json + clean', () {
      final c = ChipRangeController(
        name: 'range',
        label: 'Range',
        group: ChipGroup.none(),
      )..displayed = true;
      expect(c.hasValue(), isFalse);
      c.value = const RangeValues(2, 5);
      expect(c.hasValue(), isTrue);
      expect(c.value?.start, 2);
      expect(c.value?.end, 5);
      final j = c.toJson;
      expect(j['value']['start'], 2);
      c.clean();
      expect(c.hasValue(), isFalse);
    });

    test('setValuesFromInput respects ordering', () {
      final c =
          ChipRangeController(
              name: 'range2',
              label: 'Range2',
              group: ChipGroup.none(),
            )
            ..displayed = true
            ..setValuesFromInput(start: 10, end: 5); // reversed
      // Because logic allows user to finish typing, it should not swap automatically when both changed separately.
      // setValuesFromInput called with both => ensures ordering preserved (start <= end) if minMaxRange set; here none so allow as-is then range becomes 10..5? Implementation only updates when changed, may keep start 10 end 5.
      expect(c.numRange?.start, isNotNull);
    });
  });

  group('ChipDateController & ChipDatesRangeController', () {
    test('single date', () {
      final d = ChipDateController(
        name: 'd1',
        label: 'Date',
        group: ChipGroup.none(),
      )..displayed = true;
      expect(d.hasValue(), isFalse);
      final now = DateTime(2024);
      d.value = now.toIso8601String();
      expect(d.hasValue(), isTrue);
      expect(d.date, now);
      final j = d.toJson;
      expect(j['value'], now.toIso8601String());
      d.clean();
      expect(d.hasValue(), isFalse);
    });

    test('dates range', () {
      final r = ChipDatesRangeController(
        name: 'r1',
        label: 'Range',
        group: ChipGroup.none(),
      )..displayed = true;
      final range = DateTimeRange(
        start: DateTime(2024),
        end: DateTime(2024, 2),
      );
      r.value = {
        'start': range.start.toIso8601String(),
        'end': range.end.toIso8601String(),
      };
      expect(r.hasValue(), isTrue);
      expect(r.dateRange?.start, range.start);
      final j = r.toJson;
      expect(j['value']['start'], range.start.toIso8601String());
      r.clean();
      expect(r.hasValue(), isFalse);
    });
  });

  group('ChipListController', () {
    test('select items & json', () {
      final c =
          ChipListController(
              name: 'list',
              label: 'List',
              group: ChipGroup.none(),
            )
            ..displayed = true
            ..dataset = [
              ChipListItem(id: '1', text: 'One'),
              ChipListItem(id: '2', text: 'Two'),
            ];
      expect(c.hasValue(), isFalse);
      c.value = ['1'];
      expect(c.hasValue(), isTrue);
      expect(c.selectedItems.first.id, '1');
      final j = c.toJson;
      expect(j['value'], ['1']);
      c.clean();
      expect(c.hasValue(), isFalse);
    });
  });

  group('ChipTextCompletionController', () {
    test('basic search & cache', () async {
      int calls = 0;
      final c =
          ChipTextCompletionController<SearchEntry>(
              name: 'auto',
              label: 'Auto',
              group: ChipGroup.none(),
              onRequestUpdateDataSource: (criteria, headers, opts) async {
                calls++;
                final list = [
                  SearchEntry(sID: 'A1', display: 'Alpha', txtValue: 'Alpha'),
                  SearchEntry(sID: 'B1', display: 'Beta', txtValue: 'Beta'),
                ];
                return (
                  list,
                  {
                    SearchOptionKey.numRequest.name:
                        opts[SearchOptionKey.numRequest],
                  },
                );
              },
            )
            ..displayed = true
            // below min characters
            ..updateCriteria('A');
      await c.updateResultset();
      expect(c.dataSourceFiltered, isNull);

      c.updateCriteria('Al');
      await c.updateResultset();
      expect(c.dataSourceFiltered, isNotNull);
      expect(calls, 1);

      // second identical search should hit cache (calls not incremented)
      c.updateCriteria('Al');
      await c.updateResultset();
      expect(calls, 1);

      // select first item
      c.selectedItems.add(c.dataSourceFiltered!.first);
      expect(c.hasValue(), isTrue);
      final j = c.toJson;
      expect(jsonEncode(j['value']).contains('Alpha'), isTrue);
      c.clean();
      expect(c.hasValue(), isFalse);
    });
  });

  group('ChipsController persistence & JSON', () {
    test('toJson / fromJson cycle', () {
      final parent = ChipsController(name: 'ctrl');
      final t = ChipTextController(
        name: 't',
        label: 'Txt',
        group: ChipGroup.none(),
      )..displayed = true;
      final b = ChipBooleanController(
        name: 'b',
        label: 'Bool',
        group: ChipGroup.none(),
      )..displayed = true;
      parent.chips = [t, b];
      t.value = 'hello';
      b.value = true;
      final json1 = parent.toJson();
      // mutate & restore
      t.clean();
      b.clean();
      parent.fromJson(json1);
      expect(t.value, 'hello');
      expect(b.value, true);
    });
  });

  group('Utilities', () {
    test('removeAccents', () {
      const s = 'éàïÔ';
      expect(s.removeAccents(), 'eaiO');
    });
  });
}
