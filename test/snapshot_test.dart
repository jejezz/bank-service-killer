import 'package:bank_service_killer/l10n/app_localizations.dart';
import 'package:bank_service_killer/mode_engine.dart';
import 'package:bank_service_killer/snapshot_dialog.dart';
import 'package:bank_service_killer/watch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

WatchItem _i(String name, [List<String> cats = const []]) => WatchItem(name, categories: cats);

ItemState _s(String name, bool? running, [List<String> cats = const []]) => ItemState(_i(name, cats), running);

WatchData _sample() => WatchData(
      categories: ['보안'],
      items: [_i('Foo', ['보안']), _i('Bar'), _i('Baz')],
      modes: [
        const WatchMode('뱅킹', on: ['보안'], keep: [], revertMinutes: 30),
        const WatchMode('개발'),
      ],
      defaultMode: '개발',
    );

void main() {
  group('snapshotServices', () {
    test('실행 중이면 켜기, 아니면 끄기, 설치되지 않은 서비스는 뺀다', () {
      final m = snapshotServices([_s('Foo', true), _s('Bar', false), _s('Gone', null), _s('Baz', true)]);
      expect(m, {'foo': Want.on, 'bar': Want.off, 'baz': Want.on});
    });

    test('아무것도 없으면 비어 있다', () {
      expect(snapshotServices(const []), isEmpty);
    });

    test('저장한 상태는 그 모드와 정확히 맞는다 (저장 직후 현재 모드로 판정된다)', () {
      final states = [_s('Foo', true, ['보안']), _s('Bar', false), _s('Baz', true)];
      final data = _sample();
      expect(data.saveSnapshot('지금', snapshotServices(states), overwrite: false), isTrue);
      expect(detect(data, states, preferred: '지금').current?.name, '지금');
      expect(planFor(data.modeNamed('지금')!, states).isEmpty, isTrue);
    });
  });

  group('saveSnapshot', () {
    final services = {'foo': Want.on, 'bar': Want.off, 'baz': Want.on};

    test('새 모드: 서비스 지정만 가진 모드가 만들어진다', () {
      final d = _sample();
      expect(d.saveSnapshot('지금', services, overwrite: false), isTrue);
      final m = d.modeNamed('지금')!;
      expect(m.services, services);
      expect(m.on, isEmpty);
      expect(m.keep, isEmpty);
      expect(m.revertMinutes, 0);
      expect(d.modes.length, 3);
    });

    test('새 모드: 빈 이름이나 겹치는 이름이면 만들지 않는다', () {
      final d = _sample();
      expect(d.saveSnapshot('  ', services, overwrite: false), isFalse);
      expect(d.saveSnapshot('뱅킹', services, overwrite: false), isFalse);
      expect(d.modes.length, 2);
    });

    test('덮어쓰기: 카테고리 지정은 비우고 서비스 지정을 지금 상태로 바꾸며, 이름과 자동 복귀는 그대로다', () {
      final d = _sample();
      expect(d.saveSnapshot('뱅킹', services, overwrite: true), isTrue);
      final m = d.modeNamed('뱅킹')!;
      expect(m.services, services);
      expect(m.on, isEmpty, reason: '남기면 저장한 상태와 어긋난다');
      expect(m.revertMinutes, 30);
      expect(d.modes.length, 2, reason: '새 모드가 생기지 않는다');
      expect(d.modes.map((x) => x.name), ['뱅킹', '개발']);
    });

    test('덮어쓰기: 이전 서비스 지정은 사라지고 새 것으로 바뀐다', () {
      final d = _sample();
      d.saveSnapshot('개발', {'foo': Want.on}, overwrite: true);
      d.saveSnapshot('개발', {'bar': Want.off}, overwrite: true);
      expect(d.modeNamed('개발')!.services, {'bar': Want.off});
    });

    test('덮어쓰기: 없는 모드면 거절한다', () {
      final d = _sample();
      expect(d.saveSnapshot('없음', services, overwrite: true), isFalse);
    });

    test('기본 모드를 덮어써도 기본 모드는 그대로다', () {
      final d = _sample();
      d.saveSnapshot('개발', services, overwrite: true);
      expect(d.defaultMode, '개발');
    });
  });

  group('스냅샷 대화상자', () {
    Future<List<SnapshotChoice?>> open(WidgetTester tester, {String? suggested}) async {
      final results = <SnapshotChoice?>[];
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 900);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => results.add(
                await showSnapshotDialog(context, data: _sample(), on: 3, off: 2, skipped: 1, suggested: suggested),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('저장될 개수를 보여 준다', (tester) async {
      await open(tester);
      expect(find.text('서비스 5개의 지금 상태를 저장해요: 켜짐 3개, 꺼짐 2개.'), findsOneWidget);
      expect(find.text('이 PC에 설치되지 않은 서비스 1개는 빼요.'), findsOneWidget);
    });

    testWidgets('새 모드: 이름을 넣어야 저장되고, 이름 입력칸 힌트로 겹치지 않는 기본 이름을 제안한다', (tester) async {
      final results = await open(tester);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, '저장')).onPressed, isNull);
      expect(find.text('현재 상태'), findsOneWidget, reason: '힌트');

      await tester.enterText(find.byType(TextField), '○○은행');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '저장'));
      await tester.pumpAndSettle();
      expect(results.single!.name, '○○은행');
      expect(results.single!.overwrite, isFalse);
    });

    testWidgets('새 모드: 이미 있는 이름이면 오류를 보이고 저장할 수 없다', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextField), '뱅킹');
      await tester.pumpAndSettle();
      expect(find.text('이미 있거나 사용할 수 없는 이름이에요.'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, '저장')).onPressed, isNull);
    });

    testWidgets('덮어쓰기: 기존 모드를 고르고 안내가 나오며, 기본 모드면 경고를 더한다', (tester) async {
      final results = await open(tester, suggested: '뱅킹');
      await tester.tap(find.text('기존 모드에 덮어쓰기'));
      await tester.pumpAndSettle();
      expect(find.textContaining('덮어쓰면 그 모드의 카테고리·서비스 지정이 지금 상태로 바뀌어요'), findsOneWidget);
      expect(find.textContaining('기본 모드예요'), findsNothing);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('개발  (기본)').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('기본 모드예요'), findsOneWidget);

      await tester.tap(find.text('덮어쓰기').last);
      await tester.pumpAndSettle();
      expect(results.single!.name, '개발');
      expect(results.single!.overwrite, isTrue);
    });

    testWidgets('취소하면 null', (tester) async {
      final results = await open(tester);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(results.single, isNull);
    });
  });
}
