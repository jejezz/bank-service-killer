import 'dart:io';

import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/catalog_controller.dart';
import 'package:bank_service_killer/catalog/catalog_dialog.dart';
import 'package:bank_service_killer/l10n/app_localizations.dart';
import 'package:bank_service_killer/service_manager.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Catalog _catalog() => Catalog.fromJson({
      'schema': 1,
      'version': 3,
      'updated': '2026-10-22',
      'categories': {
        'kbd': {'ko': '키보드보안', 'en': 'Keyboard security'},
      },
      'products': [
        {
          'id': 'nxts',
          'name': 'nxTS',
          'vendor': 'Raon',
          'categories': ['kbd'],
          'driver': true,
          'match': [
            {'service': 'nxTS Process Manager Service'},
            {'exe': 'nxtssvc.exe'},
          ],
        },
      ],
    });

SvcInfo _svc(String name, String path) => SvcInfo(
      name: name,
      displayName: name,
      state: 'Running',
      startMode: 'Manual',
      path: path,
      pid: 1,
    );

class _Result {
  WatchData? data;
  bool closed = false;
}

Future<_Result> _open(
  WidgetTester tester, {
  required WatchData data,
  required List<SvcInfo> services,
  bool remote = false,
}) async {
  // 디렉터리를 실제로 만들지 않는다 (위젯 테스트의 가짜 시계 안에서는 실제 파일 입출력이 끝나지 않는다).
  final controller = CatalogController(
    bundled: _catalog(),
    cacheDir: Directory('unused_cache_dir'),
    publicKey: remote ? 'AAAA' : '',
    url: remote ? Uri.parse('https://example.test/c.json') : null,
  );
  final out = _Result();
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            out.data = await showCatalogDialog(context, controller: controller, data: data, services: services);
            out.closed = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return out;
}

WatchData _watch(List<WatchItem> items) => WatchData(
      categories: const [],
      items: items,
      modes: [const WatchMode('뱅킹'), const WatchMode('개발')],
    );

void main() {
  testWidgets('발견한 서비스를 고르면 목록에 추가되고 카테고리가 만들어지며 모드는 그대로다', (tester) async {
    final original = _watch(const []);
    final out = await _open(
      tester,
      data: original,
      services: [_svc('nxTSSvc', r'"C:\Program Files (x86)\nxTS\nxtssvc.exe"'), _svc('Spooler', r'C:\Windows\System32\spoolsv.exe')],
    );

    expect(find.text('카탈로그 v3 · 2026-10-22'), findsOneWidget);
    expect(find.textContaining('발견했지만 목록에 없는 서비스 1개'), findsOneWidget);
    expect(find.textContaining('nxTS  ·  Raon'), findsOneWidget);
    expect(find.text('드라이버 연동'), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('선택한 1개 추가'));
    await tester.pumpAndSettle();

    expect(find.textContaining('서비스 1개를 목록에 추가했어요'), findsOneWidget);
    expect(find.textContaining('새 카테고리(키보드보안)'), findsOneWidget);
    expect(find.textContaining('발견했지만 목록에 없는'), findsNothing);

    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    final saved = out.data!;
    expect(saved.items.single.name, 'nxTSSvc');
    expect(saved.items.single.categories, ['키보드보안']);
    expect(saved.modes.every((m) => m.on.isEmpty), isTrue);
    expect(original.items, isEmpty, reason: '원본은 건드리지 않는다');
  });

  testWidgets('이름이 바뀐 항목은 "이름 바꾸기"로 고친다', (tester) async {
    final out = await _open(
      tester,
      data: _watch([const WatchItem('nxTS Process Manager Service', note: 'n')]),
      services: [_svc('nxTSRenamed', r'C:\x\nxtssvc.exe')],
    );
    expect(find.textContaining('이름이 바뀐 것 같은 항목 1개'), findsOneWidget);
    expect(find.text('nxTS Process Manager Service → nxTSRenamed'), findsOneWidget);

    await tester.tap(find.text('이름 바꾸기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect(out.data!.items.single.name, 'nxTSRenamed');
    expect(out.data!.items.single.note, 'n');
  });

  testWidgets('제안이 없으면 안내만 나오고 바꾼 것이 없으니 null 을 돌려준다', (tester) async {
    final out = await _open(
      tester,
      data: _watch([const WatchItem('nxTSSvc')]),
      services: [_svc('nxTSSvc', r'C:\x\nxtssvc.exe')],
    );
    expect(find.text('새로 발견한 서비스도, 이름이 바뀐 항목도 없어요.'), findsOneWidget);
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect(out.closed, isTrue);
    expect(out.data, isNull);
  });

  testWidgets('원격 갱신이 꺼져 있으면 알리고 "지금 확인"을 막는다', (tester) async {
    await _open(tester, data: _watch(const []), services: const []);
    expect(find.textContaining('원격 갱신이 꺼져 있어요'), findsOneWidget);
    final button = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, '지금 확인'));
    expect(button.onPressed, isNull);
    expect(find.text('아직 확인하지 않았어요'), findsOneWidget);
    expect(find.text('앱에 들어 있는 기본 카탈로그'), findsOneWidget);
  });

  testWidgets('Windows 자체 서비스와 이미 카탈로그가 아는 서비스는 신고 후보에서 빠진다', (tester) async {
    await _open(
      tester,
      data: _watch(const []),
      services: [
        _svc('nxTSSvc', r'C:\x\nxtssvc.exe'),
        _svc('Spooler', r'C:\Windows\System32\spoolsv.exe'),
        _svc('FooSvc', r'C:\Program Files\Foo\foo.exe'),
      ],
    );
    await tester.tap(find.text('목록에 없는 서비스 신고…'));
    await tester.pumpAndSettle();
    expect(find.text('FooSvc'), findsOneWidget);
    expect(find.text('Spooler'), findsNothing);
    expect(find.text('nxTSSvc'), findsNothing);
  });

  test('suggestionCount: 배지 숫자는 발견+이름 변경 합계', () {
    final n = suggestionCount(
      _catalog(),
      _watch([const WatchItem('nxTS Process Manager Service')]),
      [_svc('nxTSRenamed', r'C:\x\nxtssvc.exe')],
    );
    expect(n, 1);
  });
}
