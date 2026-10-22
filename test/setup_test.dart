import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/heuristics.dart';
import 'package:bank_service_killer/catalog/setup.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter_test/flutter_test.dart';

Catalog _catalog() => Catalog.fromJson({
      'schema': 1,
      'version': 1,
      'categories': {
        'web': {'ko': '웹 플러그인', 'en': 'Web plugin'},
        'kbd': {'ko': '키보드보안', 'en': 'Keyboard security'},
      },
      'products': [
        {
          'id': 'anysign',
          'name': 'AnySign',
          'categories': ['web'],
          'match': [
            {'service': 'AnySign4PC Launcher'},
          ],
        },
        {
          'id': 'nxts',
          'name': 'nxTS',
          'categories': ['kbd'],
          'match': [
            {'service': 'nxTSSvc'},
          ],
        },
      ],
    });

InstalledService _svc(String name, {String display = '', String path = r'C:\Program Files\X\x.exe', String? signer}) =>
    InstalledService(name: name, displayName: display, exe: exeBaseName(path), path: path, signer: signer);

WatchData _fresh() => WatchData(
      categories: const [],
      items: const [],
      modes: [const WatchMode('뱅킹'), const WatchMode('개발')],
      defaultMode: '개발',
    );

void main() {
  group('planSetup', () {
    test('카탈로그가 아는 것과 후보를 나누고, 평범한 서비스와 Windows 서비스는 뺀다', () {
      final plan = planSetup(_catalog(), _fresh(), [
        _svc('AnySign4PC Launcher'),
        _svc('nxTSSvc'),
        _svc('GuardSvc', display: 'Guard Security'),
        _svc('Printer', display: 'Boring Printer'),
        _svc('Spooler', display: 'Security Spooler', path: r'C:\Windows\System32\spoolsv.exe'),
      ]);
      expect(plan.found.map((h) => h.service.name), ['AnySign4PC Launcher', 'nxTSSvc']);
      expect(plan.candidates.map((s) => s.service.name), ['GuardSvc']);
      expect(plan.isEmpty, isFalse);
    });

    test('카탈로그가 아는 서비스는 후보에 또 나오지 않는다', () {
      final plan = planSetup(_catalog(), _fresh(), [_svc('nxTSSvc', display: 'nxTS Security Service')]);
      expect(plan.found, hasLength(1));
      expect(plan.candidates, isEmpty);
    });

    test('이미 목록에 있는 서비스는 뺀다', () {
      final data = WatchData(
        categories: const [],
        items: [const WatchItem('nxTSSvc'), const WatchItem('GuardSvc')],
        modes: [const WatchMode('m')],
      );
      final plan = planSetup(_catalog(), data, [_svc('nxTSSvc'), _svc('GuardSvc', display: 'Guard Security')]);
      expect(plan.isEmpty, isTrue);
    });

    test('아무것도 찾지 못하면 비어 있다', () {
      expect(planSetup(_catalog(), _fresh(), [_svc('Printer')]).isEmpty, isTrue);
      expect(planSetup(_catalog(), _fresh(), const []).isEmpty, isTrue);
    });
  });

  group('applySetup', () {
    test('카탈로그 서비스는 카탈로그 카테고리로, 후보는 지정한 카테고리로 넣고 고른 모드에서 켠다', () {
      final data = _fresh();
      final plan = planSetup(_catalog(), data, [_svc('AnySign4PC Launcher'), _svc('GuardSvc', display: 'Guard Security')]);
      final n = applySetup(
        data,
        _catalog(),
        hits: plan.found,
        suspects: plan.candidates,
        modeNames: {'뱅킹'},
        lang: 'ko',
        candidateCategory: '새 보안 서비스',
      );
      expect(n, 2);
      expect(data.items.map((i) => i.name), ['AnySign4PC Launcher', 'GuardSvc']);
      expect(data.items[0].categories, ['웹 플러그인']);
      expect(data.items[1].categories, ['새 보안 서비스']);
      expect(data.categories, ['웹 플러그인', '새 보안 서비스']);
      expect(data.modeNamed('뱅킹')!.on, ['웹 플러그인', '새 보안 서비스']);
      expect(data.modeNamed('개발')!.on, isEmpty);
    });

    test('모드를 고르지 않으면 어느 모드에서도 켜지 않는다', () {
      final data = _fresh();
      final plan = planSetup(_catalog(), data, [_svc('nxTSSvc')]);
      applySetup(data, _catalog(),
          hits: plan.found, suspects: const [], modeNames: {}, lang: 'ko', candidateCategory: 'x');
      expect(data.items, hasLength(1));
      expect(data.modes.every((m) => m.on.isEmpty), isTrue);
    });

    test('일부만 골라도 고른 것만 넣고, 후보가 없으면 후보 카테고리를 만들지 않는다', () {
      final data = _fresh();
      final plan = planSetup(_catalog(), data, [_svc('AnySign4PC Launcher'), _svc('nxTSSvc')]);
      applySetup(data, _catalog(),
          hits: [plan.found.first], suspects: const [], modeNames: {'뱅킹'}, lang: 'ko', candidateCategory: '후보');
      expect(data.items.map((i) => i.name), ['AnySign4PC Launcher']);
      expect(data.categories, ['웹 플러그인']);
      expect(data.categories, isNot(contains('후보')));
    });

    test('영어 화면이면 카탈로그의 영어 카테고리 이름을 쓴다', () {
      final data = _fresh();
      final plan = planSetup(_catalog(), data, [_svc('nxTSSvc')]);
      applySetup(data, _catalog(),
          hits: plan.found, suspects: const [], modeNames: {'뱅킹'}, lang: 'en', candidateCategory: 'x');
      expect(data.categories, ['Keyboard security']);
    });

    test('아무것도 고르지 않으면 아무것도 바뀌지 않는다', () {
      final data = _fresh();
      final n = applySetup(data, _catalog(),
          hits: const [], suspects: const [], modeNames: {'뱅킹'}, lang: 'ko', candidateCategory: 'x');
      expect(n, 0);
      expect(data.items, isEmpty);
      expect(data.categories, isEmpty);
    });
  });

  test('후보 규칙은 서명된 카탈로그의 heuristics 도 쓴다', () {
    final c = Catalog.fromJson({
      'schema': 1,
      'version': 1,
      'heuristics': {'keywords': ['zorbix']},
    });
    final plan = planSetup(c, _fresh(), [_svc('ZorbixGuard')]);
    expect(plan.candidates.map((s) => s.service.name), ['ZorbixGuard']);
    expect(Heuristics.defaults.keywords, isNot(contains('zorbix')));
  });
}
