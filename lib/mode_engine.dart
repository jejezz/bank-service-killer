import 'watch_item.dart';

/// [Want]는 watch_item.dart 에 있다 (모드가 서비스별 동작을 저장하므로). 여기서도 쓰도록 다시 내보낸다.
export 'watch_item.dart' show Want;

/// 모드가 서비스 하나에 바라는 것. 우선순위: 서비스를 직접 정한 값 → 카테고리 켜기 → 카테고리 그대로 → 끄기.
Want wantFor(WatchMode mode, WatchItem item) {
  final direct = mode.services[item.name.toLowerCase()];
  if (direct != null) return direct;
  if (item.categories.any(mode.on.contains)) return Want.on;
  if (item.categories.any(mode.keep.contains)) return Want.keep;
  return Want.off;
}

/// 감시 항목 하나의 지금 상태. [running]이 null 이면 이 PC에 설치되지 않은 서비스다.
class ItemState {
  const ItemState(this.item, this.running);

  final WatchItem item;
  final bool? running;

  bool get installed => running != null;
}

/// 모드를 얼마나 만족하는지. 설치된 서비스 중 "건드리지 않음"이 아닌 것만 센다.
class ModeProgress {
  const ModeProgress(this.ok, this.total);

  final int ok;
  final int total;

  bool get done => total > 0 && ok == total;
  double get ratio => total == 0 ? 0 : ok / total;
}

ModeProgress progressOf(WatchMode mode, List<ItemState> states) {
  var ok = 0, total = 0;
  for (final s in states) {
    if (!s.installed) continue;
    final want = wantFor(mode, s.item);
    if (want == Want.keep) continue;
    total++;
    if ((want == Want.on) == s.running!) ok++;
  }
  return ModeProgress(ok, total);
}

/// 지금 상태가 어느 모드인지.
class ModeStatus {
  const ModeStatus({this.current, this.closest, this.closestProgress = const ModeProgress(0, 0)});

  /// 목표 상태와 정확히 맞는 모드. 없으면 null (= 혼합).
  final WatchMode? current;

  /// 혼합일 때 가장 가까운 모드와 그 진행 상황 (표시용).
  final WatchMode? closest;
  final ModeProgress closestProgress;
}

/// 실제 서비스 상태로 현재 모드를 판정한다. 여러 모드가 동시에 맞으면 [preferred](마지막으로 적용한 모드)를,
/// 없으면 목록에서 앞선 모드를 고른다.
ModeStatus detect(WatchData data, List<ItemState> states, {String? preferred}) {
  WatchMode? current;
  WatchMode? closest;
  var best = const ModeProgress(0, 0);
  for (final m in data.modes) {
    final p = progressOf(m, states);
    if (p.done && (current == null || m.name == preferred)) current = m;
    if (closest == null || p.ratio > best.ratio) {
      closest = m;
      best = p;
    }
  }
  if (current != null) return ModeStatus(current: current, closest: current, closestProgress: progressOf(current, states));
  return ModeStatus(closest: closest, closestProgress: best);
}

/// 지금 상태를 서비스별 동작으로 옮긴 것: 실행 중이면 켜기, 아니면 끄기. 이 PC에 설치되지 않은 서비스는 뺀다.
/// 키는 서비스 이름(소문자)이라 [WatchMode.services] 에 그대로 쓸 수 있다.
Map<String, Want> snapshotServices(List<ItemState> states) => {
      for (final s in states)
        if (s.installed) s.item.name.toLowerCase(): s.running! ? Want.on : Want.off,
    };

/// 모드로 바꾸려면 무엇을 켜고 끌지. 이미 맞는 서비스는 건드리지 않는다.
class ModePlan {
  const ModePlan({required this.start, required this.stop});

  final List<WatchItem> start;
  final List<WatchItem> stop;

  bool get isEmpty => start.isEmpty && stop.isEmpty;
  int get total => start.length + stop.length;
}

/// 끌 것은 목록의 거꾸로(나중에 쌓인 것부터), 켤 것은 목록 순서대로 처리하도록 담는다.
ModePlan planFor(WatchMode mode, List<ItemState> states) {
  final start = <WatchItem>[];
  final stop = <WatchItem>[];
  for (final s in states) {
    if (!s.installed) continue;
    switch (wantFor(mode, s.item)) {
      case Want.on:
        if (!s.running!) start.add(s.item);
      case Want.off:
        if (s.running!) stop.add(s.item);
      case Want.keep:
        break;
    }
  }
  return ModePlan(start: start, stop: stop.reversed.toList());
}
