import '../service_manager.dart';
import 'catalog.dart';

/// 서비스 조회 결과([SvcInfo])를 카탈로그와 견줄 수 있는 모양으로 바꾼다.
extension SvcInfoCatalog on SvcInfo {
  /// 실행 파일 전체 경로 (서명 조회에만 쓰고 밖으로 내보내지 않는다).
  String get exePath => exeFullPath(path);

  InstalledService toInstalled({String? signer}) =>
      InstalledService(name: name, displayName: displayName, exe: exeBaseName(path), signer: signer);

  /// Windows 가 직접 깔아 둔 서비스(Windows 폴더 아래)인가. 신고 후보에서 뺀다.
  bool get isWindowsOwn {
    final p = exePath.toLowerCase();
    return p.contains(r'\windows\') || p.contains(r'\windowsapps\');
  }
}

/// [all]을 [InstalledService]로 바꾼다. 카탈로그에 서명자 규칙이 있을 때만 서명자를 조사한다
/// (Windows 자체 서비스는 제외). 조사는 파일마다 시간이 걸린다.
Future<List<InstalledService>> loadInstalled(List<SvcInfo> all, Catalog catalog) async {
  final needSigners = catalog.products.any((p) => p.rules.any((r) => r.signer != null));
  Map<String, String> signers = const {};
  if (needSigners) {
    signers = await ServiceManager.signers([for (final s in all) if (!s.isWindowsOwn) s.exePath]);
  }
  return [
    for (final s in all)
      s.toInstalled(signer: signers[s.exePath]?.isEmpty ?? true ? null : signers[s.exePath]),
  ];
}
