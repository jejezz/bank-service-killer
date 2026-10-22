import 'dart:convert';
import 'dart:io';

import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/catalog_lint.dart';
import 'package:bank_service_killer/catalog/discovery.dart';
import 'package:bank_service_killer/catalog/report.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter_test/flutter_test.dart';

Catalog _small({int version = 1}) => Catalog.fromJson({
      'schema': 1,
      'version': version,
      'categories': {
        'kbd': {'ko': '키보드보안', 'en': 'Keyboard security'},
        'web': {'ko': '웹 플러그인', 'en': 'Web plugin'},
      },
      'products': [
        {
          'id': 'nxts',
          'name': 'nxTS',
          'categories': ['kbd'],
          'driver': true,
          'note': {'ko': '키보드보안', 'en': 'Keyboard security'},
          'match': [
            {'service': 'nxTS Process Manager Service'},
            {'service': 'nxTSSvc'},
            {'exe': 'nxtssvc.exe'},
          ],
        },
        {
          'id': 'anysign',
          'name': 'AnySign',
          'vendor': 'SoftForum',
          'categories': ['web'],
          'match': [
            {'service': 'AnySign4PC Launcher'},
            {'exe': 'AnySign4PCLauncher.exe', 'signer': 'SoftForum'},
          ],
        },
      ],
    });

InstalledService _svc(String name, {String display = '', String exe = '', String? signer}) =>
    InstalledService(name: name, displayName: display, exe: exe, signer: signer);

