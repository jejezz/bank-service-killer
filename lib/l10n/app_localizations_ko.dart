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
  String get helpGroupTitle => '카테고리와 모드';

  @override
  String get helpGroupBody =>
      '• 카테고리: 서비스를 묶는 이름표예요 (예: 키보드보안, 공인인증, 은행별). 한 서비스를 여러 카테고리에 넣어도 돼요. 위쪽 칩을 누르면 그 카테고리만 보이고, \'○○ 켜기 / 끄기\'가 그 카테고리에만 적용돼요.\n• 모드: \'켤 것 · 그대로 둘 것 · 끌 것\'을 정해 둔 목표 상태예요. 위쪽 [뱅킹 | 개발 …] 토글에서 고르면 그 상태가 되도록 서비스를 켜고 꺼요. 이미 맞는 서비스는 건드리지 않아요.\n• 모드를 누르면 먼저 \'끌 서비스 / 켤 서비스\' 미리보기 창이 떠요. 확인하고 [실행]을 누르면 그때 바뀌고, [취소]하면 아무것도 바뀌지 않아요. (앱 시작 시 기본 모드와 자동 복귀는 사람이 없어도 돌아야 해서 묻지 않고 실행해요.)\n• 현재 모드는 저장한 값이 아니라 서비스의 실제 상태로 판단해요. 어느 모드와도 맞지 않으면 \'혼합\'으로 보여 줘요. 혼합일 때 모드를 누르면 남은 서비스만 맞춰요.\n• 모드 관리(슬라이더 아이콘)에서 모드를 만들고 고칠 수 있어요. ★ 기본 모드는 앱을 시작할 때(Windows 로그온 포함)와 자동 복귀할 때 적용돼요.\n• 자동 복귀: 모드마다 시간을 정해 두면 그 뒤 기본 모드로 돌아가요. 1분 전에 알려 줘요.\n• 트레이 아이콘 우클릭 메뉴에서도 모드를 바꿀 수 있고, 현재 모드에 체크가 붙어요.';

  @override
  String get helpOnOffTitle => '켜기·끄기';

  @override
  String get helpOnOffBody =>
      '• 모드 전환, \'○○ 켜기 / 끄기\', 그리고 항목 오른쪽의 재생·정지 단추는 서비스를 지금 바로 시작하거나 중지해요. 시작 유형이 \'사용 안 함\'이면 \'수동\'으로 바꾼 뒤 시작해요.\n• 시작·중지 후 실제 상태가 바뀌었는지 확인하고 결과를 아래 로그에 남겨요. 중지 후 3초 뒤 다시 살아났는지도 한 번 더 확인해요.\n• 끄기는 서비스를 멈출 뿐 시작 유형은 바꾸지 않아요. 시작 유형이 \'자동\'이면 PC를 다시 켤 때 서비스가 또 시작돼요.';

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
  String get systemToolsTooltip => 'Windows 서비스 도구 열기';

  @override
  String get openMsconfig => 'msconfig (서비스 탭)';

  @override
  String get openServicesMsc => '서비스 관리 (services.msc)';

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

  @override
  String get catAll => '전체';

  @override
  String get catUncategorized => '미분류';

  @override
  String get catEmptyFilter => '이 카테고리에는 서비스가 없어요.';

  @override
  String get catManageTooltip => '카테고리 관리';

  @override
  String get catManageTitle => '카테고리 관리';

  @override
  String get catManageHint =>
      '카테고리로 서비스를 묶어 두면 그 묶음만 켜고 끌 수 있고, 모드를 만들 때 재료로 써요. 카테고리를 지워도 서비스는 남아요.';

  @override
  String get catAddField => '새 카테고리 이름';

  @override
  String get catRename => '이름 바꾸기';

  @override
  String get catDelete => '카테고리 삭제';

  @override
  String get catExists => '이미 있거나 사용할 수 없는 이름이에요.';

  @override
  String catItemCount(int n) {
    return '서비스 $n개';
  }

  @override
  String get catDefaultA => '보안 무관';

  @override
  String get catDefaultB => '웹 플러그인';

  @override
  String get catDefaultC => '드라이버 연동';

  @override
  String get addDialogCategories => '카테고리 (여러 개 선택 가능)';

  @override
  String get addDialogNewCategory => '새 카테고리 만들기';

  @override
  String scopeTurnOn(String scope) {
    return '$scope 켜기';
  }

  @override
  String scopeTurnOff(String scope) {
    return '$scope 끄기';
  }

  @override
  String modeCurrent(String name) {
    return '현재 모드: $name';
  }

  @override
  String modeMixed(String name, int ok, int total) {
    return '혼합 상태 · $name $ok/$total';
  }

  @override
  String get modeUnknown => '서비스 상태를 확인하는 중…';

  @override
  String modeRevertIn(int minutes, String name) {
    return '$minutes분 뒤 \'$name\' 모드로 돌아가요';
  }

  @override
  String modeToggleTooltip(String name) {
    return '눌러서 \'$name\' 모드로 바꿔요';
  }

  @override
  String get modeManageTooltip => '모드 관리';

  @override
  String get modeManageTitle => '모드 관리';

  @override
  String get modeManageHint =>
      '모드는 \'켤 것 · 그대로 둘 것 · 끌 것\'을 정해 둔 목표 상태예요. 모드로 바꾸면 켤 카테고리는 켜고, 그대로 둘 카테고리는 건드리지 않고, 나머지 감시 서비스는 모두 꺼요. ★ 표시한 기본 모드는 앱이 시작될 때와 자동 복귀할 때 적용돼요.';

  @override
  String get modeDefaultHint => '기본 모드로 지정 (앱 시작·자동 복귀 때 적용)';

  @override
  String get modeDefaultTag => '기본';

  @override
  String get modeAdd => '모드 추가';

  @override
  String get modeDelete => '모드 삭제 (마지막 하나는 지울 수 없어요)';

  @override
  String get modeNameExists => '이미 있거나 사용할 수 없는 이름이에요.';

  @override
  String get modeNewTitle => '새 모드';

  @override
  String get modeEditTitle => '모드 수정';

  @override
  String get modeName => '모드 이름';

  @override
  String get modeCategoriesLabel => '카테고리별 동작';

  @override
  String get modeCategoriesHint =>
      '켜기: 이 모드에서 켜요 · 그대로: 건드리지 않아요 · 끄기: 꺼요. 어떤 카테고리에도 속하지 않은 서비스는 꺼요.';

  @override
  String get wantOn => '켜기';

  @override
  String get wantKeep => '그대로';

  @override
  String get wantOff => '끄기';

  @override
  String get modeRevertField => '자동 복귀';

  @override
  String get modeRevertOff => '복귀 안 함';

  @override
  String modeRevertAfter(int n) {
    return '$n분 후 기본 모드로';
  }

  @override
  String get modeRevertHint =>
      '이 모드로 바꾼 뒤 정한 시간이 지나면 기본 모드로 돌아가요. 1분 전에 알려 주고 연장할 수 있어요.';

  @override
  String modeSummaryOn(String list) {
    return '켜기: $list';
  }

  @override
  String get modeSummaryNoneOn => '켜는 것 없음';

  @override
  String modeSummaryKeep(String list) {
    return '그대로: $list';
  }

  @override
  String logModePlan(String name, int start, int stop) {
    return '\'$name\' 모드로 전환: 켜기 $start개, 끄기 $stop개';
  }

  @override
  String logModeAlready(String name) {
    return '이미 \'$name\' 모드예요.';
  }

  @override
  String logModeDone(String name) {
    return '\'$name\' 모드 전환 완료 (모든 서비스 상태 확인됨)';
  }

  @override
  String logModePartial(String name, int ok, int total) {
    return '\'$name\' 모드 전환이 완전하지 않아요: $ok/$total. 모드 버튼을 다시 누르면 남은 서비스만 다시 시도해요.';
  }

  @override
  String logModeRevert(String name) {
    return '자동 복귀: \'$name\' 모드로 돌아갑니다';
  }

  @override
  String logModeStartup(String name) {
    return '앱 시작: 기본 모드 \'$name\'를 적용합니다';
  }

  @override
  String revertWarnTitle(String to) {
    return '곧 \'$to\' 모드로 돌아가요';
  }

  @override
  String revertWarnBody(String from, int minutes, String to) {
    return '\'$from\' 모드로 바꾼 지 $minutes분이 지났어요. 1분 뒤 \'$to\' 모드로 자동으로 돌아가요.';
  }

  @override
  String revertExtend(int n) {
    return '$n분 연장';
  }

  @override
  String get revertNow => '지금 돌아가기';

  @override
  String get modeDefaultBanking => '뱅킹';

  @override
  String get modeDefaultDev => '개발';

  @override
  String planTitle(String name) {
    return '\'$name\' 모드로 전환';
  }

  @override
  String get planIntro => '실행하면 아래처럼 바뀌어요. 확인 후 실행하세요.';

  @override
  String planStopHeader(int n) {
    return '끌 서비스 $n개';
  }

  @override
  String planStartHeader(int n) {
    return '켤 서비스 $n개';
  }

  @override
  String planUnchanged(int n) {
    return '이미 맞는 서비스 $n개는 그대로 둬요.';
  }

  @override
  String get planRun => '실행';

  @override
  String get planEnableNote => '시작 유형이 \'사용 안 함\'이라 \'수동\'으로 바꾼 뒤 시작해요';

  @override
  String get planAutoNote => '시작 유형이 \'자동\'이라 PC를 다시 켜면 또 시작돼요';

  @override
  String logModeCancelled(String name) {
    return '\'$name\' 모드 전환을 취소했어요.';
  }

  @override
  String get catalogTooltip => '보안 서비스 카탈로그';

  @override
  String catalogTooltipCount(int n) {
    return '보안 서비스 카탈로그 · 새 제안 $n개';
  }

  @override
  String get catalogTitle => '보안 서비스 카탈로그';

  @override
  String catalogInfo(int version, String updated) {
    return '카탈로그 v$version · $updated';
  }

  @override
  String get catalogSourceBundled => '앱에 들어 있는 기본 카탈로그';

  @override
  String get catalogSourceCache => '받아 둔 카탈로그 (서명 확인됨)';

  @override
  String get catalogSourceRemote => '방금 받은 카탈로그 (서명 확인됨)';

  @override
  String catalogChecked(String when) {
    return '마지막 확인: $when';
  }

  @override
  String get catalogNeverChecked => '아직 확인하지 않았어요';

  @override
  String get catalogCheckNow => '지금 확인';

  @override
  String get catalogChecking => '확인하는 중…';

  @override
  String get catalogRemoteOff =>
      '원격 갱신이 꺼져 있어요 (서명 공개키가 설정되지 않았어요). 앱에 들어 있는 기본 카탈로그만 써요.';

  @override
  String get catalogResultUpdated => '새 카탈로그를 받았어요.';

  @override
  String get catalogResultUpToDate => '이미 최신이에요.';

  @override
  String catalogResultRejected(String reason) {
    return '받은 카탈로그를 쓰지 않았어요: $reason';
  }

  @override
  String catalogResultFailed(String reason) {
    return '카탈로그를 받지 못했어요: $reason';
  }

  @override
  String get catalogErrNetwork => '네트워크 오류';

  @override
  String get catalogErrSignature => '서명이 맞지 않아요';

  @override
  String get catalogErrFormat => '형식이 맞지 않아요';

  @override
  String get catalogErrRollback => '더 낮은 버전이라 쓰지 않았어요';

  @override
  String get catalogScanning => '이 PC의 서비스를 확인하는 중…';

  @override
  String catalogFindsHeader(int n) {
    return '이 PC에서 발견했지만 목록에 없는 서비스 $n개';
  }

  @override
  String catalogRenamesHeader(int n) {
    return '이름이 바뀐 것 같은 항목 $n개';
  }

  @override
  String get catalogNothing => '새로 발견한 서비스도, 이름이 바뀐 항목도 없어요.';

  @override
  String catalogAddSelected(int n) {
    return '선택한 $n개 추가';
  }

  @override
  String get catalogRenameApply => '이름 바꾸기';

  @override
  String catalogRenameLine(String from, String to) {
    return '$from → $to';
  }

  @override
  String catalogRenameNote(String product) {
    return '카탈로그가 \'$product\'의 이름으로 알고 있는 서비스예요';
  }

  @override
  String get catalogDriverTag => '드라이버 연동';

  @override
  String catalogAdded(int n) {
    return '서비스 $n개를 목록에 추가했어요.';
  }

  @override
  String catalogNewCategoriesNote(String list) {
    return '새 카테고리($list)는 아직 어떤 모드에도 \'켜기\'로 지정되지 않았어요. 정하기 전에는 모든 모드에서 꺼져요. 모드 관리에서 정하세요.';
  }

  @override
  String get catalogReport => '목록에 없는 서비스 신고…';

  @override
  String get catalogSuggestionNote => '카탈로그는 제안만 해요. 서비스를 자동으로 켜거나 끄지 않아요.';

  @override
  String get reportTitle => '서비스 신고';

  @override
  String get reportHint =>
      '카탈로그에 없는 서비스를 골라 주세요. 아래 내용만 GitHub 이슈 초안에 담기고, 제출은 직접 해요.';

  @override
  String get reportSearch => '서비스 검색';

  @override
  String get reportWillSend => '이슈 초안에 담기는 내용 (경로는 담지 않아요):';

  @override
  String get reportOpen => 'GitHub에서 열기';

  @override
  String get reportBack => '다른 서비스 고르기';

  @override
  String get reportOpenFailed => '브라우저를 열지 못했어요.';

  @override
  String get reportChecking => '서명자를 확인하는 중…';

  @override
  String get helpCatalogTitle => '보안 서비스 카탈로그';

  @override
  String get helpCatalogBody =>
      '보안 서비스는 제품마다, 버전마다 이름이 달라서 고정된 목록은 금방 어긋나요. 그래서 \'어떤 제품이 어떤 이름·실행 파일로 설치되는지\'를 적은 카탈로그를 두고 정기적으로(24시간마다) 받아 와요.\n• 지구본 아이콘(보안 서비스 카탈로그)을 누르면 이 PC에서 발견했지만 목록에 없는 서비스와, 이름이 바뀐 것 같은 항목을 보여 줘요. 새 제안이 있으면 아이콘에 숫자가 붙어요.\n• 카탈로그는 제안만 해요. 서비스를 자동으로 켜거나 끄지 않고, 목록에 넣을지는 직접 골라요. 새로 만들어진 카테고리는 어떤 모드에도 \'켜기\'로 지정돼 있지 않아서, 모드 관리에서 정하기 전에는 모든 모드에서 꺼져요.\n• 받은 카탈로그는 서명을 확인해요. 서명이 맞지 않거나 이전 버전이면 쓰지 않고, 앱에 들어 있는 기본 카탈로그로 동작해요.\n• 카탈로그에 없는 서비스는 \'신고\'로 알릴 수 있어요. 서비스 이름·표시 이름·실행 파일 이름·서명자만 담긴 GitHub 이슈 초안이 열리고, 내용을 확인한 뒤 직접 제출해요 (경로는 담지 않아요).\n• 새로 설치된 서비스도 알아채요. 서비스를 읽을 때마다(앱을 켤 때, 30분마다) 지난번에 본 목록과 견주고, 카탈로그에 없어도 이름·경로·서명자가 보안 프로그램처럼 보이면 후보로 알려요. 아이콘 배지와 트레이 툴팁에 개수가 나와요. 처음 실행 때는 지금 있는 서비스를 기준으로 삼고 알리지 않아요.\n• 후보를 목록에 넣을 때는 카테고리와 켤 모드를 함께 정해요. 모드에서 켜지 않으면 그 서비스는 모든 모드에서 꺼져요. 후보가 아니라고 판단하면 \'무시\'해서 다시 보지 않을 수 있어요.\n• 처음 설치하면 이 PC에서 찾은 보안 서비스를 한 화면에 보여 줘요. 카탈로그가 아는 서비스는 미리 체크돼 있고, 보안 프로그램으로 보이는 후보는 체크하지 않은 채 이유와 함께 나와요. 확인하고 [추가하고 시작]을 누르면 목록과 카테고리, 뱅킹 모드가 만들어져요. [나중에]를 누르면 지구본 아이콘에서 같은 일을 할 수 있어요.\n• 후보와 발견한 서비스 옆의 돋보기 단추를 누르면 브라우저에서 그 서비스를 검색해요. 이 서비스가 무엇인지 보고 판단하는 데 쓰세요. 검색어는 서비스 이름과 실행 파일 이름뿐이고 경로는 보내지 않아요. Windows는 기본 검색엔진을 앱에 알려 주지 않아서, 카탈로그 창 아래에서 검색 엔진(Google, Naver, Bing, DuckDuckGo)을 고를 수 있어요.';

  @override
  String catalogKeyInfo(String fp) {
    return '서명 확인용 공개키: $fp…';
  }

  @override
  String catalogErrSignatureDetail(int bytes, String sig, String fp) {
    return '서명이 맞지 않아요 (받은 카탈로그 $bytes바이트, 서명 $sig…, 공개키 $fp…)';
  }

  @override
  String suspectsHeader(int n) {
    return '보안 프로그램으로 보이는 서비스 $n개 (카탈로그에 없어요)';
  }

  @override
  String get suspectsHint => '이름·경로·서명자로 짐작한 후보예요. 틀릴 수 있으니 이유를 보고 골라 주세요.';

  @override
  String suspectReasonName(String v) {
    return '이름에 \'$v\'';
  }

  @override
  String suspectReasonDisplay(String v) {
    return '표시 이름에 \'$v\'';
  }

  @override
  String suspectReasonPath(String v) {
    return '실행 경로에 \'$v\'';
  }

  @override
  String suspectReasonSigner(String v) {
    return '서명자에 \'$v\'';
  }

  @override
  String suspectAdd(int n) {
    return '선택한 $n개 추가…';
  }

  @override
  String suspectIgnore(int n) {
    return '선택한 $n개 무시';
  }

  @override
  String suspectUnignore(int n) {
    return '무시한 서비스 $n개 다시 보기';
  }

  @override
  String suspectAddTitle(int n) {
    return '서비스 $n개를 목록에 추가';
  }

  @override
  String get suspectCategory => '카테고리';

  @override
  String get suspectNewCategory => '새 카테고리 이름';

  @override
  String get suspectCategoryDefault => '새 보안 서비스';

  @override
  String get suspectModesTitle => '어느 모드에서 켤까요?';

  @override
  String suspectModeItem(String name) {
    return '\'$name\' 모드에서 켜기';
  }

  @override
  String get suspectModesNote =>
      '체크하지 않은 모드에서는 이 서비스가 꺼져요. 뱅킹처럼 보안 서비스가 필요한 모드는 체크하세요. 나중에 모드 관리에서 바꿀 수 있어요.';

  @override
  String suspectNoMode(String category) {
    return '\'$category\' 카테고리는 어느 모드에서도 켜지 않도록 추가했어요. 모든 모드에서 꺼져요. 필요하면 모드 관리에서 바꾸세요.';
  }

  @override
  String trayAlerts(int n) {
    return '새 보안 서비스 의심 $n개';
  }

  @override
  String get setupTitle => '처음 설정: 이 PC의 보안 서비스';

  @override
  String get setupIntro =>
      '이 PC에서 보안 프로그램으로 보이는 서비스를 찾았어요. 확인하고 시작하세요. 나중에 언제든 바꿀 수 있어요.';

  @override
  String get setupNothing =>
      '이 PC에서 보안 서비스를 찾지 못했어요. 은행 사이트에서 보안 프로그램이 새로 설치되면 알려 드릴게요.';

  @override
  String setupFoundHeader(int n) {
    return '카탈로그가 아는 서비스 $n개';
  }

  @override
  String setupCandidatesHeader(int n) {
    return '보안 프로그램으로 보이는 후보 $n개 (확인 필요)';
  }

  @override
  String get setupCandidatesHint =>
      '이름·경로·서명자로 짐작한 후보예요. 틀릴 수 있어서 체크하지 않았어요. 이유를 보고 골라 주세요.';

  @override
  String get setupModesTitle => '어느 모드에서 켤까요?';

  @override
  String get setupModesNote =>
      '체크하지 않은 모드에서는 고른 서비스가 꺼져요. 뱅킹처럼 보안 서비스가 필요한 모드는 체크하세요.';

  @override
  String get setupSkip => '나중에';

  @override
  String setupStart(int n) {
    return '추가하고 시작 ($n)';
  }

  @override
  String get emptyFind => '이 PC의 보안 서비스 찾기';

  @override
  String searchTooltip(String engine) {
    return '$engine에서 검색 (브라우저가 열려요)';
  }

  @override
  String searchEngineLabel(String engine) {
    return '검색 엔진: $engine';
  }

  @override
  String get searchEngineTooltip => '검색 엔진 바꾸기';

  @override
  String get searchNote =>
      '검색 단추는 서비스 이름·실행 파일 이름만 검색어로 써서 브라우저에서 열어요. 경로는 보내지 않아요.';
}
