import 'package:flutter/foundation.dart';

/// 모드를 화면 밖(트레이 메뉴 등)과 주고받는 연결 고리.
/// HomePage 가 살아 있는 동안 상태를 채우고 [apply]를 연결한다. 트레이는 이 변화를 듣고 메뉴를 다시 그린다.
class ModeActions extends ChangeNotifier {
  List<String> _names = const [];
  String? _current;
  String? _summary;
  int _alerts = 0;

  /// 모드 이름들(표시 순서).
  List<String> get names => _names;

  /// 지금 상태와 정확히 맞는 모드. 혼합이면 null.
  String? get current => _current;

  /// 트레이 툴팁 등에 쓸 한 줄 상태.
  String? get summary => _summary;

  /// 새로 제안된 서비스 개수 (카탈로그 제안 + 새 보안 서비스 후보). 트레이 툴팁에 쓴다.
  int get alerts => _alerts;

  /// 이름의 모드로 바꾼다. HomePage 가 없으면 null.
  Future<void> Function(String name)? apply;

  void update({
    required List<String> names,
    required String? current,
    required String? summary,
    int alerts = 0,
  }) {
    if (listEquals(names, _names) && current == _current && summary == _summary && alerts == _alerts) return;
    _alerts = alerts;
    _names = List.of(names);
    _current = current;
    _summary = summary;
    notifyListeners();
  }

  /// 연결을 끊는다 (HomePage 가 사라질 때). 빌드 중에 알리지 않으려고 notify 는 하지 않는다.
  void detach() {
    apply = null;
  }
}
