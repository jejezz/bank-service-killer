// From jejezz/application-release-templates common/ @ conventions-v1.
//
// conventions/identity.md의 값을 앱 코드에 반영하는 유일한 곳이다.
// displayName은 macos/Runner/Configs/AppInfo.xcconfig의 PRODUCT_NAME과 같아야
// 하고, 데스크톱 릴리스 워크플로의 check 잡이 둘을 비교한다.

abstract final class AppIdentity {
  /// 표시 이름. 번역하지 않는다 (conventions/localization.md §2).
  static const displayName = 'Bank Service Killer';

  static const repositoryUrl = 'https://github.com/jejezz/bank-service-killer';

  static const copyrightHolder = 'Jongyun Ahn';

  /// 첫 릴리스 연도. 해마다 바꾸지 않는다.
  static const firstReleaseYear = 2026;

  static const licenseName = 'MIT License';

  /// 256px 사본 — tool/icon/generate_icons.py가 만든다.
  static const iconAsset = 'assets/icon/app_icon.png';

  static const copyright = 'Copyright © $firstReleaseYear $copyrightHolder';

  /// 업데이트 서버 (introduce-public-repos 의 /api/update). 단지(장비)마다 호스트가 다르다 —
  /// 빌드 때 `--dart-define=UPDATE_SERVER=https://…/repos` 로 바꾼다. **빈 값이면 업데이트 확인을 끈다.**
  /// https 만 받는다 (conventions/updating.md).
  static const updateServerUrl = String.fromEnvironment(
    'UPDATE_SERVER',
    defaultValue: 'https://c-a3f19c04.rtc.zoomon.art/repos',
  );

  /// 보안 서비스 카탈로그 주소(https). 서명은 같은 주소 뒤에 `.sig` 를 붙인 곳에 있다.
  /// 빌드 때 `--dart-define=CATALOG_URL=…` 로 바꾼다.
  static const catalogUrl = String.fromEnvironment(
    'CATALOG_URL',
    defaultValue: 'https://raw.githubusercontent.com/jejezz/bank-service-killer/main/catalog/catalog.json',
  );

  /// 카탈로그 서명 확인용 Ed25519 공개키(base64). tool/catalog/keygen.dart 가 만든다.
  /// 비어 있으면 앱에 들어 있는 `catalog/public_key.txt` 를 쓴다(lib/catalog/public_key.dart). 둘 다 없으면 원격 갱신을 끈다.
  static const catalogPublicKey = String.fromEnvironment('CATALOG_PUBLIC_KEY');

  /// 카탈로그에 없는 서비스를 신고하는 이슈 주소.
  static String get newIssueUrl => '$repositoryUrl/issues/new';

  /// 서버가 앱을 아는 이름 = 저장소 이름 (repositoryUrl 의 마지막 경로).
  static String get updateAppId => Uri.parse(repositoryUrl).pathSegments.where((s) => s.isNotEmpty).last;
}
