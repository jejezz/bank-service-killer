import 'package:bank_service_killer/l10n/app_localizations.dart';
import 'package:bank_service_killer/mode_dialog.dart';
import 'package:bank_service_killer/mode_engine.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Result {
  WatchData? data;
  bool closed = false;
}

WatchData _sample() => WatchData(
      categories: ['웹 플러그인', '키보드보안'],
      items: [
        const WatchItem('VeraPort', categories: ['웹 플러그인'], note: '통합설치'),
        const WatchItem('AnySign', categories: ['웹 플러그인']),
        const WatchItem('nxKey', categories: ['키보드보안'], note: '키보드 보안'),
        const WatchItem('OldThing'),
      ],
      modes: [
        const WatchMode('뱅킹', on: ['웹 플러그인'], revertMinutes: 30),
        const WatchMode('개발'),
      ],
      defaultMode: '개발',
    );

// OldThing 은 이 PC에 없고, nxKey 만 실행 중이다.
const _running = <String, bool?>{'veraport': false, 'anysign': false, 'nxkey': true, 'oldthing': null};

Future<_Result> _open(WidgetTester tester, WatchData data) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 1600);
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
            out.data = await showModeManager(context, data, running: _running);
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

/// 새 모드 편집 창을 열고 서비스별 탭으로 간다.
Future<void> _newModeServicesTab(WidgetTester tester, String name) async {
  await tester.tap(find.text('모드 추가'));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextField, '모드 이름'), name);
  await tester.tap(find.text('서비스별'));
  await tester.pumpAndSettle();
}

Finder _segment(String service, String label) => find.descendant(
      of: find.ancestor(of: find.text(service), matching: find.byType(Row)).first,
      matching: find.text(label),
    );

