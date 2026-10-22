import 'dart:convert';
import 'dart:io';

/// "이미 본 서비스" 기록. 새로 설치된 서비스를 알아채고, 사용자가 무시한 후보를 다시 보여 주지 않기 위해 쓴다.
/// 서비스 이름(소문자)만 저장한다.
class SeenState {
  SeenState({Set<String>? seen, Set<String>? ignored, this.initialized = false})
      : seen = seen ?? {},
        ignored = ignored ?? {};

  /// 이미 본 서비스 이름.
  final Set<String> seen;

  /// 사용자가 "무시"한 서비스 이름 (후보에서 계속 뺀다).
  final Set<String> ignored;

  /// 처음 기준선을 잡았는가. 처음에는 지금 있는 서비스 전부가 "새것"으로 쏟아지지 않게 알리지 않는다.
  bool initialized;

  /// [current] 중 아직 보지 못한 것. 기준선이 없으면(첫 실행) 아무것도 새것이 아니다.
  Set<String> newNames(Iterable<String> current) {
    if (!initialized) return {};
    return {for (final n in current.map((e) => e.toLowerCase())) if (!seen.contains(n)) n};
  }

  /// [current] 를 모두 본 것으로 친다 (첫 실행이면 기준선을 잡는다).
  void markSeen(Iterable<String> current) {
    seen.addAll(current.map((e) => e.toLowerCase()));
    initialized = true;
  }

  void ignore(Iterable<String> names) => ignored.addAll(names.map((e) => e.toLowerCase()));

  Map<String, dynamic> toJson() => {
        'version': 1,
        'initialized': initialized,
        'seen': seen.toList()..sort(),
        'ignored': ignored.toList()..sort(),
      };

  factory SeenState.fromJson(Object? json) {
    if (json is! Map) return SeenState();
    Set<String> set(String k) => {for (final v in (json[k] as List? ?? const [])) v.toString().toLowerCase()};
    return SeenState(seen: set('seen'), ignored: set('ignored'), initialized: json['initialized'] == true);
  }
}

class SeenStore {
  static File get _file {
    final base = Platform.environment['APPDATA'] ?? Directory.current.path;
    return File('$base\\BankServiceKiller\\seen_services.json');
  }

  static Future<SeenState> load() async {
    try {
      if (await _file.exists()) return SeenState.fromJson(jsonDecode(await _file.readAsString()));
    } catch (_) {}
    return SeenState();
  }

  static Future<void> save(SeenState state) async {
    try {
      await _file.parent.create(recursive: true);
      await _file.writeAsString(jsonEncode(state.toJson()));
    } catch (_) {}
  }
}
