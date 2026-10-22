import 'catalog.dart';

/// 카탈로그를 사람이 고칠 때 생기는 실수를 찾는다. 문제가 없으면 빈 목록.
/// 게시 전 검사(`tool/catalog/verify.dart`)와 테스트가 쓴다.
List<String> lintCatalog(Catalog c) {
  final problems = <String>[];
  final ids = <String>{};
  for (final p in c.products) {
    if (!ids.add(p.id)) problems.add('duplicate product id: ${p.id}');
    if (p.name.trim().isEmpty) problems.add('${p.id}: empty name');
    if (p.rules.isEmpty) problems.add('${p.id}: no match rules');
    for (final r in p.rules) {
      if (r.isEmpty) problems.add('${p.id}: a match rule has no fields');
      // 서명자만으로 찾는 규칙은 너무 넓다 (같은 회사의 다른 제품까지 잡는다).
      if (r.service == null && r.exe == null && r.signer != null) {
        problems.add('${p.id}: a rule with only "signer" is too broad');
      }
    }
    for (final cat in p.categories) {
      if (!c.categories.containsKey(cat)) problems.add('${p.id}: unknown category "$cat"');
    }
  }
  for (final e in c.categories.entries) {
    if (e.value.of('en').isEmpty && e.value.of('ko').isEmpty) problems.add('category ${e.key}: no name');
  }
  return problems;
}