void main() {
  group('exeBaseName / exeFullPath', () {
    test('따옴표·인자·경로를 정리한다', () {
      expect(exeBaseName(r'"C:\Program Files (x86)\nxTS\nxtssvc.exe" -service'), 'nxtssvc.exe');
      expect(exeBaseName(r'C:\WINDOWS\IMGSF50Svc.exe'), 'imgsf50svc.exe');
      expect(exeBaseName(r'C:\Program Files\INNORIX_EX\innorixem.exe /x'), 'innorixem.exe');
      expect(exeBaseName(''), '');
      expect(exeFullPath(r'"C:\A B\x.exe" /y'), r'C:\A B\x.exe');
    });
  });

  group('MatchRule', () {
    test('서비스 이름은 이름·표시 이름과 대소문자 없이 같아야 한다', () {
      const r = MatchRule(service: 'AnySign4PC Launcher');
      expect(r.matches(_svc('x', display: 'anysign4pc launcher')), isTrue);
      expect(r.matches(_svc('ANYSIGN4PC LAUNCHER')), isTrue);
      expect(r.matches(_svc('AnySign4PC')), isFalse);
    });

    test('적힌 항목이 모두 맞아야 하고, 빈 규칙은 아무것도 잡지 않는다', () {
      const r = MatchRule(exe: 'a.exe', signer: 'SoftForum');
      expect(r.matches(_svc('s', exe: 'a.exe', signer: 'CN=SoftForum Co')), isTrue);
      expect(r.matches(_svc('s', exe: 'a.exe', signer: 'CN=Other')), isFalse);
      expect(r.matches(_svc('s', exe: 'a.exe')), isFalse, reason: '서명자를 모르면 맞지 않는다');
      expect(const MatchRule().matches(_svc('s')), isFalse);
    });
  });

  group('Catalog', () {
    test('형식이 다르면 FormatException', () {
      expect(() => Catalog.fromJson([]), throwsFormatException);
      expect(() => Catalog.fromJson({'schema': 2, 'version': 1}), throwsFormatException);
      expect(() => Catalog.fromJson({'schema': 1, 'version': -1}), throwsFormatException);
      expect(() => Catalog.fromJson({'schema': 1, 'version': '1'}), throwsFormatException);
    });

    test('shouldReplace: 더 높은 버전만 받는다 (되돌리기·재생 방지)', () {
      final v2 = _small(version: 2);
      expect(Catalog.shouldReplace(null, v2), isTrue);
      expect(Catalog.shouldReplace(v2, _small(version: 3)), isTrue);
      expect(Catalog.shouldReplace(v2, _small(version: 2)), isFalse);
      expect(Catalog.shouldReplace(v2, _small(version: 1)), isFalse);
    });

    test('언어별 문구는 없으면 영어로 떨어진다', () {
      final c = _small();
      expect(c.categoryLabel('kbd', 'ko'), '키보드보안');
      expect(c.categoryLabel('kbd', 'fr'), 'Keyboard security');
      expect(c.categoryLabel('none', 'ko'), 'none');
    });

    test('findHits: 서비스는 처음 맞는 제품 하나에만 짝지어진다', () {
      final hits = findHits(_small(), [
        _svc('nxTSSvc'),
        _svc('Other', exe: 'nxtssvc.exe'),
        _svc('Unrelated'),
      ]);
      expect(hits.map((h) => h.service.name), ['nxTSSvc', 'Other']);
      expect(hits.every((h) => h.product.id == 'nxts'), isTrue);
    });
  });

  group('discover', () {
    WatchData data(List<WatchItem> items) =>
        WatchData(categories: ['웹 플러그인'], items: items, modes: [const WatchMode('개발')]);

    test('이 PC에 있는데 목록에 없는 카탈로그 서비스를 찾는다', () {
      final d = discover(_small(), data([const WatchItem('AnySign4PC Launcher')]), [
        _svc('AnySign4PC Launcher'),
        _svc('nxTSSvc', display: 'nxTS Process Manager Service'),
      ]);
      expect(d.newFinds.map((h) => h.service.name), ['nxTSSvc']);
      expect(d.renames, isEmpty);
    });

    test('이미 목록에 있으면 (부분 일치 포함) 새로 찾지 않는다', () {
      final d = discover(_small(), data([const WatchItem('nxTS')]), [_svc('nxTSSvc')]);
      expect(d.isEmpty, isTrue);
    });

    test('이름이 바뀐 서비스를 짚는다: 옛 이름 항목은 없고, 카탈로그가 아는 제품이 새 이름으로 있다', () {
      final d = discover(_small(), data([const WatchItem('nxTS Process Manager Service')]), [
        _svc('nxTSNewName', exe: 'nxtssvc.exe'),
      ]);
      expect(d.renames, hasLength(1));
      expect(d.renames.first.item.name, 'nxTS Process Manager Service');
      expect(d.renames.first.hit.service.name, 'nxTSNewName');
      expect(d.newFinds, isEmpty, reason: '이름 변경으로 쓴 서비스는 새 발견으로 또 나오지 않는다');
    });

    test('옛 이름 항목이 아직 설치돼 있으면 이름 변경이 아니다', () {
      final d = discover(_small(), data([const WatchItem('nxTSSvc')]), [
        _svc('nxTSSvc'),
        _svc('nxTSNewName', exe: 'nxtssvc.exe'),
      ]);
      expect(d.renames, isEmpty);
      expect(d.newFinds.map((h) => h.service.name), ['nxTSNewName']);
    });

    test('addFinds: 카테고리를 만들어 붙이고 모드는 건드리지 않는다', () {
      final wd = data(const []);
      final hits = findHits(_small(), [_svc('nxTSSvc')]);
      final created = addFinds(wd, _small(), hits, 'ko');
      expect(created, ['키보드보안']);
      expect(wd.categories, contains('키보드보안'));
      expect(wd.items.single.name, 'nxTSSvc');
      expect(wd.items.single.categories, ['키보드보안']);
      expect(wd.items.single.note, '키보드보안');
      expect(wd.modes.single.on, isEmpty);
    });

    test('addFinds: 이미 있는 항목은 다시 넣지 않고, 있는 카테고리는 새로 만들지 않는다', () {
      final wd = data([const WatchItem('nxTSSvc')]);
      final created = addFinds(wd, _small(), findHits(_small(), [_svc('nxTSSvc')]), 'ko');
      expect(created, isEmpty);
      expect(wd.items, hasLength(1));
      final wd2 = WatchData(categories: ['키보드보안'], items: const [], modes: [const WatchMode('m')]);
      expect(addFinds(wd2, _small(), findHits(_small(), [_svc('nxTSSvc')]), 'ko'), isEmpty);
    });

    test('applyRename: 이름만 바꾸고 카테고리·메모는 남긴다', () {
      final wd = data([const WatchItem('nxTS Process Manager Service', categories: ['웹 플러그인'], note: 'n')]);
      final d = discover(_small(), wd, [_svc('nxTSNewName', exe: 'nxtssvc.exe')]);
      applyRename(wd, d.renames.single);
      expect(wd.items.single.name, 'nxTSNewName');
      expect(wd.items.single.categories, ['웹 플러그인']);
      expect(wd.items.single.note, 'n');
    });
  });

  group('lintCatalog', () {
    test('같이 배포하는 기본 카탈로그는 문제가 없다', () {
      final text = File('catalog/catalog.json').readAsStringSync();
      expect(lintCatalog(Catalog.fromJson(jsonDecode(text))), isEmpty);
    });

    test('중복 id·빈 규칙·알 수 없는 카테고리·서명자만 쓴 규칙을 잡는다', () {
      final c = Catalog.fromJson({
        'schema': 1,
        'version': 1,
        'categories': {'a': {'en': 'A'}},
        'products': [
          {'id': 'x', 'name': 'X', 'categories': ['zzz'], 'match': []},
          {'id': 'x', 'name': 'X2', 'match': [{}, {'signer': 'Corp'}]},
        ],
      });
      final p = lintCatalog(c).join('\n');
      expect(p, contains('duplicate product id: x'));
      expect(p, contains('no match rules'));
      expect(p, contains('unknown category "zzz"'));
      expect(p, contains('no fields'));
      expect(p, contains('too broad'));
    });
  });

  test('저장소의 catalog 파일들은 LF 줄바꿈이다 (서명이 바이트 전체에 걸리므로 CRLF 면 앱이 거절한다)', () {
    for (final f in ['catalog/catalog.json', 'catalog/catalog.json.sig', 'catalog/public_key.txt']) {
      final file = File(f);
      if (!file.existsSync()) continue; // .sig 는 서명 전에는 없을 수 있다
      expect(file.readAsBytesSync().contains(13), isFalse, reason: '$f 에 CR 문자가 있다');
    }
  });

  test('기본 카탈로그가 사용자가 쓰던 서비스(서비스 이름·표시 이름·실행 파일)를 알아본다', () {
    final text = File('catalog/catalog.json').readAsStringSync();
    final catalog = Catalog.fromJson(jsonDecode(text));
    final installed = [
      // 사용자 PC의 로그·화면에서 확인된 이름과 실행 파일.
      _svc('nxTSSvc', display: 'nxTS Process Manager Service', exe: exeBaseName(r'C:\Program Files (x86)\nxTS\nxtssvc.exe')),
      _svc('WizveraPMSvc', display: 'WIZVERA Process Manager Service'),
      _svc('MagicLine4NXSVC', display: 'MagicLine4NX Service', exe: 'magicline4nxservices.exe'),
      _svc('ToucnEn_nxFirewall'),
      _svc('OZWLService'),
      _svc('Spooler', display: 'Print Spooler', exe: 'spoolsv.exe'),
    ];
    final ids = findHits(catalog, installed).map((h) => h.product.id).toList();
    expect(ids, ['nxts', 'wizvera-pm', 'magicline4nx', 'nxfirewall', 'ozwl']);
  });

  group('ServiceReport', () {
    test('경로 없이 이름·실행 파일·서명자·카탈로그 버전만 담는다', () {
      const r = ServiceReport(
        serviceName: 'FooSvc',
        displayName: 'Foo Service',
        exeName: 'foo.exe',
        signer: 'CN=Foo Corp',
        catalogVersion: 7,
      );
      expect(r.body, contains('Service name: FooSvc'));
      expect(r.body, contains('Executable: foo.exe'));
      expect(r.body, contains('Signer: CN=Foo Corp'));
      expect(r.body, contains('Catalog version: 7'));
      expect(r.body, isNot(contains(r'C:\')));
    });

    test('서명이 없으면 그렇게 적고, 주소는 인코딩되어 이슈 새 글로 간다', () {
      const r = ServiceReport(serviceName: 'A B&C', displayName: 'd', exeName: 'e.exe', catalogVersion: 1);
      expect(r.body, contains('(unsigned or unknown)'));
      final u = r.url('https://github.com/o/r/issues/new');
      expect(u.host, 'github.com');
      expect(u.path, '/o/r/issues/new');
      expect(u.queryParameters['title'], 'Catalog: A B&C');
      expect(u.queryParameters['labels'], 'catalog');
    });
  });
}
