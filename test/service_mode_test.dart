import 'package:bank_service_killer/mode_engine.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _d = WatchDefaults(
  groupA: '보안 무관',
  groupB: '웹 플러그인',
  groupC: '드라이버 연동',
  bankingMode: '뱅킹',
  devMode: '개발',
);

WatchItem _i(String name, [List<String> cats = const []]) => WatchItem(name, categories: cats);

ItemState _s(String name, List<String> cats, bool? running) => ItemState(_i(name, cats), running);

void main() {
  group('wantFor 우선순위', () {
    test('서비스를 직접 정한 값이 카테고리보다 우선한다', () {
      const m = WatchMode(
        'm',
        on: ['보안'],
        keep: ['오디오'],
        services: {'a': Want.off, 'b': Want.on, 'c': Want.keep},
      );
      expect(wantFor(m, _i('A', ['보안'])), Want.off, reason: '카테고리는 켜기지만 서비스는 끄기');
      expect(wantFor(m, _i('B', ['오디오'])), Want.on, reason: '카테고리는 그대로지만 서비스는 켜기');
      expect(wantFor(m, _i('C', ['보안'])), Want.keep);
      expect(wantFor(m, _i('D', ['보안'])), Want.on, reason: '직접 정하지 않았으면 카테고리를 따른다');
      expect(wantFor(m, _i('E')), Want.off);
    });

    test('서비스 이름은 대소문자를 가리지 않는다', () {
      const m = WatchMode('m', services: {'anysign4pc launcher': Want.on});
      expect(wantFor(m, _i('AnySign4PC Launcher')), Want.on);
    });

    test('카테고리 없이 서비스만으로 만든 작은 모드', () {
      const m = WatchMode('○○은행', services: {'veraport': Want.on, 'anysign': Want.on, 'nxfirewall': Want.on, 'nxkey': Want.on});
      final states = [
        _s('VeraPort', [], false),
        _s('AnySign', [], false),
        _s('nxFirewall', [], true),
        _s('nxKey', [], false),
        _s('Other', [], true), // 나머지 감시 서비스는 끈다
      ];
      final plan = planFor(m, states);
      expect(plan.start.map((i) => i.name), ['VeraPort', 'AnySign', 'nxKey']);
      expect(plan.stop.map((i) => i.name), ['Other']);
    });
  });

  group('detect: 서비스 지정도 같은 규칙으로 판정한다', () {
    test('직접 정한 대로 켜져 있으면 그 모드다', () {
      final data = WatchData(
        categories: const [],
        items: [_i('a'), _i('b')],
        modes: [const WatchMode('작은', services: {'a': Want.on}), const WatchMode('개발')],
        defaultMode: '개발',
      );
      expect(detect(data, [_s('a', [], true), _s('b', [], false)]).current?.name, '작은');
      expect(detect(data, [_s('a', [], false), _s('b', [], false)]).current?.name, '개발');
      final mixed = detect(data, [_s('a', [], true), _s('b', [], true)]);
      expect(mixed.current, isNull);
      expect(mixed.closest?.name, isNotNull);
    });

    test('그대로로 정한 서비스는 켜져 있든 꺼져 있든 판정에 영향이 없다', () {
      final data = WatchData(
        categories: const [],
        items: [_i('a'), _i('b')],
        modes: [const WatchMode('m', services: {'a': Want.on, 'b': Want.keep})],
      );
      expect(detect(data, [_s('a', [], true), _s('b', [], true)]).current?.name, 'm');
      expect(detect(data, [_s('a', [], true), _s('b', [], false)]).current?.name, 'm');
    });
  });

  group('저장 형식 v4', () {
    WatchData sample() => WatchData(
          categories: ['보안'],
          items: [_i('A', ['보안']), _i('B')],
          modes: [
            const WatchMode('m', on: ['보안'], services: {'a': Want.off, 'b': Want.on}),
            const WatchMode('개발'),
          ],
          defaultMode: '개발',
        );

    test('저장 후 다시 읽어도 서비스 지정이 같다', () {
      final j = sample().toJson();
      expect(j['version'], 4);
      final back = WatchData.fromJson(j, defaults: _d);
      expect(back.modeNamed('m')!.services, {'a': Want.off, 'b': Want.on});
      expect(back.modeNamed('개발')!.services, isEmpty);
    });

    test('서비스 지정이 없는 모드는 JSON 에 services 를 쓰지 않는다', () {
      final modes = (sample().toJson()['modes'] as List).cast<Map<String, dynamic>>();
      expect(modes[1].containsKey('services'), isFalse);
    });

    test('v3 파일(services 없음)은 그대로 읽히고 동작이 바뀌지 않는다', () {
      final back = WatchData.fromJson({
        'version': 3,
        'categories': ['보안'],
        'modes': [
          {'name': 'm', 'on': ['보안'], 'keep': [], 'revertMinutes': 10},
        ],
        'defaultMode': 'm',
        'items': [
          {'name': 'A', 'categories': ['보안'], 'note': ''},
        ],
      }, defaults: _d);
      expect(back.modeNamed('m')!.services, isEmpty);
      expect(wantFor(back.modeNamed('m')!, back.items.single), Want.on);
    });

    test('알 수 없는 동작 값과 목록에 없는 서비스 지정은 버린다', () {
      final back = WatchData.fromJson({
        'version': 4,
        'categories': [],
        'modes': [
          {'name': 'm', 'services': {'a': 'on', 'b': 'bogus', 'ghost': 'on'}},
        ],
        'items': [
          {'name': 'A', 'categories': []},
          {'name': 'B', 'categories': []},
        ],
      }, defaults: _d);
      expect(back.modeNamed('m')!.services, {'a': Want.on});
    });
  });

  group('서비스 항목 편집이 모드의 직접 지정을 따라간다', () {
    WatchData sample() => WatchData(
          categories: const [],
          items: [_i('Foo'), _i('Bar')],
          modes: [
            const WatchMode('m', services: {'foo': Want.on, 'bar': Want.keep}),
            const WatchMode('n', services: {'foo': Want.off}),
          ],
        );

    test('renameItem: 이름을 바꾸면 모든 모드의 지정이 새 이름으로 옮겨진다', () {
      final d = sample();
      expect(d.renameItem('Foo', 'FooNew'), isTrue);
      expect(d.items.first.name, 'FooNew');
      expect(d.modeNamed('m')!.services, {'foonew': Want.on, 'bar': Want.keep});
      expect(d.modeNamed('n')!.services, {'foonew': Want.off});
    });

    test('renameItem: 겹치는 이름·빈 이름·없는 항목은 거절한다', () {
      final d = sample();
      expect(d.renameItem('Foo', 'bar'), isFalse);
      expect(d.renameItem('Foo', '  '), isFalse);
      expect(d.renameItem('Nope', 'x'), isFalse);
      expect(d.modeNamed('m')!.services, {'foo': Want.on, 'bar': Want.keep});
    });

    test('renameItem: 대소문자만 바꿔도 지정은 유지된다', () {
      final d = sample();
      expect(d.renameItem('Foo', 'FOO'), isTrue);
      expect(d.modeNamed('m')!.services['foo'], Want.on);
    });

    test('removeItem: 항목을 지우면 그 서비스의 지정도 지운다', () {
      final d = sample()..removeItem('Foo');
      expect(d.items.map((i) => i.name), ['Bar']);
      expect(d.modeNamed('m')!.services, {'bar': Want.keep});
      expect(d.modeNamed('n')!.services, isEmpty);
    });
  });

  test('uniqueModeName: 겹치지 않는 이름을 만든다', () {
    final d = WatchData(
      categories: const [],
      items: const [],
      modes: [const WatchMode('뱅킹'), const WatchMode('뱅킹 복사'), const WatchMode('뱅킹 복사 2')],
    );
    expect(d.uniqueModeName('새'), '새');
    expect(d.uniqueModeName('뱅킹'), '뱅킹 2');
    expect(d.uniqueModeName('뱅킹 복사'), '뱅킹 복사 3');
  });
}
