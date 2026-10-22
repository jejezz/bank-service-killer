import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/heuristics.dart';
import 'package:bank_service_killer/catalog/installed.dart';
import 'package:bank_service_killer/catalog/seen_state.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter_test/flutter_test.dart';

InstalledService _svc(
  String name, {
  String display = '',
  String path = r'C:\Program Files\Foo\foo.exe',
  String? signer,
}) =>
    InstalledService(name: name, displayName: display, exe: exeBaseName(path), path: path, signer: signer);

Set<String> _names(List<Suspect> s) => {for (final x in s) x.service.name};

void main() {
  const h = Heuristics.defaults;

  group('findSuspects', () {
    test('이름·표시 이름·경로의 보안 낱말을 이유와 함께 잡는다', () {
      final s = findSuspects(h, [
        _svc('NProtectSvc'),
        _svc('FooSvc', display: 'Foo Keyboard Security'),
        _svc('BarSvc', path: r'C:\Program Files (x86)\TouchEn\bar.exe'),
        _svc('Boring', display: 'Boring Printer'),
      ]);
      expect(_names(s), {'NProtectSvc', 'FooSvc', 'BarSvc'});
      final n = s.firstWhere((x) => x.service.name == 'NProtectSvc');
      expect(n.reasons, contains(const Reason(ReasonKind.name, 'nprotect')));
      final f = s.firstWhere((x) => x.service.name == 'FooSvc');
      expect(f.reasons, contains(const Reason(ReasonKind.display, 'security')));
      final b = s.firstWhere((x) => x.service.name == 'BarSvc');
      expect(b.reasons, contains(const Reason(ReasonKind.path, 'touchen')));
    });

    test('한글 낱말도 잡는다', () {
      final s = findSuspects(h, [_svc('X', display: '가상키패드 서비스')]);
      expect(_names(s), {'X'});
    });

    test('서명자가 보안 업체면 이름이 평범해도 잡는다', () {
      final s = findSuspects(h, [_svc('Plain', signer: 'CN=INCA Internet Co., Ltd.')]);
      expect(_names(s), {'Plain'});
      expect(s.single.reasons.single.kind, ReasonKind.signer);
    });

    test('서명자를 모르면 서명자 규칙만 건너뛴다', () {
      expect(findSuspects(h, [_svc('Plain')]), isEmpty);
      expect(_names(findSuspects(h, [_svc('SecuritySvc')])), {'SecuritySvc'});
    });

    test('Windows 폴더 아래 서비스와 믿는 서명자(Microsoft)는 뺀다', () {
      final s = findSuspects(h, [
        _svc('WinDefend', display: 'Microsoft Defender Antivirus Service', path: r'C:\Windows\System32\x.exe'),
        _svc('Edge', display: 'Edge Security Helper', signer: 'CN=Microsoft Corporation, O=Microsoft Corporation'),
        _svc('Real', display: 'Real Security'),
      ]);
      expect(_names(s), {'Real'});
    });

    test('skip 에 든 이름(이미 목록에 있거나 무시한 것)은 뺀다', () {
      final s = findSuspects(h, [_svc('NProtectSvc'), _svc('OtherSecurity')], skip: {'nprotectsvc'});
      expect(_names(s), {'OtherSecurity'});
    });

    test('이유가 많은 순으로 정렬한다', () {
      final s = findSuspects(h, [
        _svc('OneReason', display: 'Security'),
        _svc('nProtect Security', display: 'nProtect Security', path: r'C:\x\nprotect\a.exe', signer: 'CN=INCA Internet'),
      ]);
      expect(s.first.service.name, 'nProtect Security');
      expect(s.first.reasons.length, greaterThan(s.last.reasons.length));
    });

    test('카탈로그의 heuristics 가 기본 규칙에 더해진다', () {
      final extra = HeuristicsData.fromJson({
        'keywords': ['Zorbix'],
        'signers': ['Zorbix Ltd'],
        'trustedSigners': ['Trusted Co'],
      });
      expect(extra.keywords, ['zorbix'], reason: '소문자로 견준다');
      final merged = h.merge(extra);
      expect(_names(findSuspects(merged, [_svc('ZorbixGuard')])), {'ZorbixGuard'});
      expect(findSuspects(h, [_svc('ZorbixGuard')]), isEmpty);
      expect(
        findSuspects(merged, [_svc('Trusted', display: 'Security', signer: 'CN=Trusted Co')]),
        isEmpty,
        reason: '믿는 서명자가 우선',
      );
      expect(merged.keywords.length, h.keywords.length + 1);
    });
  });

  group('Catalog.heuristics', () {
    test('없으면 비어 있다', () {
      final c = Catalog.fromJson({'schema': 1, 'version': 1});
      expect(c.heuristics.keywords, isEmpty);
    });

    test('있으면 읽는다', () {
      final c = Catalog.fromJson({
        'schema': 1,
        'version': 1,
        'heuristics': {'keywords': ['A'], 'signers': ['B']},
      });
      expect(c.heuristics.keywords, ['a']);
      expect(c.heuristics.signers, ['b']);
    });
  });

  group('SeenState', () {
    test('첫 실행(기준선 없음)에는 아무것도 새것이 아니고, markSeen 으로 기준선을 잡는다', () {
      final s = SeenState();
      expect(s.newNames(['A', 'B']), isEmpty);
      s.markSeen(['A', 'B']);
      expect(s.initialized, isTrue);
      expect(s.newNames(['a', 'B', 'C']), {'c'});
    });

    test('무시한 이름은 따로 기억한다', () {
      final s = SeenState()..markSeen(['A']);
      s.ignore(['Foo']);
      expect(s.ignored, {'foo'});
    });

    test('저장 후 다시 읽어도 같다', () {
      final s = SeenState()
        ..markSeen(['A', 'B'])
        ..ignore(['X']);
      final back = SeenState.fromJson(s.toJson());
      expect(back.initialized, isTrue);
      expect(back.seen, {'a', 'b'});
      expect(back.ignored, {'x'});
    });

    test('깨진 입력은 빈 상태로 읽는다', () {
      expect(SeenState.fromJson('garbage').initialized, isFalse);
      expect(SeenState.fromJson(null).seen, isEmpty);
    });
  });

  group('SignerCache', () {
    test('이미 조사한 파일은 다시 조사하지 않고, 서명이 없으면 null 이다', () async {
      final asked = <List<String>>[];
      final c = SignerCache(lookup: (paths) async {
        asked.add(paths.toList());
        return {for (final p in paths) p: p.contains('signed') ? 'CN=Corp' : ''};
      });
      await c.fill([r'C:\a\signed.exe', r'C:\a\plain.exe']);
      await c.fill([r'C:\a\signed.exe', r'C:\a\new.exe']);
      expect(asked, [
        [r'C:\a\signed.exe', r'C:\a\plain.exe'],
        [r'C:\a\new.exe'],
      ]);
      expect(c.of(r'C:\a\signed.exe'), 'CN=Corp');
      expect(c.of(r'C:\a\plain.exe'), isNull);
      expect(c.has(r'C:\a\plain.exe'), isTrue);
      expect(c.of(r'C:\unknown.exe'), isNull);
    });
  });

  group('WatchData.enableCategoryIn', () {
    test('켜기로 지정하고 그대로에서는 뺀다', () {
      final d = WatchData(
        categories: ['a', 'b'],
        items: const [],
        modes: [const WatchMode('뱅킹', on: ['a'], keep: ['b']), const WatchMode('개발')],
      );
      expect(d.enableCategoryIn('뱅킹', 'b'), isTrue);
      expect(d.modeNamed('뱅킹')!.on, ['a', 'b']);
      expect(d.modeNamed('뱅킹')!.keep, isEmpty);
      expect(d.enableCategoryIn('뱅킹', 'b'), isTrue);
      expect(d.modeNamed('뱅킹')!.on, ['a', 'b'], reason: '두 번 해도 중복되지 않는다');
    });

    test('없는 모드·카테고리면 false', () {
      final d = WatchData(categories: ['a'], items: const [], modes: [const WatchMode('m')]);
      expect(d.enableCategoryIn('nope', 'a'), isFalse);
      expect(d.enableCategoryIn('m', 'nope'), isFalse);
    });
  });
}
