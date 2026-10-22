import 'package:bank_service_killer/category_dialog.dart';
import 'package:bank_service_killer/l10n/app_localizations.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _open(WidgetTester tester, WatchData data) async {
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          await showCategoryManager(context, data);
        },
        child: const Text('open'),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('카테고리를 추가·삭제하고 저장하면 사본이 돌아온다', (tester) async {
    final original = WatchData(
      categories: ['키보드보안', '공인인증'],
      items: [const WatchItem('a', categories: ['키보드보안'])],
    );
    await _open(tester, original);

    // 새 카테고리 추가 (뱅킹 모드 대상으로 들어간다)
    await tester.enterText(find.byType(TextField), '신한');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('신한'), findsOneWidget);

    // 공인인증 삭제 (두 번째 휴지통: 키보드보안, 공인인증, 신한 순)
    await tester.tap(find.byIcon(Icons.delete_rounded).at(1));
    await tester.pumpAndSettle();
    expect(find.text('공인인증'), findsNothing);

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    // 원본은 건드리지 않는다.
    expect(original.categories, ['키보드보안', '공인인증']);
  });

  testWidgets('이미 있는 이름은 오류를 보여 주고 추가하지 않는다', (tester) async {
    await _open(tester, WatchData(categories: ['키보드보안'], items: const []));
    await tester.enterText(find.byType(TextField), '키보드보안');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('이미 있거나 사용할 수 없는 이름이에요.'), findsOneWidget);
    // 입력칸에도 같은 글자가 있으니 목록 항목만 센다.
    expect(find.widgetWithText(ListTile, '키보드보안'), findsOneWidget);
  });
}
