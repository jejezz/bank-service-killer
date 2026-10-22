import 'dart:convert';
import 'dart:io';

/// 감시 대상 서비스 항목. name은 서비스 이름 또는 표시 이름(부분 일치 가능).
/// 카테고리는 사용자가 만드는 이름이고, 한 서비스가 여러 카테고리에 속할 수 있다.
class WatchItem {
  final String name;
  final List<String> categories;
  final String note;

  const WatchItem(this.name, {this.categories = const [], this.note = ''});

  WatchItem copyWith({String? name, List<String>? categories, String? note}) =>
      WatchItem(name ?? this.name, categories: categories ?? this.categories, note: note ?? this.note);

  Map<String, dynamic> toJson() => {'name': name, 'categories': categories, 'note': note};

  /// v2: `categories` 목록. v1: 단일 `group`(A/B/C)을 [legacyGroups]로 카테고리 이름에 옮긴다.
  factory WatchItem.fromJson(Map<String, dynamic> j, {Map<String, String> legacyGroups = const {}}) {
    final raw = j['categories'];
    final List<String> cats;
    if (raw is List) {
      cats = [for (final c in raw) c.toString()];
    } else {
      final g = (j['group'] ?? 'B').toString();
      cats = [legacyGroups[g] ?? g];
    }
    return WatchItem(j['name'] as String, categories: cats, note: (j['note'] ?? '') as String);
  }
}

/// 감시 목록 전체: 카테고리(순서 있음) + 항목 + 뱅킹 모드에 켤 카테고리.
class WatchData {
  WatchData({
    required List<String> categories,
    required List<WatchItem> items,
    List<String>? bankingCategories,
  })  : categories = List.of(categories),
        items = List.of(items),
        bankingCategories = List.of(bankingCategories ?? const []) {
    _syncCategories();
    // 지정하지 않으면 모든 카테고리가 뱅킹 모드 대상이다.
    if (bankingCategories == null) this.bankingCategories.addAll(this.categories);
  }

  static const version = 2;

  final List<String> categories;
  final List<WatchItem> items;

  /// "뱅킹 모드"가 켜는 카테고리.
  final List<String> bankingCategories;

  /// 항목이 쓰는 카테고리가 목록에 없으면 뒤에 붙인다.
  void _syncCategories() {
    for (final it in items) {
      for (final c in it.categories) {
        if (!categories.contains(c)) categories.add(c);
      }
    }
    bankingCategories.removeWhere((c) => !categories.contains(c));
  }

  WatchData copy() => WatchData(categories: categories, items: items, bankingCategories: bankingCategories);

  bool isInBankingMode(WatchItem item) => item.categories.any(bankingCategories.contains);

  int countIn(String category) => items.where((i) => i.categories.contains(category)).length;

  int get uncategorizedCount => items.where((i) => i.categories.isEmpty).length;

