/// 카탈로그에 없는 서비스를 신고할 때 보내는 내용.
///
/// 서버가 없으므로 신고는 "미리 채운 GitHub 이슈 화면을 브라우저에서 여는 것"이다. 사용자가 내용을
/// 보고 직접 제출하므로 동의가 분명하고, 앱이 몰래 보내는 것은 없다.
/// 개인정보가 섞이지 않게 **서비스 이름, 표시 이름, 실행 파일 이름, 서명자, 카탈로그 버전**만 담는다.
/// (경로는 사용자 이름이 들어갈 수 있어 보내지 않는다.)
class ServiceReport {
  const ServiceReport({
    required this.serviceName,
    required this.displayName,
    required this.exeName,
    this.signer,
    required this.catalogVersion,
  });

  final String serviceName;
  final String displayName;
  final String exeName;
  final String? signer;
  final int catalogVersion;

  String get title => 'Catalog: $serviceName';

  /// 사용자가 제출 전에 그대로 읽을 수 있는 본문.
  String get body => [
        'Service name: $serviceName',
        'Display name: $displayName',
        'Executable: $exeName',
        'Signer: ${signer == null || signer!.isEmpty ? '(unsigned or unknown)' : signer}',
        'Catalog version: $catalogVersion',
        '',
        'Used by (bank / securities / government / other) and what it does:',
        '',
      ].join('\n');

  /// 미리 채운 새 이슈 주소. [issuesNewUrl] 은 `…/issues/new`.
  Uri url(String issuesNewUrl) =>
      Uri.parse(issuesNewUrl).replace(queryParameters: {'title': title, 'body': body, 'labels': 'catalog'});
}
