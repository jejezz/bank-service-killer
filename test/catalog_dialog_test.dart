import 'dart:io';

import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/catalog_controller.dart';
import 'package:bank_service_killer/catalog/catalog_dialog.dart';
import 'package:bank_service_killer/catalog/installed.dart';
import 'package:bank_service_killer/catalog/seen_state.dart';
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
  SeenState? seen,
  Map<String, String> signers = const {},
  void Function(SeenState)? onSeenChanged,
}) async {
  // 디렉터리를 실제로 만들지 않는다 (위젯 테스트의 가짜 시계 안에서는 실제 파일 입출력이 끝나지 않는다).
  final controller = CatalogController(
    bundled: _catalog(),
    cacheDir: Directory('unused_cache_dir'),
    publicKey: remote ? 'AAAA' : '',
    url: remote ? Uri.parse('https://example.test/c.json') : null,
  );
  // 창이 길어졌으니 화면도 크게 잡아 모든 구역이 보이게 한다.
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1000, 1800);
  addTearDown(tester.view.reset);
  final out = _Result();
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            out.data = await showCatalogDialog(
              context,
              controller: controller,
              data: data,
              services: services,
              seen: seen,
              // 실제 PowerShell 을 부르지 않는다 (위젯 테스트의 가짜 시계 안에서는 프로세스가 끝나지 않는다).
              signers: SignerCache(lookup: (paths) async => {for (final p in paths) p: signers[p] ?? ''}),
              onSeenChanged: onSeenChanged == null ? null : (s) async => onSeenChanged(s),
            );
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
      defaultMode: '개발',
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


  group('보안 프로그램 후보', () {
    // 카탈로그에는 없지만 이름·서명자가 보안 프로그램처럼 보이는 서비스.
    List<SvcInfo> services() => [
          _svc('nxTSSvc', r'C:\x\nxtssvc.exe'),
          _svc('GuardSvc', r'C:\Program Files\Guard\guard.exe'),
          _svc('PlainSvc', r'C:\Program Files\Plain\plain.exe'),
          _svc('Spooler', r'C:\Windows\System32\spoolsv.exe'),
        ];
    const signers = {r'C:\Program Files\Guard\guard.exe': 'CN=INCA Internet Co.'};

    testWidgets('이유와 함께 보여 주고, 카탈로그가 아는 서비스·Windows 서비스·평범한 서비스는 뺀다', (tester) async {
      await _open(tester, data: _watch(const []), services: services(), signers: signers);
      expect(find.textContaining('보안 프로그램으로 보이는 서비스 1개'), findsOneWidget);
      expect(find.textContaining("GuardSvc  ·  서명자에 'inca internet'"), findsOneWidget);
      expect(find.textContaining('PlainSvc'), findsNothing);
      expect(find.textContaining('Spooler'), findsNothing);
    });

    testWidgets('목록에 이미 있는 서비스는 후보에서 뺀다', (tester) async {
      await _open(tester, data: _watch([const WatchItem('GuardSvc')]), services: services(), signers: signers);
      expect(find.textContaining('보안 프로그램으로 보이는 서비스'), findsNothing);
    });

    testWidgets('창을 열면 지금 서비스를 모두 본 것으로 치고 저장을 맡긴다', (tester) async {
      final seen = SeenState();
      var saved = 0;
      await _open(
        tester,
        data: _watch(const []),
        services: services(),
        seen: seen,
        onSeenChanged: (_) => saved++,
      );
      expect(seen.initialized, isTrue);
      expect(seen.seen, containsAll(['nxtssvc', 'guardsvc', 'plainsvc', 'spooler']));
      expect(saved, greaterThan(0));
    });

    testWidgets('추가: 카테고리와 켤 모드를 고르면 항목·카테고리·모드가 함께 반영된다', (tester) async {
      final out = await _open(tester, data: _watch(const []), services: services(), signers: signers);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'GuardSvc'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('선택한 1개 추가…'));
      await tester.pumpAndSettle();

      expect(find.text('서비스 1개를 목록에 추가'), findsOneWidget);
      // 기본 모드('개발')가 아닌 '뱅킹'이 미리 체크돼 있다.
      expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, "'뱅킹' 모드에서 켜기")).value, isTrue);
      expect(tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, "'개발' 모드에서 켜기")).value, isFalse);

      await tester.tap(find.text('추가').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('서비스 1개를 목록에 추가했어요'), findsOneWidget);
      expect(find.textContaining('보안 프로그램으로 보이는 서비스'), findsNothing, reason: '추가하면 후보에서 빠진다');

      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();
      final saved = out.data!;
      expect(saved.items.single.name, 'GuardSvc');
      expect(saved.items.single.categories, ['새 보안 서비스']);
      expect(saved.categories, contains('새 보안 서비스'));
      expect(saved.modeNamed('뱅킹')!.on, ['새 보안 서비스']);
      expect(saved.modeNamed('개발')!.on, isEmpty);
    });

    testWidgets('모드를 하나도 고르지 않으면 어느 모드에서도 켜지 않는다고 알린다', (tester) async {
      final out = await _open(tester, data: _watch(const []), services: services(), signers: signers);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'GuardSvc'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('선택한 1개 추가…'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CheckboxListTile, "'뱅킹' 모드에서 켜기"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('추가').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('어느 모드에서도 켜지 않도록 추가했어요'), findsOneWidget);
      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();
      expect(out.data!.modes.every((m) => m.on.isEmpty), isTrue);
    });

    testWidgets('무시하면 후보에서 빠지고 기억하며, 다시 보기로 되돌린다', (tester) async {
      final seen = SeenState();
      final out = await _open(tester, data: _watch(const []), services: services(), signers: signers, seen: seen);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'GuardSvc'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('선택한 1개 무시'));
      await tester.pumpAndSettle();
      expect(find.textContaining('보안 프로그램으로 보이는 서비스'), findsNothing);
      expect(seen.ignored, {'guardsvc'});

      await tester.tap(find.text('무시한 서비스 1개 다시 보기'));
      await tester.pumpAndSettle();
      expect(find.textContaining('보안 프로그램으로 보이는 서비스 1개'), findsOneWidget);
      expect(seen.ignored, isEmpty);

      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();
      expect(out.data, isNull, reason: '목록은 바뀌지 않았다');
    });
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