  /// 카테고리를 추가한다. 이미 있거나 빈 이름이면 false.
  bool addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty || categories.contains(n)) return false;
    categories.add(n);
    return true;
  }

  /// 이름을 바꾼다. 항목·뱅킹 모드 설정도 따라 바뀐다. 겹치거나 빈 이름이면 false.
  bool renameCategory(String from, String to) {
    final n = to.trim();
    if (n.isEmpty || (n != from && categories.contains(n))) return false;
    String map(String c) => c == from ? n : c;
    final cats = categories.map(map).toList();
    final bank = bankingCategories.map(map).toList();
    final its = [for (final i in items) i.copyWith(categories: i.categories.map(map).toList())];
    categories
      ..clear()
      ..addAll(cats);
    bankingCategories
      ..clear()
      ..addAll(bank);
    items
      ..clear()
      ..addAll(its);
    return true;
  }

  /// 카테고리만 지운다. 서비스 항목은 남고 그 카테고리에서만 빠진다.
  void deleteCategory(String name) {
    categories.remove(name);
    bankingCategories.remove(name);
    final its = [
      for (final i in items) i.copyWith(categories: i.categories.where((c) => c != name).toList())
    ];
    items
      ..clear()
      ..addAll(its);
  }

  void setBanking(String category, bool on) {
    if (!categories.contains(category)) return;
    if (on) {
      if (!bankingCategories.contains(category)) bankingCategories.add(category);
    } else {
      bankingCategories.remove(category);
    }
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'categories': categories,
        'bankingCategories': bankingCategories,
        'items': items.map((e) => e.toJson()).toList(),
      };

  /// v2(객체) 또는 v1(항목 배열, group A/B/C)을 읽는다.
  /// [legacyGroups]는 v1의 A/B/C → 카테고리 이름 (표시 언어로 만든다).
  factory WatchData.fromJson(Object? json, {required Map<String, String> legacyGroups}) {
    if (json is Map<String, dynamic>) {
      final items = [
        for (final e in (json['items'] as List? ?? const []))
          WatchItem.fromJson(e as Map<String, dynamic>, legacyGroups: legacyGroups)
      ];
      final cats = [for (final c in (json['categories'] as List? ?? const [])) c.toString()];
      final banking = json['bankingCategories'] is List
          ? [for (final c in json['bankingCategories'] as List) c.toString()]
          : null;
      return WatchData(categories: cats, items: items, bankingCategories: banking);
    }
    final items = [
      for (final e in (json as List))
        WatchItem.fromJson(e as Map<String, dynamic>, legacyGroups: legacyGroups)
    ];
    return WatchData._fromLegacy(items, legacyGroups);
  }

  factory WatchData._fromLegacy(List<WatchItem> items, Map<String, String> legacyGroups) {
    final used = {for (final i in items) ...i.categories};
    final legacyNames = legacyGroups.values;
    final cats = [
      ...legacyNames.where(used.contains),
      ...used.where((c) => !legacyNames.contains(c)),
    ];
    // v1에서 A는 "보안 무관" 이라 뱅킹 모드에는 넣지 않는다.
    final notSecurity = legacyGroups['A'];
    return WatchData(
      categories: cats,
      items: items,
      bankingCategories: cats.where((c) => c != notSecurity).toList(),
    );
  }

  /// 처음 실행할 때의 기본 목록.
  factory WatchData.defaults(Map<String, String> legacyGroups) {
    final items = [
      for (final (name, group, note) in _defaultItems)
        WatchItem(name, categories: [legacyGroups[group] ?? group], note: note),
    ];
    return WatchData._fromLegacy(items, legacyGroups);
  }
}

const _defaultItems = <(String, String, String)>[
  ('Nahimic service', 'A', '오디오 효과 (보안 아님)'),
  ('AnySign4PC Launcher', 'B', ''),
  ('CrossEX Live Checker', 'B', ''),
  ('Image SAFER 5.0 Service', 'B', ''),
  ('INNORIX EX Management', 'B', ''),
  ('INNORIX EX Service', 'B', ''),
  ('Interezen LWS', 'B', ''),
  ('KOSCOMSecLogGather', 'B', ''),
  ('MagicLine4NX Service', 'B', ''),
  ('nxTS Process Manager Service', 'C', '키보드보안, 드라이버 연동 가능'),
  ('OZWLservice', 'B', ''),
  ('SignKoreaWD', 'B', ''),
  ('ToucnEn_nxFireWall', 'C', '개인방화벽, 드라이버 연동 가능'),
  ('WIZVERA Process Manager Service', 'B', ''),
];

/// %APPDATA%\BankServiceKiller\watchlist.json 에 감시 목록을 저장/로드한다.
class WatchStore {
  static File get _file {
    final base = Platform.environment['APPDATA'] ?? Directory.current.path;
    return File('$base\\BankServiceKiller\\watchlist.json');
  }

  /// 이름을 바꾸기 전(Bank Breaker)에 쓰던 위치. 새 파일이 없을 때만 읽는다.
  static File get _legacyFile {
    final base = Platform.environment['APPDATA'] ?? Directory.current.path;
    return File('$base\\BankBreaker\\watchlist.json');
  }

  /// [legacyGroups]: v1 파일의 그룹 A/B/C 를 옮겨 담을 카테고리 이름.
  static Future<WatchData> load({required Map<String, String> legacyGroups}) async {
    try {
      final file = await _file.exists() ? _file : _legacyFile;
      if (await file.exists()) {
        return WatchData.fromJson(jsonDecode(await file.readAsString()), legacyGroups: legacyGroups);
      }
    } catch (_) {}
    return WatchData.defaults(legacyGroups);
  }

  static Future<void> save(WatchData data) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(const JsonEncoder.withIndent('  ').convert(data.toJson()));
  }
}
