import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/installed.dart';
import 'package:bank_service_killer/service_manager.dart';
import 'package:bank_service_killer/catalog/search_button.dart';
import 'package:bank_service_killer/catalog/web_search.dart';
import 'package:bank_service_killer/l10n/app_localizations.dart';
import 'package:bank_service_killer/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

InstalledService _svc({
  String name = 'nossvc',
  String display = 'nProtect Online Security',
  String path = r'C:\Users\someone\AppData\nprotect\npkcsvc.exe',
}) =>
    InstalledService(name: name, displayName: display, exe: exeBaseName(path), path: path);

void main() {
  group('searchQuery', () {
    test('이름은 따옴표로 묶고 표시 이름과 실행 파일 이름을 덧붙인다', () {
      expect(searchQuery(_svc()), '"nossvc" nProtect Online Security npkcsvc.exe');
    });

    test('같은 이름은 한 번만 쓴다 (대소문자 무시)', () {
      expect(searchQuery(_svc(name: 'Foo', display: 'foo', path: r'C:\x\FOO.exe')), '"Foo" foo.exe');
    });

    test('표시 이름이나 실행 파일이 없으면 이름만 쓴다', () {
      expect(searchQuery(_svc(display: '', path: '')), '"nossvc"');
    });

    test('경로(사용자 이름이 섞일 수 있다)는 검색어에 넣지 않는다', () {
      final q = searchQuery(_svc());
      expect(q, isNot(contains('someone')));
      expect(q, isNot(contains(r'C:\')));
      expect(q, isNot(contains('AppData')));
    });
  });

  group('searchTargetFor (메인 목록의 줄)', () {
    test('이 PC에 있는 서비스는 서비스 이름·표시 이름·실행 파일 이름으로 검색한다', () {
      const svc = SvcInfo(
        name: 'nossvc',
        displayName: 'nProtect Online Security',
        state: 'Running',
        startMode: 'Auto',
        path: r'"C:\Users\someone\nprotect\npkcsvc.exe" -svc',
        pid: 1,
      );
      final t = searchTargetFor(svc: svc, itemName: '목록에 적은 이름');
      expect(searchQuery(t), '"nossvc" nProtect Online Security npkcsvc.exe');
      expect(searchQuery(t), isNot(contains('someone')));
    });

    test('설치되지 않은(이름 불일치) 줄은 목록에 적은 이름만으로 검색한다', () {
      final t = searchTargetFor(itemName: 'ToucnEn_nxFireWall');
      expect(searchQuery(t), '"ToucnEn_nxFireWall"');
    });
  });

  group('SearchEngine', () {
    test('검색어를 인코딩해 각 엔진의 검색 주소를 만든다', () {
      final s = _svc(name: 'A B&C', display: '', path: '');
      final q = Uri.encodeQueryComponent('"A B&C"');
      expect(searchUri(SearchEngine.google, s).toString(), 'https://www.google.com/search?q=$q');
      expect(searchUri(SearchEngine.naver, s).toString(), 'https://search.naver.com/search.naver?query=$q');
      expect(searchUri(SearchEngine.bing, s).toString(), 'https://www.bing.com/search?q=$q');
      expect(searchUri(SearchEngine.duckDuckGo, s).toString(), 'https://duckduckgo.com/?q=$q');
    });

    test('쿼리 값은 한 덩어리로 돌려받을 수 있다 (& 가 새지 않는다)', () {
      final u = searchUri(SearchEngine.google, _svc(name: 'A&B=C', display: '', path: ''));
      expect(u.queryParameters.keys, ['q']);
      expect(u.queryParameters['q'], '"A&B=C"');
    });

    test('한글 서비스 이름도 그대로 돌려받는다', () {
      final u = searchUri(SearchEngine.naver, _svc(name: '보안서비스', display: '', path: ''));
      expect(u.queryParameters['query'], '"보안서비스"');
    });

    test('모두 https 이다', () {
      for (final e in SearchEngine.values) {
        expect(e.uri('x').scheme, 'https');
      }
    });
  });

  group('AppSettings.searchEngine', () {
    test('기본은 Google 이고 바꾸면 저장되어 다시 읽힌다', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await AppSettings.load();
      expect(s.searchEngine, SearchEngine.google);
      var notified = 0;
      s.addListener(() => notified++);
      await s.setSearchEngine(SearchEngine.naver);
      expect(s.searchEngine, SearchEngine.naver);
      expect(notified, 1);
      await s.setSearchEngine(SearchEngine.naver);
      expect(notified, 1, reason: '같은 값이면 알리지 않는다');
      final again = await AppSettings.load();
      expect(again.searchEngine, SearchEngine.naver);
    });

    test('알 수 없는 값은 Google 로 떨어진다', () async {
      SharedPreferences.setMockInitialValues({AppSettings.searchEngineKey: 'altavista'});
      expect((await AppSettings.load()).searchEngine, SearchEngine.google);
    });
  });

  group('위젯', () {
    Widget app(Widget child, {AppSettings? settings}) {
      final home = Scaffold(body: Center(child: child));
      return MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: settings == null ? home : AppSettingsScope(settings: settings, child: home),
      );
    }

    testWidgets('검색 단추는 설정이 없으면 Google 을, 있으면 고른 엔진을 안내한다', (tester) async {
      await tester.pumpWidget(app(ServiceSearchButton(_svc())));
      expect(find.byTooltip('Google에서 검색 (브라우저가 열려요)'), findsOneWidget);

      SharedPreferences.setMockInitialValues({AppSettings.searchEngineKey: 'naver'});
      final settings = (await tester.runAsync(AppSettings.load))!;
      await tester.pumpWidget(app(ServiceSearchButton(_svc()), settings: settings));
      expect(find.byTooltip('Naver에서 검색 (브라우저가 열려요)'), findsOneWidget);
    });

    testWidgets('엔진 메뉴: 설정이 없으면 그리지 않고, 있으면 현재 엔진을 보이며 바꿀 수 있다', (tester) async {
      await tester.pumpWidget(app(const SearchEngineMenu()));
      expect(find.textContaining('검색 엔진'), findsNothing);

      SharedPreferences.setMockInitialValues({});
      final settings = (await tester.runAsync(AppSettings.load))!;
      await tester.pumpWidget(app(const SearchEngineMenu(), settings: settings));
      expect(find.text('검색 엔진: Google'), findsOneWidget);

      await tester.tap(find.text('검색 엔진: Google'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bing'));
      await tester.pumpAndSettle();
      expect(settings.searchEngine, SearchEngine.bing);
      expect(find.text('검색 엔진: Bing'), findsOneWidget);
    });
  });
}
