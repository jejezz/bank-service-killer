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

  /// v2~: `categories` 목록. v1: 단일 `group`(A/B/C)을 [legacyGroups]로 카테고리 이름에 옮긴다.
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

/// 모드가 서비스 하나에 바라는 것.
enum Want { on, off, keep }

/// 모드: 이름 붙은 "목표 상태".
/// [on] 카테고리의 서비스는 켜고, [keep] 카테고리의 서비스는 건드리지 않고,
/// 나머지 감시 서비스는 모두 끈다. (한 서비스가 on 과 keep 에 모두 속하면 on 이 이긴다.)
class WatchMode {
  final String name;
  final List<String> on;
  final List<String> keep;

  /// 이 모드로 바꾼 뒤 기본 모드로 자동 복귀하기까지 분. 0 이면 복귀하지 않는다.
  final int revertMinutes;

  /// 서비스 이름(소문자)으로 직접 정한 동작. 카테고리로 정한 것보다 **우선**한다.
  /// 사이트가 요구하는 서비스만 골라 켜는 작은 모드를 만들 때 쓴다.
  final Map<String, Want> services;

  const WatchMode(
    this.name, {
    this.on = const [],
    this.keep = const [],
    this.revertMinutes = 0,
    this.services = const {},
  });

  WatchMode copyWith({
    String? name,
    List<String>? on,
    List<String>? keep,
    int? revertMinutes,
    Map<String, Want>? services,
  }) =>
      WatchMode(
        name ?? this.name,
        on: on ?? this.on,
        keep: keep ?? this.keep,
        revertMinutes: revertMinutes ?? this.revertMinutes,
        services: services ?? this.services,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'on': on,
        'keep': keep,
        'revertMinutes': revertMinutes,
        if (services.isNotEmpty) 'services': {for (final e in services.entries) e.key: e.value.name},
      };

  factory WatchMode.fromJson(Map<String, dynamic> j) {
    final raw = j['services'];
    final svc = <String, Want>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        final w = Want.values.asNameMap()[e.value.toString()];
        if (w != null) svc[e.key.toString().toLowerCase()] = w;
      }
    }
    return WatchMode(
      j['name'] as String,
      on: [for (final c in (j['on'] as List? ?? const [])) c.toString()],
      keep: [for (final c in (j['keep'] as List? ?? const [])) c.toString()],
      revertMinutes: (j['revertMinutes'] ?? 0) as int,
      services: svc,
    );
  }
}

/// 처음 만들 때·옛 파일을 옮길 때 쓰는 표시 언어별 이름들.
class WatchDefaults {
  const WatchDefaults({
    required this.groupA,
    required this.groupB,
    required this.groupC,
    required this.bankingMode,
    required this.devMode,
  });

  final String groupA;
  final String groupB;
  final String groupC;
  final String bankingMode;
  final String devMode;

  Map<String, String> get legacyGroups => {'A': groupA, 'B': groupB, 'C': groupC};
}

/// 감시 목록 전체: 카테고리(순서 있음) + 항목 + 모드.
class WatchData {
  WatchData({
    required List<String> categories,
    required List<WatchItem> items,
    List<WatchMode> modes = const [],
    String? defaultMode,
  })  : categories = List.of(categories),
        items = List.of(items),
        modes = List.of(modes),
        _defaultMode = defaultMode {
    _sync();
  }

  static const version = 4;

  final List<String> categories;
  final List<WatchItem> items;
  final List<WatchMode> modes;
  String? _defaultMode;

  /// 앱을 시작하거나 자동 복귀할 때 적용하는 모드 이름. 모드가 없으면 null.
  String? get defaultMode => _defaultMode;

  /// 항목이 쓰는 카테고리를 목록에 보충하고, 모드가 가리키는 없는 카테고리·기본 모드를 바로잡는다.
  void _sync() {
    for (final it in items) {
      for (final c in it.categories) {
        if (!categories.contains(c)) categories.add(c);
      }
    }
    for (var i = 0; i < modes.length; i++) {
      final m = modes[i];
      final names = {for (final it in items) it.name.toLowerCase()};
      modes[i] = m.copyWith(
        on: m.on.where(categories.contains).toList(),
        keep: m.keep.where(categories.contains).toList(),
        // 목록에 없는 서비스를 가리키는 직접 지정은 버린다.
        services: {for (final e in m.services.entries) if (names.contains(e.key)) e.key: e.value},
      );
    }
    if (modes.isEmpty) {
      _defaultMode = null;
    } else if (_defaultMode == null || !modes.any((m) => m.name == _defaultMode)) {
      _defaultMode = modes.first.name;
    }
  }

  WatchData copy() => WatchData(categories: categories, items: items, modes: modes, defaultMode: _defaultMode);

