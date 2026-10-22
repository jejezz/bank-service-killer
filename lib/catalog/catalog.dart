/// 보안 서비스 카탈로그: 어떤 제품이 어떤 서비스로 설치되는지 적어 둔 데이터.
///
/// 서비스 이름은 제품 버전마다 바뀌므로 이름 하나가 아니라 여러 식별 규칙(서비스 이름,
/// 실행 파일명, 서명자)으로 찾는다. 카탈로그는 "제안"일 뿐이고 목록에 넣을지는 사용자가 정한다.
library;

/// JSON 객체를 `Map<String, dynamic>` 으로. 객체가 아니면 [FormatException].
Map<String, dynamic> _asMap(Object? v) {
  if (v is Map) return Map<String, dynamic>.from(v);
  throw const FormatException('expected a JSON object');
}

/// 이 앱이 읽을 수 있는 카탈로그 형식 버전.
const supportedCatalogSchema = 1;

/// 언어별 문구. 요청한 언어가 없으면 영어, 그것도 없으면 아무거나.
class LocalizedText {
  const LocalizedText(this._byLang);

  final Map<String, String> _byLang;

  String of(String lang) => _byLang[lang] ?? _byLang['en'] ?? (_byLang.values.isEmpty ? '' : _byLang.values.first);

  factory LocalizedText.fromJson(Object? json) {
    if (json is String) return LocalizedText({'en': json});
    if (json is Map) return LocalizedText({for (final e in json.entries) e.key.toString(): e.value.toString()});
    return const LocalizedText({});
  }
}

/// 이 PC에 설치된 서비스 하나 (카탈로그와 견주는 쪽의 최소 정보).
class InstalledService {
  const InstalledService({required this.name, this.displayName = '', this.exe = '', this.signer});

  final String name;
  final String displayName;

  /// 실행 파일 이름(소문자, 경로·인자 없음). 모르면 빈 문자열.
  final String exe;

  /// 실행 파일 서명자(인증서 주체). 아직 조사하지 않았으면 null.
  final String? signer;

  InstalledService withSigner(String? s) =>
      InstalledService(name: name, displayName: displayName, exe: exe, signer: s);
}

/// `"C:\Program Files\X\a.exe" /arg` 같은 서비스 명령줄에서 실행 파일 경로만 뽑는다.
String exeFullPath(String commandLine) {
  var s = commandLine.trim();
  if (s.isEmpty) return '';
  if (s.startsWith('"')) {
    final end = s.indexOf('"', 1);
    s = end < 0 ? s.substring(1) : s.substring(1, end);
  } else {
    final m = RegExp(r'^(.*?\.(exe|sys|dll))(\s|$)', caseSensitive: false).firstMatch(s);
    if (m != null) s = m.group(1)!;
  }
  return s;
}

/// 서비스 명령줄에서 실행 파일 이름만 소문자로 뽑는다 (경로·인자 없음).
String exeBaseName(String commandLine) {
  final s = exeFullPath(commandLine);
  final slash = s.lastIndexOf(RegExp(r'[\\/]'));
  return (slash < 0 ? s : s.substring(slash + 1)).toLowerCase();
}

/// 식별 규칙 하나. 적힌 항목이 **모두** 맞아야 일치하고, 아무 항목도 없으면 일치하지 않는다.
class MatchRule {
  const MatchRule({this.service, this.exe, this.signer});

  /// 서비스 이름 또는 표시 이름과 (대소문자 무시) 같아야 한다.
  final String? service;

  /// 실행 파일 이름과 (대소문자 무시) 같아야 한다.
  final String? exe;

  /// 서명자에 (대소문자 무시) 들어 있어야 한다. 서명자를 아직 모르면 일치하지 않는다.
  final String? signer;

  bool get isEmpty => service == null && exe == null && signer == null;

  bool matches(InstalledService s) {
    if (isEmpty) return false;
    final sv = service?.toLowerCase();
    if (sv != null && sv != s.name.toLowerCase() && sv != s.displayName.toLowerCase()) return false;
    final ex = exe?.toLowerCase();
    if (ex != null && ex != s.exe) return false;
    final sg = signer?.toLowerCase();
    if (sg != null && !(s.signer?.toLowerCase().contains(sg) ?? false)) return false;
    return true;
  }

