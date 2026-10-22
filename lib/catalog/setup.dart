import '../watch_item.dart';
import 'catalog.dart';
import 'discovery.dart';
import 'heuristics.dart';

/// 첫 실행 마법사가 보여 줄 것: 이 PC에서 찾은 보안 서비스.
class SetupPlan {
  const SetupPlan({this.found = const [], this.candidates = const []});

  /// 카탈로그가 아는 서비스 (미리 체크해서 보여 준다).
  final List<CatalogHit> found;

  /// 카탈로그에는 없지만 보안 프로그램처럼 보이는 서비스 (체크하지 않고 이유와 함께 보여 준다).
  final List<Suspect> candidates;

  bool get isEmpty => found.isEmpty && candidates.isEmpty;
}

/// 이 PC의 서비스([installed])에서 카탈로그와 후보 규칙으로 보안 서비스를 찾는다.
/// 이미 [data]에 있는 서비스는 뺀다. 아무것도 바꾸지 않는다.
SetupPlan planSetup(Catalog catalog, WatchData data, List<InstalledService> installed, {Set<String> skip = const {}}) {
  final found = discover(catalog, data, installed).newFinds;
  final known = {
    ...skip,
    for (final h in found) h.service.name.toLowerCase(),
    for (final h in findHits(catalog, installed)) h.service.name.toLowerCase(),
    for (final s in installed)
      if (data.items.any((i) => itemCovers(i, s))) s.name.toLowerCase(),
  };
  final candidates = findSuspects(Heuristics.defaults.merge(catalog.heuristics), installed, skip: known);
  return SetupPlan(found: found, candidates: candidates);
}

/// 사용자가 고른 것을 [data]에 반영한다.
///
/// - [hits]는 카탈로그의 카테고리 이름으로, [suspects]는 [candidateCategory]에 넣는다.
/// - 넣은 서비스의 카테고리는 [modeNames] 모드에서 "켜기"로 지정한다 (안 그러면 모든 모드가 그 서비스를 끈다).
/// 실제로 새로 넣은 서비스 개수를 돌려준다.
int applySetup(
  WatchData data,
  Catalog catalog, {
  required List<CatalogHit> hits,
  required List<Suspect> suspects,
  required Set<String> modeNames,
  required String lang,
  required String candidateCategory,
}) {
  final before = data.items.length;
  addFinds(data, catalog, hits, lang);
  final added = <String>{};
  for (final h in hits) {
    final item = data.items.where((i) => i.name.toLowerCase() == h.service.name.toLowerCase());
    for (final i in item) {
      added.addAll(i.categories);
    }
  }
  if (suspects.isNotEmpty) {
    data.addCategory(candidateCategory);
    for (final s in suspects) {
      if (data.items.any((i) => i.name.toLowerCase() == s.service.name.toLowerCase())) continue;
      data.items.add(WatchItem(s.service.name, categories: [candidateCategory]));
      added.add(candidateCategory);
    }
  }
  for (final m in modeNames) {
    for (final c in added) {
      data.enableCategoryIn(m, c);
    }
  }
  return data.items.length - before;
}
