/// 서비스 목록 검색: 이름·표시 이름·메모·카테고리 중 하나에 검색어가 들어 있으면 맞는다 (대소문자 무시).
/// 검색어가 비어 있으면(공백 포함) 모두 맞는다. 메인 목록과 모드 편집의 서비스별 탭이 같은 규칙을 쓴다.
bool matchesSearch(
  String query, {
  required String name,
  String displayName = '',
  String note = '',
  List<String> categories = const [],
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return name.toLowerCase().contains(q) ||
      displayName.toLowerCase().contains(q) ||
      note.toLowerCase().contains(q) ||
      categories.any((c) => c.toLowerCase().contains(q));
}
