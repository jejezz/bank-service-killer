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
  String get logTitle => '로그';

  @override
  String get logEmpty => '작업 결과가 여기에 표시돼요.';

  @override
  String get logResizeTooltip => '드래그해서 로그 창 크기 조절';

  @override
  String get helpTooltip => '사용 방법';

  @override
  String get helpTitle => '사용 방법';

  @override
  String get helpClose => '닫기';

  @override
  String get helpPurposeTitle => '이 앱은 무엇인가요?';

  @override
  String get helpPurposeBody =>
      '인터넷 뱅킹 때 필요한 보안 프로그램은 평소엔 PC를 느리게 하거나 충돌을 일으켜요. 이 앱은 그런 상주 서비스를 뱅킹할 때만 켜고, 끝나면 끄고, 실제로 켜졌는지·꺼졌는지 확인해 줘요. 서비스를 제어하려면 관리자 권한이 필요해서 실행할 때 권한 상승(UAC) 창이 떠요.';

  @override
  String get helpListTitle => '서비스 목록은 어디서 오나요?';

  @override
  String get helpListBody =>
      '목록은 자동으로 만들어지지 않아요. 처음에는 흔한 금융·보안 서비스가 미리 들어 있고, 그 뒤로는 직접 관리해요.\n• 추가: 위쪽 + 단추(Ctrl+N)에서 서비스 이름이나 표시 이름을 입력하면 이 PC에 설치된 서비스 중 일치하는 것이 아래에 나타나요. 눌러서 고르면 돼요.\n• 새로 설치된 서비스는 자동으로 감지되지 않아요. 직접 추가해야 해요. 서비스 이름은 msconfig(서비스 탭)나 services.msc에서 볼 수 있어요.\n• 이름이 일부만 같아도 찾아 주고(부분 일치), \"설치되지 않음 / 이름 불일치\"로 나오면 이 PC에 없거나 이름이 달라요.\n• 목록은 %APPDATA%\\BankServiceKiller\\watchlist.json 에 저장돼요. 새로고침(F5)은 서비스의 현재 상태를 다시 읽어 와요.';

  @override
  String get helpGroupTitle => '서비스 이름 뒤의 [A] [B] [C]';

  @override
  String get helpGroupBody =>
      '항목을 추가할 때 고른 분류 표시예요.\n• A: 보안과 무관한 서비스 (예: 오디오 효과)\n• B: 웹 플러그인형 보안 서비스 (대부분의 금융 보안 프로그램)\n• C: 드라이버와 연동될 수 있는 서비스 (키보드보안·개인방화벽 등). 끄면 문제가 생길 수 있으니 주의하세요.\n분류는 참고용이라 켜기·끄기 동작에는 영향이 없어요.';

  @override
  String get helpOnOffTitle => '켜기·끄기';

  @override
  String get helpOnOffBody =>
      '• 전체 켜기 / 끄기, 그리고 항목 오른쪽의 재생·정지 단추는 서비스를 지금 바로 시작하거나 중지해요. 시작 유형이 \'사용 안 함\'이면 \'수동\'으로 바꾼 뒤 시작해요.\n• 시작·중지 후 실제 상태가 바뀌었는지 확인하고 결과를 아래 로그에 남겨요. 중지 후 3초 뒤 다시 살아났는지도 한 번 더 확인해요.\n• 끄기는 서비스를 멈출 뿐 시작 유형은 바꾸지 않아요. 시작 유형이 \'자동\'이면 PC를 다시 켤 때 서비스가 또 시작돼요.';

  @override
  String get helpModeTitle => '시작 유형 (자동 / 수동 / 사용 안 함)';

  @override
  String get helpModeBody =>
      '항목 오른쪽 드롭다운으로 고르면 바로 적용돼요. 다만 지금 실행 중인 서비스를 켜거나 끄지는 않고, 다음 부팅부터의 시작 방식에 영향을 줘요.\n• 자동: 부팅할 때 자동으로 시작돼요.\n• 수동: 부팅 때는 시작되지 않고, 필요할 때 켜기 단추로 시작해요. 뱅킹용 서비스에 권장해요.\n• 사용 안 함: 시작 자체가 막혀요. 이 앱의 켜기 단추는 \'수동\'으로 바꾼 뒤 시작해요.\n\'msconfig 비활성\'은 msconfig에서 해당 서비스를 꺼 둔 상태라는 표시예요.';

  @override
  String get helpResidentTitle => '상주와 시작프로그램';

  @override
  String get helpResidentBody =>
      '창을 닫으면 종료되지 않고 작업 표시줄 오른쪽 트레이에 남아요. 트레이 아이콘을 누르면 창이 열리고, 우클릭 메뉴의 \'종료\'로 완전히 끝내요. 첫 실행 때 Windows 로그온 시 자동으로 시작(창 없이 트레이에만)되도록 등록되며, 위쪽 전원 아이콘 메뉴에서 켜고 끌 수 있어요.';

  @override
  String get commonSave => '저장';

  @override
  String get editTooltip => '이름·분류 수정';

  @override
  String get editDialogTitle => '감시 서비스 수정';

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
