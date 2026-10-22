import 'package:bank_service_killer/l10n/app_localizations.dart';
import 'package:bank_service_killer/mode_dialog.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Result {
  WatchData? data;
  bool closed = false;
}

Future<_Result> _open(WidgetTester tester, WatchData data) async {
  final out = _Result();
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            out.data = await showModeManager(context, data);
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

WatchData _sample() => WatchData(
      categories: ['보안', '오디오'],
      items: const [],
      modes: [const WatchMode('뱅킹', on: ['보안'], keep: ['오디오'], revertMinutes: 30), const WatchMode('개발')],
      defaultMode: '개발',
    );

void main() {
  testWidgets('모드 목록에 요약이 보이고 기본 모드에 표시가 붙는다', (tester) async {
    await _open(tester, _sample());
    expect(find.text('뱅킹'), findsOneWidget);
    expect(find.text('개발  (기본)'), findsOneWidget);
    expect(find.textContaining('켜기: 보안'), findsOneWidget);
    expect(find.textContaining('그대로: 오디오'), findsOneWidget);
    expect(find.text('켜는 것 없음'), findsOneWidget);
  });

  testWidgets('새 모드를 만들고 저장하면 결과에 들어 있고 원본은 그대로다', (tester) async {
    final original = _sample();
    final out = await _open(tester, original);

    await tester.tap(find.text('모드 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '증권');
    // 첫 카테고리(보안)를 '켜기'로.
    await tester.tap(find.text('켜기').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장').last);
    await tester.pumpAndSettle();
    expect(find.text('증권'), findsOneWidget);

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(out.closed, isTrue);
    final saved = out.data!;
    expect(saved.modes.map((m) => m.name), ['뱅킹', '개발', '증권']);
    expect(saved.modeNamed('증권')!.on, ['보안']);
    expect(saved.modeNamed('증권')!.keep, isEmpty);
    expect(original.modes.length, 2);
  });

  testWidgets('이미 있는 이름이면 추가되지 않는다', (tester) async {
    final out = await _open(tester, _sample());
    await tester.tap(find.text('모드 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '뱅킹');
    await tester.tap(find.text('저장').last);
    await tester.pumpAndSettle();
    expect(find.text('이미 있거나 사용할 수 없는 이름이에요.'), findsOneWidget);
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(out.data!.modes.length, 2);
  });

  testWidgets('마지막 하나 남은 모드는 삭제할 수 없다', (tester) async {
    await _open(tester, WatchData(categories: const [], items: const [], modes: [const WatchMode('only')]));
    final delete = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.delete_rounded));
    expect(delete.onPressed, isNull);
  });
}
