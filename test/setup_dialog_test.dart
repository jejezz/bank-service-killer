import 'dart:io';

import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/catalog_controller.dart';
import 'package:bank_service_killer/catalog/installed.dart';
import 'package:bank_service_killer/catalog/setup_dialog.dart';
import 'package:bank_service_killer/l10n/app_localizations.dart';
import 'package:bank_service_killer/service_manager.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Catalog _catalog() => Catalog.fromJson({
      'schema': 1,
      'version': 1,
      'categories': {
        'web': {'ko': '웹 플러그인', 'en': 'Web plugin'},
      },
      'products': [
        {
          'id': 'anysign',
          'name': 'AnySign',
          'vendor': 'SoftForum',
          'categories': ['web'],
          'match': [
            {'service': 'AnySign4PC Launcher'},
          ],
        },
      ],
    });

SvcInfo _svc(String name, String path, {String display = ''}) => SvcInfo(
      name: name,
      displayName: display.isEmpty ? name : display,
      state: 'Running',
      startMode: 'Manual',
      path: path,
      pid: 1,
    );

WatchData _initial() => WatchData(
      categories: const [],
      items: const [],
      modes: [const WatchMode('뱅킹', revertMinutes: 30), const WatchMode('개발')],
      defaultMode: '개발',
    );

class _Result {
  WatchData? data;
  bool closed = false;
}

Future<_Result> _open(WidgetTester tester, List<SvcInfo> services) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1000, 1800);
  addTearDown(tester.view.reset);
  final controller = CatalogController(
    bundled: _catalog(),
    cacheDir: Directory('unused_cache_dir'),
    publicKey: '',
    url: null,
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
            out.data = await showSetupDialog(
              context,
              catalog: controller,
              data: _initial(),
              services: services,
              signers: SignerCache(lookup: (paths) async => {for (final p in paths) p: ''}),
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

List<SvcInfo> _services() => [
      _svc('AnySign4PC Launcher', r'C:\Program Files\AnySign\a.exe'),
      _svc('GuardSvc', r'C:\Program Files\Guard\guard.exe', display: 'Guard Security'),
      _svc('Printer', r'C:\Program Files\P\p.exe'),
      _svc('Spooler', r'C:\Windows\System32\spoolsv.exe'),
    ];

bool _checked(WidgetTester tester, Finder f) => tester.widget<CheckboxListTile>(f).value ?? false;

void main() {
  testWidgets('카탈로그가 아는 서비스는 미리 체크하고, 후보는 체크하지 않은 채 이유와 함께 보여 준다', (tester) async {
    await _open(tester, _services());
    expect(find.text('처음 설정: 이 PC의 보안 서비스'), findsOneWidget);
    expect(find.text('카탈로그가 아는 서비스 1개'), findsOneWidget);
    expect(find.text('AnySign  ·  SoftForum'), findsOneWidget);
    expect(_checked(tester, find.widgetWithText(CheckboxListTile, 'AnySign  ·  SoftForum')), isTrue);

    expect(find.text('보안 프로그램으로 보이는 후보 1개 (확인 필요)'), findsOneWidget);
    expect(find.textContaining("GuardSvc  ·  이름에 'guard'"), findsNothing, reason: '이름에는 보안 낱말이 없다');
    expect(find.textContaining("표시 이름에 'security'"), findsOneWidget);
    expect(_checked(tester, find.widgetWithText(CheckboxListTile, 'Guard Security')), isFalse);

    expect(find.textContaining('Printer'), findsNothing);
    expect(find.textContaining('Spooler'), findsNothing);
    // 기본 모드('개발')가 아닌 '뱅킹'이 미리 체크돼 있다.
    expect(_checked(tester, find.widgetWithText(CheckboxListTile, "'뱅킹' 모드에서 켜기")), isTrue);
    expect(_checked(tester, find.widgetWithText(CheckboxListTile, "'개발' 모드에서 켜기")), isFalse);
    expect(find.text('추가하고 시작 (1)'), findsOneWidget);
    // 각 서비스 옆에 검색 단추가 있다.
    expect(find.byTooltip('Google에서 검색 (브라우저가 열려요)'), findsNWidgets(2));
  });

  testWidgets('시작하면 목록·카테고리·뱅킹 모드가 만들어진다', (tester) async {
    final out = await _open(tester, _services());
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Guard Security')); // 후보도 하나 고른다
    await tester.pumpAndSettle();
    expect(find.text('추가하고 시작 (2)'), findsOneWidget);

    await tester.tap(find.text('추가하고 시작 (2)'));
    await tester.pumpAndSettle();
    expect(out.closed, isTrue);
    final d = out.data!;
    expect(d.items.map((i) => i.name), ['AnySign4PC Launcher', 'GuardSvc']);
    expect(d.items[0].categories, ['웹 플러그인']);
    expect(d.items[1].categories, ['새 보안 서비스']);
    expect(d.modeNamed('뱅킹')!.on, ['웹 플러그인', '새 보안 서비스']);
    expect(d.modeNamed('개발')!.on, isEmpty);
  });

  testWidgets('체크를 모두 풀면 시작할 수 없다', (tester) async {
    await _open(tester, _services());
    await tester.tap(find.widgetWithText(CheckboxListTile, 'AnySign  ·  SoftForum'));
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, '추가하고 시작 (0)'));
    expect(button.onPressed, isNull);
  });

  testWidgets('나중에를 누르면 아무것도 바꾸지 않고 null 을 돌려준다', (tester) async {
    final out = await _open(tester, _services());
    await tester.tap(find.text('나중에'));
    await tester.pumpAndSettle();
    expect(out.closed, isTrue);
    expect(out.data, isNull);
  });

  testWidgets('찾은 것이 없으면 안내만 하고 닫기만 있다', (tester) async {
    final out = await _open(tester, [_svc('Printer', r'C:\x\p.exe'), _svc('Spooler', r'C:\Windows\System32\s.exe')]);
    expect(find.textContaining('보안 서비스를 찾지 못했어요'), findsOneWidget);
    expect(find.textContaining('추가하고 시작'), findsNothing);
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect(out.data, isNull);
  });
}
