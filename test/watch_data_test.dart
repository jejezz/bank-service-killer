import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _groups = {'A': '보안 무관', 'B': '웹 플러그인', 'C': '드라이버 연동'};

void main() {
  group('v1 마이그레이션', () {
    test('group A/B/C 가 카테고리 이름으로 옮겨지고 A 는 뱅킹 모드에서 빠진다', () {
      final data = WatchData.fromJson([
        {'name': 'Nahimic service', 'group': 'A', 'note': 'x'},
        {'name': 'AnySign', 'group': 'B'},
        {'name': 'nxTS', 'group': 'C'},
      ], legacyGroups: _groups);
      expect(data.categories, ['보안 무관', '웹 플러그인', '드라이버 연동']);
      expect(data.items.map((i) => i.categories), [
        ['보안 무관'],
        ['웹 플러그인'],
        ['드라이버 연동'],
      ]);
      expect(data.items.first.note, 'x');
      expect(data.bankingCategories, ['웹 플러그인', '드라이버 연동']);
    });

    test('알 수 없는 group 은 그 글자 그대로 카테고리가 된다', () {
      final data = WatchData.fromJson([
        {'name': 'x', 'group': 'Z'},
      ], legacyGroups: _groups);
      expect(data.categories, ['Z']);
    });
  });

  group('v2', () {
    test('저장 후 다시 읽어도 같다', () {
      final data = WatchData(
        categories: ['키보드보안', '공인인증'],
        items: [
          const WatchItem('a', categories: ['키보드보안', '공인인증'], note: 'n'),
          const WatchItem('b'),
        ],
        bankingCategories: ['공인인증'],
      );
      final back = WatchData.fromJson(data.toJson(), legacyGroups: _groups);
      expect(back.categories, data.categories);
      expect(back.bankingCategories, ['공인인증']);
      expect(back.items[0].categories, ['키보드보안', '공인인증']);
      expect(back.items[1].categories, isEmpty);
    });

    test('항목이 쓰는데 목록에 없는 카테고리는 보충된다', () {
      final data = WatchData.fromJson({
        'version': 2,
        'categories': ['a'],
        'items': [
          {'name': 'x', 'categories': ['a', 'b']},
        ],
      }, legacyGroups: _groups);
      expect(data.categories, ['a', 'b']);
      // bankingCategories 가 없으면 전부 뱅킹 모드.
      expect(data.bankingCategories, ['a', 'b']);
    });
  });

  group('카테고리 편집', () {
    WatchData sample() => WatchData(
          categories: ['k', 'c'],
          items: [
            const WatchItem('a', categories: ['k']),
            const WatchItem('b', categories: ['k', 'c']),
          ],
          bankingCategories: ['k'],
        );

    test('이름 바꾸기는 항목과 뱅킹 모드 설정도 바꾼다', () {
      final d = sample();
      expect(d.renameCategory('k', 'kb'), isTrue);
      expect(d.categories, ['kb', 'c']);
      expect(d.bankingCategories, ['kb']);
      expect(d.items[1].categories, ['kb', 'c']);
    });

    test('겹치는 이름·빈 이름으로는 바꿀 수 없다', () {
      final d = sample();
      expect(d.renameCategory('k', 'c'), isFalse);
      expect(d.renameCategory('k', '  '), isFalse);
      expect(d.categories, ['k', 'c']);
    });

    test('삭제는 항목을 남기고 카테고리에서만 뺀다', () {
      final d = sample()..deleteCategory('k');
      expect(d.categories, ['c']);
      expect(d.bankingCategories, isEmpty);
      expect(d.items.map((i) => i.name), ['a', 'b']);
      expect(d.items[0].categories, isEmpty);
      expect(d.uncategorizedCount, 1);
    });

    test('추가는 중복·빈 이름을 막고 개수를 센다', () {
      final d = sample();
      expect(d.addCategory('k'), isFalse);
      expect(d.addCategory(' '), isFalse);
      expect(d.addCategory(' 새 '), isTrue);
      expect(d.categories.last, '새');
      expect(d.countIn('k'), 2);
      expect(d.countIn('c'), 1);
    });

    test('뱅킹 모드 대상 판정', () {
      final d = sample();
      expect(d.isInBankingMode(d.items[0]), isTrue);
      d.setBanking('k', false);
      expect(d.isInBankingMode(d.items[1]), isFalse);
      d.setBanking('c', true);
      expect(d.isInBankingMode(d.items[1]), isTrue);
    });
  });

  test('기본 목록은 14개이고 Nahimic 만 뱅킹 모드에서 빠진다', () {
    final d = WatchData.defaults(_groups);
    expect(d.items.length, 14);
    final out = d.items.where((i) => !d.isInBankingMode(i)).map((i) => i.name);
    expect(out, ['Nahimic service']);
  });
}
