// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get aboutTooltip => '정보';

  @override
  String aboutVersion(String version, String build) {
    return '버전 $version (빌드 $build)';
  }

  @override
  String get aboutOpenSourceLicenses => '오픈소스 라이선스';

  @override
  String get aboutRepository => 'GitHub';

  @override
  String get commonClose => '닫기';

  @override
  String aboutMenuItem(String appName) {
    return '$appName 정보';
  }

  @override
  String get themeMenuTooltip => '테마';

  @override
  String get themeSystem => '시스템 설정 따르기';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get languageMenuTooltip => '언어';

  @override
  String get languageSystem => '시스템 설정 따르기 / System';

  @override
  String get languageSystemShort => '시스템';

  @override
  String get aboutTagline => '금융보안 서비스를 필요할 때만 켜고 끄는 도구';

  @override
  String get aboutDescription =>
      '금융보안·키보드보안 같은 상주 서비스를 뱅킹할 때만 켜고, 끝나면 끄고, 실제로 반영됐는지 확인해요.';

  @override
  String get homeEmptyTitle => '감시할 서비스가 없어요';

  @override
  String get homeEmptyAction => '서비스 추가';

  @override
  String get updateCheckMenuItem => '업데이트 확인';

  @override
  String get updateChecking => '업데이트를 확인하는 중…';

  @override
  String get updateAvailableTitle => '새 버전이 있습니다';

  @override
  String updateAvailableBody(String appName, String current, String latest) {
    return '$appName $latest 버전이 나왔습니다. (현재 $current)';
  }

  @override
  String get updateReleaseNotes => '변경 내용';

  @override
  String get updateNow => '지금 업데이트';

  @override
  String get updateLater => '나중에';

  @override
  String get updateSkipVersion => '이 버전 건너뛰기';

  @override
  String get updateDownloading => '내려받는 중…';

  @override
  String get updateVerifying => '파일을 확인하는 중…';

  @override
  String updateDownloadProgress(String received, String total) {
    return '$received / $total';
  }

  @override
  String get updateCancel => '취소';

  @override
  String get updateFailedTitle => '업데이트하지 못했습니다';

  @override
  String get updateCheckFailedTitle => '업데이트를 확인하지 못했습니다';

  @override
  String get updateErrorNetwork =>
      '업데이트 서버에 연결하지 못했습니다. 인터넷 연결을 확인한 뒤 다시 시도해 주세요.';

  @override
  String get updateErrorChecksum =>
      '내려받은 파일이 올바르지 않아 설치하지 않았습니다. 잠시 뒤에 다시 시도해 주세요.';

  @override
  String get updateErrorInstall => '설치를 시작하지 못했습니다.';

  @override
  String get updateErrorGeneric =>
      '업데이트 서버에서 예상하지 못한 응답을 받았습니다. 잠시 뒤에 다시 시도해 주세요.';

  @override
  String get updateUpToDateTitle => '최신 버전입니다';

  @override
  String updateUpToDateBody(String version) {
    return '$version 버전을 사용 중입니다.';
  }

  @override
  String get updateUnavailableTitle => '직접 설치해 주세요';

  @override
  String updateUnavailableBody(String latest) {
    return '$latest 버전이 있지만 앱에서 자동으로 설치할 수 없습니다. 릴리스 페이지에서 받아 주세요.';
  }

  @override
  String get updateOpenReleasePage => '릴리스 페이지 열기';

  @override
  String get updateBrowserDownloadTitle => '브라우저에서 내려받습니다';

  @override
  String updateBrowserDownloadBody(String appName) {
    return '브라우저가 새 버전 내려받기를 시작합니다. 받은 DMG를 열어 $appName 을(를) Applications 폴더로 끌어다 놓아 주세요. 실행 중이면 종료한 뒤 덮어쓰세요.';
  }

  @override
  String get updateMacosOpenedTitle => '설치 창이 열렸습니다';

  @override
  String updateMacosOpenedBody(String appName) {
    return '열린 창에서 $appName 을(를) Applications 폴더로 끌어다 놓아 주세요. 실행 중이면 종료한 뒤 덮어쓰세요.';
  }

  @override
  String get updateWindowsInstallTitle => '설치 프로그램을 열었습니다';

  @override
  String updateWindowsInstallBody(String appName) {
    return '설치하려면 $appName 을(를) 종료해야 합니다. 설치 프로그램의 안내를 따라 주세요.';
  }

  @override
  String updateQuitApp(String appName) {
    return '$appName 종료';
  }

  @override
  String get updateLinuxInstallTitle => '설치를 준비했습니다';

  @override
  String updateLinuxInstallBody(String appName) {
    return '$appName 을(를) 종료하고 설치합니다. 설치가 끝나면 자동으로 다시 시작됩니다.';
  }

  @override
  String get updateQuitAndInstall => '종료하고 설치';

  @override
  String get updateBusyTitle => '지금은 업데이트할 수 없습니다';

  @override
  String get updateBusyBody => '작업이 진행 중입니다. 끝난 뒤에 다시 시도해 주세요.';

  @override
  String get commonCancel => '취소';

  @override
  String get commonAdd => '추가';

  @override
  String get homeTurnOnAll => '전체 켜기 (뱅킹용)';

  @override
  String get homeTurnOffAll => '전체 끄기';

  @override
  String get refreshTooltip => '새로 고침 (F5)';

  @override
  String get addServiceTooltip => '서비스 추가 (Ctrl+N)';

  @override
  String get adminWarning =>
      '관리자 권한이 아니에요. 서비스 시작·중지·설정 변경은 관리자 권한으로 실행해야 동작해요.';

  @override
  String get trayShow => '창 열기';

  @override
  String get trayExit => '종료';

  @override
  String get startupMenuTooltip => '시작프로그램';

  @override
  String get startupAutoRun => 'Windows 시작 시 자동 실행 (트레이 상주)';

  @override
  String startupChangeFailed(String detail) {
    return '시작프로그램 설정을 바꾸지 못했어요: $detail';
  }

  @override
  String get notInstalled => '설치되지 않음 / 이름 불일치';

  @override
  String serviceSubtitle(String displayName, String state, String startMode) {
    return '$displayName · $state · 시작 유형 $startMode';
  }

  @override
  String get msconfigDisabledNote => ' · msconfig 비활성';

  @override
  String get startModeAuto => '자동';

  @override
  String get startModeManual => '수동';

  @override
  String get startModeDisabled => '사용 안 함';

  @override
  String get stopVerifyTooltip => '중지 후 검증';

  @override
  String get startVerifyTooltip => '시작 후 검증';

  @override
  String get removeTooltip => '목록에서 제거';

  @override
  String get addDialogTitle => '감시 서비스 추가';

  @override
  String get addDialogField => '서비스 이름 또는 표시 이름';

  @override
  String get groupA => 'A: 보안 무관';

  @override
  String get groupB => 'B: 웹 플러그인';

  @override
  String get groupC => 'C: 드라이버 연동 가능';

  @override
  String logQueryError(String error) {
    return '조회 오류: $error';
  }

  @override
  String logAlreadyInList(String name) {
    return '이미 목록에 있음: $name';
  }

  @override
  String logLine(String name, String message) {
    return '$name: $message';
  }

  @override
  String get logOk => 'OK';

  @override
  String get logFail => '실패';

  @override
  String get logEmptyTitle => '작업 기록';

  @override
  String svcModeChanged(String mode) {
    return '시작 유형을 $mode (으)로 변경';
  }

  @override
  String svcStartCmdFailed(int code, String detail) {
    return '시작 명령 실패($code): $detail';
  }

  @override
  String svcStopCmdFailed(int code, String detail) {
    return '중지 명령 실패($code): $detail';
  }

  @override
  String get svcRestarted => '중지 후 서비스가 다시 시작됨 (감시/복구 동작 의심)';

  @override
  String get svcStopVerified => '중지 확인 (3초 후 재확인도 Stopped)';

  @override
  String get svcNotFound => '서비스를 찾을 수 없음';

  @override
  String svcStateVerified(String label, String target) {
    return '$label 확인 ($target)';
  }

  @override
  String svcStateFailed(String label, String state) {
    return '$label 확인 실패: 현재 상태 $state';
  }

  @override
  String get svcLabelStart => '시작';

  @override
  String get svcLabelStop => '중지';

  @override
  String get svcStateUnknown => '알 수 없음';

  @override
  String svcListFailed(String error) {
    return '서비스 목록 조회 실패: $error';
  }
}
