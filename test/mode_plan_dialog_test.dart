import 'package:bank_service_killer/l10n/app_localizations.dart';
import 'package:bank_service_killer/mode_plan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Out {
  bool? ran;
}

Future<_Out> _open(WidgetTester tester) async {
  final out = _Out();
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            out.ran = await showModePlanDialog(
              context,
              modeName: '뱅킹',
              stop: const [PlanLine('Nahimic', note: '시작 유형이 자동')],
              start: const [PlanLine('AnySign4PC'), PlanLine('nxTS')],
              unchanged: 3,
            );
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

void main() {
  testWidgets('끌 것과 켤 것을 개수와 함께 보여 준다', (tester) async {
    await _open(tester);
    expect(find.text("'뱅킹' 모드로 전환"), findsOneWidget);
    expect(find.text('끌 서비스 1개'), findsOneWidget);
    expect(find.text('켤 서비스 2개'), findsOneWidget);
    expect(find.text('Nahimic'), findsOneWidget);
    expect(find.text('시작 유형이 자동'), findsOneWidget);
    expect(find.text('AnySign4PC'), findsOneWidget);
    expect(find.text('이미 맞는 서비스 3개는 그대로 둬요.'), findsOneWidget);
  });

  testWidgets('실행을 누르면 true', (tester) async {
    final out = await _open(tester);
    await tester.tap(find.text('실행'));
    await tester.pumpAndSettle();
    expect(out.ran, isTrue);
  });

  testWidgets('취소를 누르면 false', (tester) async {
    final out = await _open(tester);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(out.ran, isFalse);
  });

  testWidgets('비어 있는 구역은 머리글도 나오지 않는다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModePlanDialog(
              context,
              modeName: '개발',
              stop: const [PlanLine('a')],
              start: const [],
              unchanged: 0,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.textContaining('켤 서비스'), findsNothing);
    expect(find.textContaining('이미 맞는'), findsNothing);
  });
}
