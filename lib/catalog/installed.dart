import '../service_manager.dart';
import 'catalog.dart';

/// 서비스 조회 결과([SvcInfo])를 카탈로그와 견줄 수 있는 모양으로 바꾼다.
extension SvcInfoCatalog on SvcInfo {
  /// 실행 파일 전체 경로 (서명 조회와 후보 판정에만 쓰고 밖으로 내보내지 않는다).
  String get exePath => exeFullPath(path);

  InstalledService toInstalled({String? signer}) => InstalledService(
        name: name,
        displayName: displayName,
        exe: exeBaseName(path),
        signer: signer,
        path: exePath,
      );

  /// Windows 가 직접 깔아 둔 서비스(Windows 폴더 아래)인가. 후보와 신고 대상에서 뺀다.
  bool get isWindowsOwn => toInstalled().isWindowsOwn;
}

/// 감시 목록의 한 줄을 웹에서 검색할 때 쓸 서비스 정보. 이 PC에 있으면 서비스 이름·표시 이름·실행 파일 이름을 쓰고,
/// 없으면(설치되지 않음 / 이름 불일치) 목록에 적은 이름만 쓴다.
InstalledService searchTargetFor({SvcInfo? svc, required String itemName}) =>
    svc?.toInstalled() ?? InstalledService(name: itemName);

/// 서명자 조회 결과 (경로 → 서명자, 서명이 없으면 ''). 같은 파일을 다시 조사하지 않게 앱이 들고 있는다.
/// 서명 확인은 파일마다 시간이 걸려서, 새로 생긴 파일만 조사하는 데 쓴다.
class SignerCache {
  /// [lookup] 은 시험에서 가짜로 바꿀 수 있다 (기본은 PowerShell 로 실제 조사).
  SignerCache({Future<Map<String, String>> Function(Iterable<String>)? lookup})
      : _lookup = lookup ?? ServiceManager.signers;

  final Future<Map<String, String>> Function(Iterable<String>) _lookup;
  final Map<String, String> _byPath = {};

  /// [paths] 중 아직 모르는 것만 조사해 채운다.
  Future<void> fill(Iterable<String> paths) async {
    final missing = [for (final p in paths.toSet()) if (p.isNotEmpty && !_byPath.containsKey(p)) p];
    if (missing.isEmpty) return;
    final found = await _lookup(missing);
    for (final p in missing) {
      _byPath[p] = found[p] ?? '';
    }
  }

  /// 조사했고 서명이 있으면 그 주체, 아니면 null.
  String? of(String path) {
    final v = _byPath[path];
    return v == null || v.isEmpty ? null : v;
  }

  bool has(String path) => _byPath.containsKey(path);
}

/// [all]을 [InstalledService]로 바꾼다.
///
/// 서명자는 카탈로그에 서명자 규칙이 있거나 [withSigners]가 true 일 때만 조사한다 (Windows 자체 서비스는 제외).
/// [signerFor]가 있으면 그 이름(소문자)의 서비스만 조사한다 — 새로 생긴 서비스만 보고 싶을 때 쓴다.
Future<List<InstalledService>> loadInstalled(
  List<SvcInfo> all,
  Catalog catalog, {
  SignerCache? cache,
  bool withSigners = false,
  Set<String>? signerFor,
}) async {
  final needSigners = withSigners || catalog.products.any((p) => p.rules.any((r) => r.signer != null));
  final c = cache ?? SignerCache();
  if (needSigners) {
    await c.fill([
      for (final s in all)
        if (!s.isWindowsOwn && (signerFor == null || signerFor.contains(s.name.toLowerCase()))) s.exePath,
    ]);
  }
  return [for (final s in all) s.toInstalled(signer: needSigners ? c.of(s.exePath) : null)];
}