void main() {
  testWidgets('서비스별 탭에서 서비스를 골라 작은 모드를 만든다', (tester) async {
    final out = await _open(tester, _sample());
    await _newModeServicesTab(tester, '○○은행');

    expect(find.text('서비스별'), findsOneWidget);
    expect(find.text('4개 표시'), findsOneWidget);

    // 사이트가 요구하는 네 서비스 중 둘만 켜기로 정한다.
    await tester.tap(_segment('VeraPort', '켜기'));
    await tester.pumpAndSettle();
    await tester.tap(_segment('AnySign', '켜기'));
    await tester.pumpAndSettle();
    expect(find.text('직접 지정 (2)'), findsOneWidget);

    await tester.tap(find.text('저장').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    final m = out.data!.modeNamed('○○은행')!;
    expect(m.services, {'veraport': Want.on, 'anysign': Want.on});
    expect(m.on, isEmpty, reason: '카테고리는 건드리지 않았다');
    // 정한 서비스만 켜지고 나머지 감시 서비스는 꺼진다.
    expect(wantFor(m, out.data!.items[0]), Want.on);
    expect(wantFor(m, out.data!.items[2]), Want.off);
  });

  testWidgets('눌린 것을 다시 누르면 지정이 풀려 카테고리 기준으로 돌아간다', (tester) async {
    final out = await _open(tester, _sample());
    await _newModeServicesTab(tester, '임시');
    await tester.tap(_segment('nxKey', '켜기'));
    await tester.pumpAndSettle();
    expect(find.text('직접 지정 (1)'), findsOneWidget);
    await tester.tap(_segment('nxKey', '켜기'));
    await tester.pumpAndSettle();
    expect(find.text('직접 지정 (0)'), findsOneWidget);

    await tester.tap(find.text('저장').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(out.data!.modeNamed('임시')!.services, isEmpty);
  });

  testWidgets('검색은 이름·메모·카테고리를 보고, 결과가 없으면 안내한다', (tester) async {
    await _open(tester, _sample());
    await _newModeServicesTab(tester, 'x');
    final box = find.widgetWithText(TextField, '서비스 검색 (이름·메모·카테고리)');

    await tester.enterText(box, 'anysign');
    await tester.pumpAndSettle();
    expect(find.text('1개 표시'), findsOneWidget);

    await tester.enterText(box, '통합설치'); // 메모
    await tester.pumpAndSettle();
    expect(find.text('1개 표시'), findsOneWidget);
    expect(find.text('VeraPort'), findsOneWidget);

    await tester.enterText(box, '키보드보안'); // 카테고리
    await tester.pumpAndSettle();
    expect(find.text('1개 표시'), findsOneWidget);
    expect(find.text('nxKey'), findsOneWidget);

    await tester.enterText(box, 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('조건에 맞는 서비스가 없어요.'), findsOneWidget);
  });

  testWidgets('설치됨·실행 중 거르기', (tester) async {
    await _open(tester, _sample());
    await _newModeServicesTab(tester, 'x');
    expect(find.text('OldThing  (설치되지 않음)'), findsOneWidget);

    await tester.tap(find.text('설치됨'));
    await tester.pumpAndSettle();
    expect(find.text('3개 표시'), findsOneWidget);
    expect(find.textContaining('OldThing'), findsNothing);

    await tester.tap(find.text('실행 중'));
    await tester.pumpAndSettle();
    expect(find.text('1개 표시'), findsOneWidget);
    expect(find.text('nxKey'), findsOneWidget);
  });

  testWidgets('보이는 서비스를 한꺼번에 정하고 풀 수 있다 (검색 결과에만 적용)', (tester) async {
    final out = await _open(tester, _sample());
    await _newModeServicesTab(tester, '한꺼번에');
    await tester.enterText(find.widgetWithText(TextField, '서비스 검색 (이름·메모·카테고리)'), '웹 플러그인');
    await tester.pumpAndSettle();
    expect(find.text('2개 표시'), findsOneWidget);

    await tester.tap(find.text('2개 표시'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("보이는 서비스 모두 '켜기'로"));
    await tester.pumpAndSettle();
    expect(find.text('직접 지정 (2)'), findsOneWidget);

    await tester.tap(find.text('2개 표시'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('보이는 서비스 지정 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('직접 지정 (0)'), findsOneWidget);

    await tester.tap(find.text('2개 표시'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("보이는 서비스 모두 '켜기'로"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(out.data!.modeNamed('한꺼번에')!.services, {'veraport': Want.on, 'anysign': Want.on});
  });

  testWidgets('카테고리 기준 동작을 흐리게 보여 주고, 서비스 지정이 덮어쓰면 그 줄에서는 숨긴다', (tester) async {
    await _open(tester, _sample());
    await tester.tap(find.byTooltip('모드 수정').first); // 뱅킹: 웹 플러그인 켜기
    await tester.pumpAndSettle();
    await tester.tap(find.text('서비스별'));
    await tester.pumpAndSettle();
    expect(find.textContaining('웹 플러그인  ·  카테고리 기준: 켜기'), findsNWidgets(2));
    expect(find.textContaining('키보드보안  ·  카테고리 기준: 끄기'), findsOneWidget);

    await tester.tap(_segment('VeraPort', '끄기')); // 카테고리는 켜기지만 이 서비스만 끄기
    await tester.pumpAndSettle();
    expect(find.textContaining('웹 플러그인  ·  카테고리 기준: 켜기'), findsOneWidget);
  });

  testWidgets('복제: 서비스 지정까지 그대로 복사한 새 모드가 생긴다', (tester) async {
    final data = _sample();
    data.updateMode('뱅킹', data.modeNamed('뱅킹')!.copyWith(services: {'nxkey': Want.on}));
    final out = await _open(tester, data);
    expect(find.textContaining('서비스 직접 지정 1개'), findsOneWidget);

    await tester.tap(find.byTooltip('모드 복제').first);
    await tester.pumpAndSettle();
    expect(find.text('뱅킹 복사'), findsOneWidget);
    await tester.tap(find.byTooltip('모드 복제').first);
    await tester.pumpAndSettle();
    expect(find.text('뱅킹 복사 2'), findsOneWidget, reason: '이름이 겹치지 않게 번호가 붙는다');

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final copy = out.data!.modeNamed('뱅킹 복사')!;
    expect(copy.on, ['웹 플러그인']);
    expect(copy.services, {'nxkey': Want.on});
    expect(copy.revertMinutes, 30);
    expect(out.data!.defaultMode, '개발');
  });
}
