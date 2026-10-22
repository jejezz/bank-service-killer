import '../watch_item.dart';
import 'catalog.dart';

/// 감시 항목 하나가 이 서비스를 가리키는가. 앱이 항목으로 서비스를 찾는 방식과 같다:
/// 서비스 이름·표시 이름이 같거나 한쪽이 다른 쪽을 포함한다 (대소문자 무시).
bool itemCovers(WatchItem item, InstalledService s) {
  final key = item.name.toLowerCase();
  if (key.isEmpty) return false;
  final name = s.name.toLowerCase();
  final display = s.displayName.toLowerCase();
  return name == key || display == key || name.contains(key) || display.contains(key);
}

/// 목록에 있는 항목의 이름이 바뀐 것 같다는 제안: [item] 은 이 PC에 없고, 카탈로그가
/// 그 이름을 아는 제품이 다른 이름의 서비스([hit])로 설치돼 있다.
class RenameSuggestion {
  const RenameSuggestion(this.item, this.hit);

  final WatchItem item;
  final CatalogHit hit;
}

class Discovery {
  const Discovery({this.newFinds = const [], this.renames = const []});

  /// 이 PC에 있는 카탈로그 서비스인데 감시 목록에는 없는 것.
  final List<CatalogHit> newFinds;
  final List<RenameSuggestion> renames;

  bool get isEmpty => newFinds.isEmpty && renames.isEmpty;
  int get count => newFinds.length + renames.length;
}

/// 카탈로그와 이 PC의 서비스, 감시 목록을 견줘 제안을 만든다. 아무것도 바꾸지 않는다.
Discovery discover(Catalog catalog, WatchData data, List<InstalledService> installed) {
  final hits = findHits(catalog, installed);
  final uncovered = [
    for (final h in hits)
      if (!data.items.any((i) => itemCovers(i, h.service))) h,
  ];
  final orphans = [
    for (final i in data.items)
      if (!installed.any((s) => itemCovers(i, s))) i,
  ];

  final renames = <RenameSuggestion>[];
  final consumed = <CatalogHit>{};
  for (final item in orphans) {
    for (final h in uncovered) {
      if (consumed.contains(h)) continue;
      if (h.product.knowsServiceName(item.name)) {
        renames.add(RenameSuggestion(item, h));
        consumed.add(h);
        break;
      }
    }
  }
  return Discovery(
    newFinds: [for (final h in uncovered) if (!consumed.contains(h)) h],
    renames: renames,
  );
}

/// 발견한 서비스를 감시 목록에 더한다. 카탈로그 카테고리는 [lang] 이름으로 사용자 카테고리에
/// 옮기고, 없으면 만든다. 어떤 모드에도 넣지 않으므로 모드는 그대로다.
/// 새로 만든 카테고리 이름들을 돌려준다.
List<String> addFinds(WatchData data, Catalog catalog, List<CatalogHit> hits, String lang) {
  final created = <String>[];
  for (final h in hits) {
    if (data.items.any((i) => i.name.toLowerCase() == h.service.name.toLowerCase())) continue;
    final cats = <String>[];
    for (final id in h.product.categories) {
      final label = catalog.categoryLabel(id, lang);
      if (data.addCategory(label)) created.add(label);
      cats.add(label);
    }
    final note = h.product.note.of(lang);
    data.items.add(WatchItem(
      h.service.name,
      categories: cats,
      note: note.isNotEmpty ? note : h.product.name,
    ));
  }
  return created;
}

/// 이름이 바뀐 항목을 새 서비스 이름으로 고친다. 카테고리와 메모는 그대로다.
void applyRename(WatchData data, RenameSuggestion r) {
  data.renameItem(r.item.name, r.hit.service.name);
}
