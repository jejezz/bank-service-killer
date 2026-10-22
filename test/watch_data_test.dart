import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _d = WatchDefaults(
  groupA: '보안 무관',
  groupB: '웹 플러그인',
  groupC: '드라이버 연동',
  bankingMode: '뱅킹',
  devMode: '개발',
);

void main() {
  group('v1 마이그레이션', () {
    test('group A/B/C 가 카테고리로 옮겨지고, 뱅킹은 A 를 건드리지 않고 개발은 전부 끈다', () {
      final data = WatchData.fromJson([
        {'name': 'Nahimic service', 'group': 'A', 'note': 'x'},
        {'name': 'AnySign', 'group': 'B'},
        {'name': 'nxTS', 'group': 'C'},
      ], defaults: _d);
      expect(data.categories, ['보안 무관', '웹 플러그인', '드라이버 연동']);
      expect(data.items.map((i) => i.categories), [
        ['보안 무관'],
        ['웹 플러그인'],
        ['드라이버 연동'],
      ]);
      expect(data.items.first.note, 'x');
      final banking = data.modeNamed('뱅킹')!;
      expect(banking.on, ['웹 플러그인', '드라이버 연동']);
      expect(banking.keep, ['보안 무관']);
      expect(banking.revertMinutes, 30);
      final dev = data.modeNamed('개발')!;
      expect(dev.on, isEmpty);
      expect(dev.keep, isEmpty);
      expect(data.defaultMode, '개발');
    });

    test('알 수 없는 group 은 그 글자 그대로 카테고리가 된다', () {
      final data = WatchData.fromJson([
        {'name': 'x', 'group': 'Z'},
      ], defaults: _d);
      expect(data.categories, ['Z']);
    });
  });

  group('v2 마이그레이션', () {
    test('뱅킹 카테고리는 뱅킹 모드의 on, 나머지는 keep 이 된다', () {
      final data = WatchData.fromJson({
        'version': 2,
        'categories': ['a', 'b', 'c'],
        'bankingCategories': ['a', 'b'],
        'items': [
          {'name': 'x', 'categories': ['a']},
        ],
      }, defaults: _d);
      final banking = data.modeNamed('뱅킹')!;
      expect(banking.on, ['a', 'b']);
      expect(banking.keep, ['c']);
      expect(data.modeNamed('개발')!.on, isEmpty);
      expect(data.defaultMode, '개발');
    });

    test('bankingCategories 가 없으면 전부 뱅킹 모드 대상이다', () {
      final data = WatchData.fromJson({
        'version': 2,
        'categories': ['a'],
        'items': [
          {'name': 'x', 'categories': ['a', 'b']},
        ],
      }, defaults: _d);
      expect(data.categories, ['a', 'b']);
      expect(data.modeNamed('뱅킹')!.on, ['a', 'b']);
      expect(data.modeNamed('뱅킹')!.keep, isEmpty);
    });
  });

  group('v3', () {
    WatchData sample() => WatchData(
          categories: ['키보드보안', '공인인증'],
          items: [
            const WatchItem('a', categories: ['키보드보안', '공인인증'], note: 'n'),
            const WatchItem('b'),
          ],
          modes: [
            const WatchMode('뱅킹', on: ['공인인증'], keep: ['키보드보안'], revertMinutes: 20),
            const WatchMode('개발'),
          ],
          defaultMode: '개발',
        );

    test('저장 후 다시 읽어도 같다', () {
      final back = WatchData.fromJson(sample().toJson(), defaults: _d);
      expect(back.categories, ['키보드보안', '공인인증']);
      expect(back.modes.map((m) => m.name), ['뱅킹', '개발']);
      expect(back.modeNamed('뱅킹')!.on, ['공인인증']);
      expect(back.modeNamed('뱅킹')!.keep, ['키보드보안']);
      expect(back.modeNamed('뱅킹')!.revertMinutes, 20);
      expect(back.defaultMode, '개발');
      expect(back.items[0].categories, ['키보드보안', '공인인증']);
      expect(back.items[1].categories, isEmpty);
    });

    test('모드가 가리키는 없는 카테고리와 없는 기본 모드는 바로잡힌다', () {
      final d = WatchData(
        categories: ['a'],
        items: const [],
        modes: [const WatchMode('m', on: ['a', 'ghost'])],
        defaultMode: 'nope',
      );
      expect(d.modeNamed('m')!.on, ['a']);
      expect(d.defaultMode, 'm');
    });
  });

  group('카테고리 편집', () {
    WatchData sample() => WatchData(
          categories: ['k', 'c'],
          items: [
            const WatchItem('a', categories: ['k']),
            const WatchItem('b', categories: ['k', 'c']),
          ],
          modes: [
            const WatchMode('m', on: ['k'], keep: ['c']),
          ],
        );

    test('이름 바꾸기는 항목과 모드도 바꾼다', () {
      final d = sample();
      expect(d.renameCategory('k', 'kb'), isTrue);
      expect(d.categories, ['kb', 'c']);
      expect(d.modeNamed('m')!.on, ['kb']);
      expect(d.items[1].categories, ['kb', 'c']);
    });

    test('겹치는 이름·빈 이름으로는 바꿀 수 없다', () {
      final d = sample();
      expect(d.renameCategory('k', 'c'), isFalse);
      expect(d.renameCategory('k', '  '), isFalse);
      expect(d.categories, ['k', 'c']);
    });

    test('삭제는 항목을 남기고 카테고리·모드에서만 뺀다', () {
      final d = sample()..deleteCategory('k');
      expect(d.categories, ['c']);
      expect(d.modeNamed('m')!.on, isEmpty);
      expect(d.modeNamed('m')!.keep, ['c']);
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
  });

  group('모드 편집', () {
    WatchData sample() => WatchData(
          categories: ['a'],
          items: const [],
          modes: [const WatchMode('뱅킹', on: ['a']), const WatchMode('개발')],
          defaultMode: '개발',
        );

    test('추가는 중복·빈 이름을 막는다', () {
      final d = sample();
      expect(d.addMode(const WatchMode('뱅킹')), isFalse);
      expect(d.addMode(const WatchMode(' ')), isFalse);
      expect(d.addMode(const WatchMode(' 증권 ', on: ['a'])), isTrue);
      expect(d.modes.last.name, '증권');
    });

    test('기본 모드 이름을 바꾸면 기본 모드도 따라간다', () {
      final d = sample();
      expect(d.updateMode('개발', const WatchMode('개발용')), isTrue);
      expect(d.defaultMode, '개발용');
      expect(d.updateMode('개발용', const WatchMode('뱅킹')), isFalse);
    });

    test('기본 모드를 지우면 첫 모드가 기본이 되고, 마지막 하나는 지울 수 없다', () {
      final d = sample();
      expect(d.deleteMode('개발'), isTrue);
      expect(d.defaultMode, '뱅킹');
      expect(d.deleteMode('뱅킹'), isFalse);
      expect(d.modes.length, 1);
    });

    test('기본 모드 지정', () {
      final d = sample();
      expect(d.setDefaultMode('뱅킹'), isTrue);
      expect(d.defaultMode, '뱅킹');
      expect(d.setDefaultMode('없음'), isFalse);
    });
  });

  test('새로 설치했을 때의 시작 데이터는 서비스가 없고 뱅킹·개발 모드만 있다', () {
    final d = WatchData.initial(_d);
    expect(d.items, isEmpty);
    expect(d.categories, isEmpty);
    expect(d.modes.map((m) => m.name), ['뱅킹', '개발']);
    expect(d.modeNamed('뱅킹')!.revertMinutes, 30);
    expect(d.defaultMode, '개발');
  });
}
