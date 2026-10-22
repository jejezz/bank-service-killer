import 'package:bank_service_killer/mode_engine.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _banking = WatchMode('뱅킹', on: ['보안'], keep: ['오디오']);
const _dev = WatchMode('개발');

WatchData _data() => WatchData(
      categories: ['보안', '오디오'],
      items: const [],
      modes: [_banking, _dev],
      defaultMode: '개발',
    );

WatchItem _item(String name, List<String> cats) => WatchItem(name, categories: cats);

ItemState _s(String name, List<String> cats, bool? running) => ItemState(_item(name, cats), running);

void main() {
  test('wantFor: on 이 keep 보다 우선이고, 어디에도 없으면 끈다', () {
    expect(wantFor(_banking, _item('a', ['보안'])), Want.on);
    expect(wantFor(_banking, _item('a', ['오디오'])), Want.keep);
    expect(wantFor(_banking, _item('a', ['보안', '오디오'])), Want.on);
    expect(wantFor(_banking, _item('a', [])), Want.off);
    expect(wantFor(_dev, _item('a', ['보안'])), Want.off);
  });

  group('detect', () {
    test('목표와 정확히 맞으면 그 모드', () {
      final states = [_s('s1', ['보안'], true), _s('s2', ['보안'], true), _s('au', ['오디오'], false)];
      final st = detect(_data(), states);
      expect(st.current?.name, '뱅킹');
      expect(st.closestProgress.ok, 2);
    });

    test('keep 항목은 켜져 있든 꺼져 있든 판정에 영향이 없다', () {
      final base = [_s('s1', ['보안'], true)];
      expect(detect(_data(), [...base, _s('au', ['오디오'], true)]).current?.name, '뱅킹');
      expect(detect(_data(), [...base, _s('au', ['오디오'], false)]).current?.name, '뱅킹');
    });

    test('전부 꺼져 있으면 개발', () {
      final states = [_s('s1', ['보안'], false), _s('au', ['오디오'], true)];
      // 개발 모드는 오디오도 끄라고 하므로 오디오가 켜져 있으면 개발이 아니다.
      expect(detect(_data(), states).current, isNull);
      expect(detect(_data(), [_s('s1', ['보안'], false), _s('au', ['오디오'], false)]).current?.name, '개발');
    });

    test('일부만 켜져 있으면 혼합이고 가장 가까운 모드와 진행을 알려 준다', () {
      final states = [_s('s1', ['보안'], true), _s('s2', ['보안'], false), _s('s3', ['보안'], true)];
      final st = detect(_data(), states);
      expect(st.current, isNull);
      expect(st.closest?.name, '뱅킹');
      expect(st.closestProgress.ok, 2);
      expect(st.closestProgress.total, 3);
    });

    test('설치되지 않은 서비스는 판정에서 빠진다', () {
      final states = [_s('s1', ['보안'], true), _s('ghost', ['보안'], null)];
      expect(detect(_data(), states).current?.name, '뱅킹');
    });

    test('설치된 서비스가 하나도 없으면 어떤 모드도 아니다', () {
      expect(detect(_data(), [_s('ghost', ['보안'], null)]).current, isNull);
      expect(detect(_data(), const []).current, isNull);
    });

    test('여러 모드가 동시에 맞으면 preferred 를 고른다', () {
      final d = WatchData(
        categories: ['보안'],
        items: const [],
        modes: [const WatchMode('A', on: ['보안']), const WatchMode('B', on: ['보안'])],
      );
      final states = [_s('s1', ['보안'], true)];
      expect(detect(d, states).current?.name, 'A');
      expect(detect(d, states, preferred: 'B').current?.name, 'B');
    });
  });

  group('planFor', () {
    test('이미 맞는 서비스는 건드리지 않고, 끌 것은 거꾸로 담는다', () {
      final states = [
        _s('on-ok', ['보안'], true),
        _s('on-need', ['보안'], false),
        _s('au', ['오디오'], true),
        _s('off1', [], true),
        _s('off2', [], true),
        _s('off-ok', [], false),
        _s('ghost', ['보안'], null),
      ];
      final plan = planFor(_banking, states);
      expect(plan.start.map((i) => i.name), ['on-need']);
      expect(plan.stop.map((i) => i.name), ['off2', 'off1']);
      expect(plan.total, 3);
    });

    test('이미 그 모드면 계획이 비어 있다', () {
      final states = [_s('s1', ['보안'], true), _s('au', ['오디오'], false)];
      expect(planFor(_banking, states).isEmpty, isTrue);
    });

    test('개발 모드는 켜진 것을 모두 끈다 (keep 없음)', () {
      final states = [_s('s1', ['보안'], true), _s('au', ['오디오'], true)];
      final plan = planFor(_dev, states);
      expect(plan.start, isEmpty);
      expect(plan.stop.map((i) => i.name), ['au', 's1']);
    });
  });
}
