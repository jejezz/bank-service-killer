import 'dart:convert';

/// 카탈로그 서명 확인용 공개키(base64)로 쓸 수 있는 값인가: Ed25519 공개키는 32바이트다.
bool isValidPublicKey(String s) {
  try {
    return base64.decode(s.trim()).length == 32;
  } catch (_) {
    return false;
  }
}

/// 쓸 공개키를 정한다.
///
/// 1. 빌드 때 `--dart-define=CATALOG_PUBLIC_KEY=…` 로 준 값이 있으면 그것 ([defined]).
/// 2. 없으면 앱에 들어 있는 `catalog/public_key.txt` ([readAsset]).
///
/// 둘 다 없거나 형식이 틀리면 빈 문자열이고, 그러면 원격 카탈로그 갱신이 꺼진다.
/// 공개키는 항상 **앱 안에** 있다 — 네트워크에서 받은 파일로 정하지 않는다. 그래야 저장소를 뚫은 사람이
/// 카탈로그와 공개키를 함께 바꿔치기해도 통과하지 못한다.
Future<String> resolveCatalogPublicKey({
  required String defined,
  required Future<String> Function() readAsset,
}) async {
  final d = defined.trim();
  if (d.isNotEmpty) return isValidPublicKey(d) ? d : '';
  try {
    final t = (await readAsset()).trim();
    return isValidPublicKey(t) ? t : '';
  } catch (_) {
    return '';
  }
}