  factory MatchRule.fromJson(Map<String, dynamic> j) => MatchRule(
        service: j['service'] as String?,
        exe: j['exe'] as String?,
        signer: j['signer'] as String?,
      );
}

class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    this.vendor,
    this.categories = const [],
    this.usedBy = const [],
    this.note = const LocalizedText({}),
    this.rules = const [],
    this.driver = false,
  });

  final String id;
  final String name;
  final String? vendor;

  /// 카탈로그의 카테고리 id들.
  final List<String> categories;

  /// 어디서 쓰이는지 (bank, securities, government …).
  final List<String> usedBy;
  final LocalizedText note;
  final List<MatchRule> rules;

  /// 드라이버와 연동돼 끄면 문제가 생길 수 있는 제품.
  final bool driver;

  bool matches(InstalledService s) => rules.any((r) => r.matches(s));

  /// 이 제품이 [name] 이라는 서비스 이름을 알고 있는가 (이름이 바뀐 서비스를 짚을 때 쓴다).
  bool knowsServiceName(String name) {
    final n = name.toLowerCase();
    return rules.any((r) => r.service?.toLowerCase() == n);
  }

  factory CatalogProduct.fromJson(Map<String, dynamic> j) => CatalogProduct(
        id: j['id'] as String,
        name: j['name'] as String,
        vendor: j['vendor'] as String?,
        categories: [for (final c in (j['categories'] as List? ?? const [])) c.toString()],
        usedBy: [for (final c in (j['usedBy'] as List? ?? const [])) c.toString()],
        note: LocalizedText.fromJson(j['note']),
        rules: [for (final r in (j['match'] as List? ?? const [])) MatchRule.fromJson(_asMap(r))],
        driver: (j['driver'] ?? false) as bool,
      );
}

class Catalog {
  const Catalog({
    required this.schema,
    required this.version,
    required this.updated,
    required this.categories,
    required this.products,
  });

  final int schema;

  /// 올라가기만 하는 정수. 이보다 낮은 카탈로그로는 되돌리지 않는다.
  final int version;
  final String updated;
  final Map<String, LocalizedText> categories;
  final List<CatalogProduct> products;

  String categoryLabel(String id, String lang) => categories[id]?.of(lang) ?? id;

  /// 형식이 맞지 않으면 [FormatException].
  factory Catalog.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) throw const FormatException('catalog is not an object');
    final schema = json['schema'];
    if (schema != supportedCatalogSchema) throw FormatException('unsupported catalog schema: $schema');
    final version = json['version'];
    if (version is! int || version < 0) throw const FormatException('catalog version must be a non-negative integer');
    final cats = json['categories'];
    return Catalog(
      schema: schema as int,
      version: version,
      updated: (json['updated'] ?? '') as String,
      categories: cats is Map ? {for (final e in cats.entries) e.key.toString(): LocalizedText.fromJson(e.value)} : {},
      products: [for (final p in (json['products'] as List? ?? const [])) CatalogProduct.fromJson(_asMap(p))],
    );
  }

  /// [incoming]으로 바꿔도 되는가: 같은 형식이고 버전이 더 높아야 한다 (되돌리기·재생 방지).
  static bool shouldReplace(Catalog? current, Catalog incoming) =>
      incoming.schema == supportedCatalogSchema && (current == null || incoming.version > current.version);
}

/// 카탈로그 제품과 이 PC의 서비스가 짝지어진 것.
class CatalogHit {
  const CatalogHit(this.product, this.service);

  final CatalogProduct product;
  final InstalledService service;
}

/// [services] 각각을 처음 일치하는 제품과 짝짓는다 (한 서비스는 한 제품에만).
List<CatalogHit> findHits(Catalog catalog, List<InstalledService> services) {
  final hits = <CatalogHit>[];
  for (final s in services) {
    for (final p in catalog.products) {
      if (p.matches(s)) {
        hits.add(CatalogHit(p, s));
        break;
      }
    }
  }
  return hits;
}
