import 'package:url_launcher/url_launcher.dart';

import 'catalog.dart';

/// 서비스를 웹에서 검색할 때 쓸 검색엔진. Windows 는 사용자의 "기본 검색엔진"을 앱에 알려 주지 않으므로
/// 고를 수 있게 하고, 기본은 [google] 이다.
enum SearchEngine {
  google('Google', 'https://www.google.com/search?q='),
  naver('Naver', 'https://search.naver.com/search.naver?query='),
  bing('Bing', 'https://www.bing.com/search?q='),
  duckDuckGo('DuckDuckGo', 'https://duckduckgo.com/?q=');

  const SearchEngine(this.label, this._prefix);

  final String label;
  final String _prefix;

  /// [query]를 인코딩해 검색 주소를 만든다.
  Uri uri(String query) => Uri.parse('$_prefix${Uri.encodeQueryComponent(query)}');
}

/// 검색어: 서비스 이름(따옴표로 묶음) + 표시 이름 + 실행 파일 이름.
/// 이름이 같은 것은 한 번만 쓴다. **경로는 넣지 않는다** (사용자 이름이 들어갈 수 있다).
String searchQuery(InstalledService s) {
  final parts = <String>['"${s.name}"'];
  final seen = <String>{s.name.toLowerCase()};
  for (final extra in [s.displayName, s.exe]) {
    final t = extra.trim();
    if (t.isNotEmpty && seen.add(t.toLowerCase())) parts.add(t);
  }
  return parts.join(' ');
}

Uri searchUri(SearchEngine engine, InstalledService s) => engine.uri(searchQuery(s));

/// 기본 브라우저로 검색 결과를 연다. 열지 못하면 false.
Future<bool> openSearch(SearchEngine engine, InstalledService s) async {
  try {
    return await launchUrl(searchUri(engine, s), mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