  WatchMode? modeNamed(String? name) {
    for (final m in modes) {
      if (m.name == name) return m;
    }
    return null;
  }

  int countIn(String category) => items.where((i) => i.categories.contains(category)).length;

  int get uncategorizedCount => items.where((i) => i.categories.isEmpty).length;

  // ── 카테고리 편집 ─────────────────────────────────────────

  /// 카테고리를 추가한다. 이미 있거나 빈 이름이면 false.
  bool addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty || categories.contains(n)) return false;
    categories.add(n);
    return true;
  }

  void _replaceAll<T>(List<T> target, List<T> source) => target
    ..clear()
    ..addAll(source);

  /// 이름을 바꾼다. 항목·모드도 따라 바뀐다. 겹치거나 빈 이름이면 false.
  bool renameCategory(String from, String to) {
    final n = to.trim();
    if (n.isEmpty || (n != from && categories.contains(n))) return false;
    String map(String c) => c == from ? n : c;
    _replaceAll(categories, categories.map(map).toList());
    _replaceAll(items, [for (final i in items) i.copyWith(categories: i.categories.map(map).toList())]);
    _replaceAll(modes, [
      for (final m in modes) m.copyWith(on: m.on.map(map).toList(), keep: m.keep.map(map).toList())
    ]);
    return true;
  }

  /// 카테고리만 지운다. 서비스 항목은 남고 그 카테고리에서만 빠진다.
  void deleteCategory(String name) {
    categories.remove(name);
    _replaceAll(items, [
      for (final i in items) i.copyWith(categories: i.categories.where((c) => c != name).toList())
    ]);
    _replaceAll(modes, [
      for (final m in modes)
        m.copyWith(on: m.on.where((c) => c != name).toList(), keep: m.keep.where((c) => c != name).toList())
    ]);
  }

  // ── 서비스 항목 편집 (모드의 직접 지정도 함께 갱신) ─────────────────

  /// 서비스 항목 이름을 바꾼다. 모드에서 그 이름으로 정한 동작도 따라 옮긴다. 다른 항목과 겹치거나 빈 이름이면 false.
  bool renameItem(String from, String to) {
    final n = to.trim();
    final i = items.indexWhere((e) => e.name == from);
    if (i < 0 || n.isEmpty) return false;
    if (items.any((e) => e.name.toLowerCase() == n.toLowerCase() && e.name != from)) return false;
    items[i] = items[i].copyWith(name: n);
    final fromKey = from.toLowerCase(), toKey = n.toLowerCase();
    if (fromKey != toKey) {
      _replaceAll(modes, [
        for (final m in modes)
          m.services.containsKey(fromKey)
              ? m.copyWith(services: {
                  for (final e in m.services.entries) e.key == fromKey ? toKey : e.key: e.value,
                })
              : m,
      ]);
    }
    return true;
  }

  /// 서비스 항목을 지운다. 모드에서 그 서비스에 정한 동작도 함께 지운다.
  void removeItem(String name) {
    items.removeWhere((e) => e.name == name);
    final key = name.toLowerCase();
    _replaceAll(modes, [
      for (final m in modes)
        m.services.containsKey(key)
            ? m.copyWith(services: {for (final e in m.services.entries) if (e.key != key) e.key: e.value})
            : m,
    ]);
  }

  // ── 모드 편집 ─────────────────────────────────────────────

  /// [base]와 겹치지 않는 모드 이름 ("뱅킹 복사", "뱅킹 복사 2" …).
  String uniqueModeName(String base) {
    if (!modes.any((m) => m.name == base)) return base;
    for (var n = 2;; n++) {
      final candidate = '$base $n';
      if (!modes.any((m) => m.name == candidate)) return candidate;
    }
  }

  /// 모드를 추가한다. 이름이 비었거나 겹치면 false.
  bool addMode(WatchMode mode) {
    final n = mode.name.trim();
    if (n.isEmpty || modes.any((m) => m.name == n)) return false;
    modes.add(mode.copyWith(name: n));
    _sync();
    return true;
  }

  /// [name] 모드를 [mode]로 바꾼다 (이름 변경 포함). 이름이 비었거나 다른 모드와 겹치면 false.
  bool updateMode(String name, WatchMode mode) {
    final i = modes.indexWhere((m) => m.name == name);
    final n = mode.name.trim();
    if (i < 0 || n.isEmpty || modes.any((m) => m.name == n && m.name != name)) return false;
    modes[i] = mode.copyWith(name: n);
    if (_defaultMode == name) _defaultMode = n;
    _sync();
    return true;
  }

  /// [category]를 [mode] 모드에서 "켜기"로 지정한다 ("그대로"에 있었으면 거기서 뺀다). 없는 모드·카테고리면 false.
  bool enableCategoryIn(String mode, String category) {
    final i = modes.indexWhere((m) => m.name == mode);
    if (i < 0 || !categories.contains(category)) return false;
    final m = modes[i];
    modes[i] = m.copyWith(
      on: m.on.contains(category) ? m.on : [...m.on, category],
      keep: m.keep.where((c) => c != category).toList(),
    );
    return true;
  }

  /// 마지막 하나는 지울 수 없다. 기본 모드를 지우면 첫 모드가 기본이 된다.
  bool deleteMode(String name) {
    if (modes.length <= 1) return false;
    modes.removeWhere((m) => m.name == name);
    _sync();
    return true;
  }

  bool setDefaultMode(String name) {
    if (!modes.any((m) => m.name == name)) return false;
    _defaultMode = name;
    return true;
  }

  // ── 저장 형식 ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'version': version,
        'categories': categories,
        'modes': modes.map((m) => m.toJson()).toList(),
        'defaultMode': _defaultMode,
        'items': items.map((e) => e.toJson()).toList(),
      };

  /// v3(모드), v2(뱅킹 카테고리), v1(항목 배열, group A/B/C)을 모두 읽는다.
  factory WatchData.fromJson(Object? json, {required WatchDefaults defaults}) {
    final legacy = defaults.legacyGroups;
    if (json is Map<String, dynamic>) {
      final items = [
        for (final e in (json['items'] as List? ?? const []))
          WatchItem.fromJson(e as Map<String, dynamic>, legacyGroups: legacy)
      ];
      final cats = [for (final c in (json['categories'] as List? ?? const [])) c.toString()];
      if (json['modes'] is List) {
        return WatchData(
          categories: cats,
          items: items,
          modes: [for (final m in json['modes'] as List) WatchMode.fromJson(m as Map<String, dynamic>)],
          defaultMode: json['defaultMode'] as String?,
        );
      }
      // v2: bankingCategories → 뱅킹/개발 두 모드.
      final all = {...cats, for (final i in items) ...i.categories}.toList();
      final banking = json['bankingCategories'] is List
          ? [for (final c in json['bankingCategories'] as List) c.toString()]
          : all;
      return WatchData(
        categories: all,
        items: items,
        modes: _bankingAndDev(defaults, on: banking, keep: all.where((c) => !banking.contains(c)).toList()),
        defaultMode: defaults.devMode,
      );
    }
    final items = [
      for (final e in (json as List)) WatchItem.fromJson(e as Map<String, dynamic>, legacyGroups: legacy)
    ];
    return _fresh(items, defaults);
  }

  static List<WatchMode> _bankingAndDev(WatchDefaults d,
          {required List<String> on, required List<String> keep}) =>
      [
        WatchMode(d.bankingMode, on: on, keep: keep, revertMinutes: 30),
        WatchMode(d.devMode),
      ];

  /// 항목만 있고 모드가 없을 때(v1·처음 실행): A 는 "보안 무관" 이라 뱅킹 모드에서 건드리지 않는다.
  static WatchData _fresh(List<WatchItem> items, WatchDefaults d) {
    final used = {for (final i in items) ...i.categories};
    final names = d.legacyGroups.values;
    final cats = [...names.where(used.contains), ...used.where((c) => !names.contains(c))];
    return WatchData(
      categories: cats,
      items: items,
      modes: _bankingAndDev(
        d,
        on: cats.where((c) => c != d.groupA).toList(),
        keep: cats.where((c) => c == d.groupA).toList(),
      ),
      defaultMode: d.devMode,
    );
  }

  /// 새로 설치했을 때의 시작 데이터: 서비스 항목은 없고 모드(뱅킹·개발)만 있다.
  /// 서비스는 고정 목록이 아니라 이 PC에서 찾은 것으로 채운다 (첫 실행 마법사).
  factory WatchData.initial(WatchDefaults d) => _fresh(const [], d);
}

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

  /// 저장된 목록이 이미 있는가 (이 앱이나 옛 이름 Bank Breaker 로). 없으면 새로 설치한 것이다.
  static Future<bool> hasSaved() async => await _file.exists() || await _legacyFile.exists();

  static Future<WatchData> load({required WatchDefaults defaults}) async {
    File? file;
    try {
      file = await _file.exists() ? _file : _legacyFile;
      if (await file.exists()) {
        return WatchData.fromJson(jsonDecode(await file.readAsString()), defaults: defaults);
      }
    } catch (_) {
      // 읽을 수 없는 파일은 덮어쓰기 전에 옆에 남겨 둔다 (목록을 조용히 잃지 않게).
      try {
        await file?.copy('${file.path}.broken');
      } catch (_) {}
    }
    return WatchData.initial(defaults);
  }

  static Future<void> save(WatchData data) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(const JsonEncoder.withIndent('  ').convert(data.toJson()));
  }
}
