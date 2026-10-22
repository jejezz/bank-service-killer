import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @aboutTooltip.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get aboutTooltip;

  /// No description provided for @aboutVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전 {version} (빌드 {build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutOpenSourceLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get aboutOpenSourceLicenses;

  /// No description provided for @aboutRepository.
  ///
  /// In ko, this message translates to:
  /// **'GitHub'**
  String get aboutRepository;

  /// No description provided for @commonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// No description provided for @aboutMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'{appName} 정보'**
  String aboutMenuItem(String appName);

  /// No description provided for @themeMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get themeMenuTooltip;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get themeDark;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get languageMenuTooltip;

  /// No description provided for @languageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기 / System'**
  String get languageSystem;

  /// No description provided for @languageSystemShort.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get languageSystemShort;

  /// No description provided for @aboutTagline.
  ///
  /// In ko, this message translates to:
  /// **'금융보안 서비스를 필요할 때만 켜고 끄는 도구'**
  String get aboutTagline;

  /// No description provided for @aboutDescription.
  ///
  /// In ko, this message translates to:
  /// **'금융보안·키보드보안 같은 상주 서비스를 뱅킹할 때만 켜고, 끝나면 끄고, 실제로 반영됐는지 확인해요.'**
  String get aboutDescription;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'감시할 서비스가 없어요'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyAction.
  ///
  /// In ko, this message translates to:
  /// **'서비스 추가'**
  String get homeEmptyAction;

  /// No description provided for @updateCheckMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 확인'**
  String get updateCheckMenuItem;

  /// No description provided for @updateChecking.
  ///
  /// In ko, this message translates to:
  /// **'업데이트를 확인하는 중…'**
  String get updateChecking;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 버전이 있습니다'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In ko, this message translates to:
  /// **'{appName} {latest} 버전이 나왔습니다. (현재 {current})'**
  String updateAvailableBody(String appName, String current, String latest);

  /// No description provided for @updateReleaseNotes.
  ///
  /// In ko, this message translates to:
  /// **'변경 내용'**
  String get updateReleaseNotes;

  /// No description provided for @updateNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 업데이트'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get updateLater;

  /// No description provided for @updateSkipVersion.
  ///
  /// In ko, this message translates to:
  /// **'이 버전 건너뛰기'**
  String get updateSkipVersion;

  /// No description provided for @updateDownloading.
  ///
  /// In ko, this message translates to:
  /// **'내려받는 중…'**
  String get updateDownloading;

  /// No description provided for @updateVerifying.
  ///
  /// In ko, this message translates to:
  /// **'파일을 확인하는 중…'**
  String get updateVerifying;

  /// No description provided for @updateDownloadProgress.
  ///
  /// In ko, this message translates to:
  /// **'{received} / {total}'**
  String updateDownloadProgress(String received, String total);

  /// No description provided for @updateCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get updateCancel;

  /// No description provided for @updateFailedTitle.
  ///
  /// In ko, this message translates to:
  /// **'업데이트하지 못했습니다'**
  String get updateFailedTitle;

  /// No description provided for @updateCheckFailedTitle.
  ///
  /// In ko, this message translates to:
  /// **'업데이트를 확인하지 못했습니다'**
  String get updateCheckFailedTitle;

  /// No description provided for @updateErrorNetwork.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 서버에 연결하지 못했습니다. 인터넷 연결을 확인한 뒤 다시 시도해 주세요.'**
  String get updateErrorNetwork;

  /// No description provided for @updateErrorChecksum.
  ///
  /// In ko, this message translates to:
  /// **'내려받은 파일이 올바르지 않아 설치하지 않았습니다. 잠시 뒤에 다시 시도해 주세요.'**
  String get updateErrorChecksum;

  /// No description provided for @updateErrorInstall.
  ///
  /// In ko, this message translates to:
  /// **'설치를 시작하지 못했습니다.'**
  String get updateErrorInstall;

  /// No description provided for @updateErrorGeneric.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 서버에서 예상하지 못한 응답을 받았습니다. 잠시 뒤에 다시 시도해 주세요.'**
  String get updateErrorGeneric;

  /// No description provided for @updateUpToDateTitle.
  ///
  /// In ko, this message translates to:
  /// **'최신 버전입니다'**
  String get updateUpToDateTitle;

  /// No description provided for @updateUpToDateBody.
  ///
  /// In ko, this message translates to:
  /// **'{version} 버전을 사용 중입니다.'**
  String updateUpToDateBody(String version);

  /// No description provided for @updateUnavailableTitle.
  ///
  /// In ko, this message translates to:
  /// **'직접 설치해 주세요'**
  String get updateUnavailableTitle;

  /// No description provided for @updateUnavailableBody.
  ///
  /// In ko, this message translates to:
  /// **'{latest} 버전이 있지만 앱에서 자동으로 설치할 수 없습니다. 릴리스 페이지에서 받아 주세요.'**
  String updateUnavailableBody(String latest);

  /// No description provided for @updateOpenReleasePage.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 페이지 열기'**
  String get updateOpenReleasePage;

  /// No description provided for @updateBrowserDownloadTitle.
  ///
  /// In ko, this message translates to:
  /// **'브라우저에서 내려받습니다'**
  String get updateBrowserDownloadTitle;

  /// No description provided for @updateBrowserDownloadBody.
  ///
  /// In ko, this message translates to:
  /// **'브라우저가 새 버전 내려받기를 시작합니다. 받은 DMG를 열어 {appName} 을(를) Applications 폴더로 끌어다 놓아 주세요. 실행 중이면 종료한 뒤 덮어쓰세요.'**
  String updateBrowserDownloadBody(String appName);

  /// No description provided for @updateMacosOpenedTitle.
  ///
  /// In ko, this message translates to:
  /// **'설치 창이 열렸습니다'**
  String get updateMacosOpenedTitle;

  /// No description provided for @updateMacosOpenedBody.
  ///
  /// In ko, this message translates to:
  /// **'열린 창에서 {appName} 을(를) Applications 폴더로 끌어다 놓아 주세요. 실행 중이면 종료한 뒤 덮어쓰세요.'**
  String updateMacosOpenedBody(String appName);

  /// No description provided for @updateWindowsInstallTitle.
  ///
  /// In ko, this message translates to:
  /// **'설치 프로그램을 열었습니다'**
  String get updateWindowsInstallTitle;

  /// No description provided for @updateWindowsInstallBody.
  ///
  /// In ko, this message translates to:
  /// **'설치하려면 {appName} 을(를) 종료해야 합니다. 설치 프로그램의 안내를 따라 주세요.'**
  String updateWindowsInstallBody(String appName);

  /// No description provided for @updateQuitApp.
  ///
  /// In ko, this message translates to:
  /// **'{appName} 종료'**
  String updateQuitApp(String appName);

  /// No description provided for @updateLinuxInstallTitle.
  ///
  /// In ko, this message translates to:
  /// **'설치를 준비했습니다'**
  String get updateLinuxInstallTitle;

  /// No description provided for @updateLinuxInstallBody.
  ///
  /// In ko, this message translates to:
  /// **'{appName} 을(를) 종료하고 설치합니다. 설치가 끝나면 자동으로 다시 시작됩니다.'**
  String updateLinuxInstallBody(String appName);

  /// No description provided for @updateQuitAndInstall.
  ///
  /// In ko, this message translates to:
  /// **'종료하고 설치'**
  String get updateQuitAndInstall;

  /// No description provided for @updateBusyTitle.
  ///
  /// In ko, this message translates to:
  /// **'지금은 업데이트할 수 없습니다'**
  String get updateBusyTitle;

  /// No description provided for @updateBusyBody.
  ///
  /// In ko, this message translates to:
  /// **'작업이 진행 중입니다. 끝난 뒤에 다시 시도해 주세요.'**
  String get updateBusyBody;

  /// No description provided for @commonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// No description provided for @commonAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get commonAdd;

  /// No description provided for @refreshTooltip.
  ///
  /// In ko, this message translates to:
  /// **'새로 고침 (F5)'**
  String get refreshTooltip;

  /// No description provided for @addServiceTooltip.
  ///
  /// In ko, this message translates to:
  /// **'서비스 추가 (Ctrl+N)'**
  String get addServiceTooltip;

  /// No description provided for @adminWarning.
  ///
  /// In ko, this message translates to:
  /// **'관리자 권한이 아니에요. 서비스 시작·중지·설정 변경은 관리자 권한으로 실행해야 동작해요.'**
  String get adminWarning;

  /// No description provided for @trayShow.
  ///
  /// In ko, this message translates to:
  /// **'창 열기'**
  String get trayShow;

  /// No description provided for @trayExit.
  ///
  /// In ko, this message translates to:
  /// **'종료'**
  String get trayExit;

  /// No description provided for @startupMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'시작프로그램'**
  String get startupMenuTooltip;

  /// No description provided for @startupAutoRun.
  ///
  /// In ko, this message translates to:
  /// **'Windows 시작 시 자동 실행 (트레이 상주)'**
  String get startupAutoRun;

  /// No description provided for @startupChangeFailed.
  ///
  /// In ko, this message translates to:
  /// **'시작프로그램 설정을 바꾸지 못했어요: {detail}'**
  String startupChangeFailed(String detail);

  /// No description provided for @logTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그'**
  String get logTitle;

  /// No description provided for @logEmpty.
  ///
  /// In ko, this message translates to:
  /// **'작업 결과가 여기에 표시돼요.'**
  String get logEmpty;

  /// No description provided for @logResizeTooltip.
  ///
  /// In ko, this message translates to:
  /// **'드래그해서 로그 창 크기 조절'**
  String get logResizeTooltip;

  /// No description provided for @helpTooltip.
  ///
  /// In ko, this message translates to:
  /// **'사용 방법'**
  String get helpTooltip;

  /// No description provided for @helpTitle.
  ///
  /// In ko, this message translates to:
  /// **'사용 방법'**
  String get helpTitle;

  /// No description provided for @helpClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get helpClose;

  /// No description provided for @helpPurposeTitle.
  ///
  /// In ko, this message translates to:
  /// **'이 앱은 무엇인가요?'**
  String get helpPurposeTitle;

  /// No description provided for @helpPurposeBody.
  ///
  /// In ko, this message translates to:
  /// **'인터넷 뱅킹 때 필요한 보안 프로그램은 평소엔 PC를 느리게 하거나 충돌을 일으켜요. 이 앱은 그런 상주 서비스를 뱅킹할 때만 켜고, 끝나면 끄고, 실제로 켜졌는지·꺼졌는지 확인해 줘요. 서비스를 제어하려면 관리자 권한이 필요해서 실행할 때 권한 상승(UAC) 창이 떠요.'**
  String get helpPurposeBody;

  /// No description provided for @helpListTitle.
  ///
  /// In ko, this message translates to:
  /// **'서비스 목록은 어디서 오나요?'**
  String get helpListTitle;

  /// No description provided for @helpListBody.
  ///
  /// In ko, this message translates to:
  /// **'목록은 자동으로 만들어지지 않아요. 처음에는 흔한 금융·보안 서비스가 미리 들어 있고, 그 뒤로는 직접 관리해요.\n• 추가: 위쪽 + 단추(Ctrl+N)에서 서비스 이름이나 표시 이름을 입력하면 이 PC에 설치된 서비스 중 일치하는 것이 아래에 나타나요. 눌러서 고르면 돼요.\n• 새로 설치된 서비스는 자동으로 감지되지 않아요. 직접 추가해야 해요. 서비스 이름은 msconfig(서비스 탭)나 services.msc에서 볼 수 있어요.\n• 이름이 일부만 같아도 찾아 주고(부분 일치), \"설치되지 않음 / 이름 불일치\"로 나오면 이 PC에 없거나 이름이 달라요.\n• 목록은 %APPDATA%\\BankServiceKiller\\watchlist.json 에 저장돼요. 새로고침(F5)은 서비스의 현재 상태를 다시 읽어 와요.'**
  String get helpListBody;

  /// No description provided for @helpGroupTitle.
  ///
  /// In ko, this message translates to:
  /// **'카테고리와 모드'**
  String get helpGroupTitle;

  /// No description provided for @helpGroupBody.
  ///
  /// In ko, this message translates to:
  /// **'• 카테고리: 서비스를 묶는 이름표예요 (예: 키보드보안, 공인인증, 은행별). 한 서비스를 여러 카테고리에 넣어도 돼요. 위쪽 칩을 누르면 그 카테고리만 보이고, \'○○ 켜기 / 끄기\'가 그 카테고리에만 적용돼요.\n• 모드: \'켤 것 · 그대로 둘 것 · 끌 것\'을 정해 둔 목표 상태예요. 위쪽 [뱅킹 | 개발 …] 토글에서 고르면 그 상태가 되도록 서비스를 켜고 꺼요. 이미 맞는 서비스는 건드리지 않아요.\n• 모드를 누르면 먼저 \'끌 서비스 / 켤 서비스\' 미리보기 창이 떠요. 확인하고 [실행]을 누르면 그때 바뀌고, [취소]하면 아무것도 바뀌지 않아요. (앱 시작 시 기본 모드와 자동 복귀는 사람이 없어도 돌아야 해서 묻지 않고 실행해요.)\n• 현재 모드는 저장한 값이 아니라 서비스의 실제 상태로 판단해요. 어느 모드와도 맞지 않으면 \'혼합\'으로 보여 줘요. 혼합일 때 모드를 누르면 남은 서비스만 맞춰요.\n• 모드 관리(슬라이더 아이콘)에서 모드를 만들고 고칠 수 있어요. ★ 기본 모드는 앱을 시작할 때(Windows 로그온 포함)와 자동 복귀할 때 적용돼요.\n• 자동 복귀: 모드마다 시간을 정해 두면 그 뒤 기본 모드로 돌아가요. 1분 전에 알려 줘요.\n• 트레이 아이콘 우클릭 메뉴에서도 모드를 바꿀 수 있고, 현재 모드에 체크가 붙어요.'**
  String get helpGroupBody;

  /// No description provided for @helpOnOffTitle.
  ///
  /// In ko, this message translates to:
  /// **'켜기·끄기'**
  String get helpOnOffTitle;

  /// No description provided for @helpOnOffBody.
  ///
  /// In ko, this message translates to:
  /// **'• 모드 전환, \'○○ 켜기 / 끄기\', 그리고 항목 오른쪽의 재생·정지 단추는 서비스를 지금 바로 시작하거나 중지해요. 시작 유형이 \'사용 안 함\'이면 \'수동\'으로 바꾼 뒤 시작해요.\n• 시작·중지 후 실제 상태가 바뀌었는지 확인하고 결과를 아래 로그에 남겨요. 중지 후 3초 뒤 다시 살아났는지도 한 번 더 확인해요.\n• 끄기는 서비스를 멈출 뿐 시작 유형은 바꾸지 않아요. 시작 유형이 \'자동\'이면 PC를 다시 켤 때 서비스가 또 시작돼요.'**
  String get helpOnOffBody;

  /// No description provided for @helpModeTitle.
  ///
  /// In ko, this message translates to:
  /// **'시작 유형 (자동 / 수동 / 사용 안 함)'**
  String get helpModeTitle;

  /// No description provided for @helpModeBody.
  ///
  /// In ko, this message translates to:
  /// **'항목 오른쪽 드롭다운으로 고르면 바로 적용돼요. 다만 지금 실행 중인 서비스를 켜거나 끄지는 않고, 다음 부팅부터의 시작 방식에 영향을 줘요.\n• 자동: 부팅할 때 자동으로 시작돼요.\n• 수동: 부팅 때는 시작되지 않고, 필요할 때 켜기 단추로 시작해요. 뱅킹용 서비스에 권장해요.\n• 사용 안 함: 시작 자체가 막혀요. 이 앱의 켜기 단추는 \'수동\'으로 바꾼 뒤 시작해요.\n\'msconfig 비활성\'은 msconfig에서 해당 서비스를 꺼 둔 상태라는 표시예요.'**
  String get helpModeBody;

  /// No description provided for @helpResidentTitle.
  ///
  /// In ko, this message translates to:
  /// **'상주와 시작프로그램'**
  String get helpResidentTitle;

  /// No description provided for @helpResidentBody.
  ///
  /// In ko, this message translates to:
  /// **'창을 닫으면 종료되지 않고 작업 표시줄 오른쪽 트레이에 남아요. 트레이 아이콘을 누르면 창이 열리고, 우클릭 메뉴의 \'종료\'로 완전히 끝내요. 첫 실행 때 Windows 로그온 시 자동으로 시작(창 없이 트레이에만)되도록 등록되며, 위쪽 전원 아이콘 메뉴에서 켜고 끌 수 있어요.'**
  String get helpResidentBody;

  /// No description provided for @commonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// No description provided for @editTooltip.
  ///
  /// In ko, this message translates to:
  /// **'이름·분류 수정'**
  String get editTooltip;

  /// No description provided for @editDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'감시 서비스 수정'**
  String get editDialogTitle;

  /// No description provided for @systemToolsTooltip.
  ///
  /// In ko, this message translates to:
  /// **'Windows 서비스 도구 열기'**
  String get systemToolsTooltip;

  /// No description provided for @openMsconfig.
  ///
  /// In ko, this message translates to:
  /// **'msconfig (서비스 탭)'**
  String get openMsconfig;

  /// No description provided for @openServicesMsc.
  ///
  /// In ko, this message translates to:
  /// **'서비스 관리 (services.msc)'**
  String get openServicesMsc;

  /// No description provided for @notInstalled.
  ///
  /// In ko, this message translates to:
  /// **'설치되지 않음 / 이름 불일치'**
  String get notInstalled;

  /// No description provided for @serviceSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'{displayName} · {state} · 시작 유형 {startMode}'**
  String serviceSubtitle(String displayName, String state, String startMode);

  /// No description provided for @msconfigDisabledNote.
  ///
  /// In ko, this message translates to:
  /// **' · msconfig 비활성'**
  String get msconfigDisabledNote;

  /// No description provided for @startModeAuto.
  ///
  /// In ko, this message translates to:
  /// **'자동'**
  String get startModeAuto;

  /// No description provided for @startModeManual.
  ///
  /// In ko, this message translates to:
  /// **'수동'**
  String get startModeManual;

  /// No description provided for @startModeDisabled.
  ///
  /// In ko, this message translates to:
  /// **'사용 안 함'**
  String get startModeDisabled;

  /// No description provided for @stopVerifyTooltip.
  ///
  /// In ko, this message translates to:
  /// **'중지 후 검증'**
  String get stopVerifyTooltip;

  /// No description provided for @startVerifyTooltip.
  ///
  /// In ko, this message translates to:
  /// **'시작 후 검증'**
  String get startVerifyTooltip;

  /// No description provided for @removeTooltip.
  ///
  /// In ko, this message translates to:
  /// **'목록에서 제거'**
  String get removeTooltip;

  /// No description provided for @addDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'감시 서비스 추가'**
  String get addDialogTitle;

  /// No description provided for @addDialogField.
  ///
  /// In ko, this message translates to:
  /// **'서비스 이름 또는 표시 이름'**
  String get addDialogField;

  /// No description provided for @logQueryError.
  ///
  /// In ko, this message translates to:
  /// **'조회 오류: {error}'**
  String logQueryError(String error);

  /// No description provided for @logAlreadyInList.
  ///
  /// In ko, this message translates to:
  /// **'이미 목록에 있음: {name}'**
  String logAlreadyInList(String name);

  /// No description provided for @logLine.
  ///
  /// In ko, this message translates to:
  /// **'{name}: {message}'**
  String logLine(String name, String message);

  /// No description provided for @logOk.
  ///
  /// In ko, this message translates to:
  /// **'OK'**
  String get logOk;

  /// No description provided for @logFail.
  ///
  /// In ko, this message translates to:
  /// **'실패'**
  String get logFail;

  /// No description provided for @logEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'작업 기록'**
  String get logEmptyTitle;

  /// No description provided for @svcModeChanged.
  ///
  /// In ko, this message translates to:
  /// **'시작 유형을 {mode} (으)로 변경'**
  String svcModeChanged(String mode);

  /// No description provided for @svcStartCmdFailed.
  ///
  /// In ko, this message translates to:
  /// **'시작 명령 실패({code}): {detail}'**
  String svcStartCmdFailed(int code, String detail);

  /// No description provided for @svcStopCmdFailed.
  ///
  /// In ko, this message translates to:
  /// **'중지 명령 실패({code}): {detail}'**
  String svcStopCmdFailed(int code, String detail);

  /// No description provided for @svcRestarted.
  ///
  /// In ko, this message translates to:
  /// **'중지 후 서비스가 다시 시작됨 (감시/복구 동작 의심)'**
  String get svcRestarted;

  /// No description provided for @svcStopVerified.
  ///
  /// In ko, this message translates to:
  /// **'중지 확인 (3초 후 재확인도 Stopped)'**
  String get svcStopVerified;

  /// No description provided for @svcNotFound.
  ///
  /// In ko, this message translates to:
  /// **'서비스를 찾을 수 없음'**
  String get svcNotFound;

  /// No description provided for @svcStateVerified.
  ///
  /// In ko, this message translates to:
  /// **'{label} 확인 ({target})'**
  String svcStateVerified(String label, String target);

  /// No description provided for @svcStateFailed.
  ///
  /// In ko, this message translates to:
  /// **'{label} 확인 실패: 현재 상태 {state}'**
  String svcStateFailed(String label, String state);

  /// No description provided for @svcLabelStart.
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get svcLabelStart;

  /// No description provided for @svcLabelStop.
  ///
  /// In ko, this message translates to:
  /// **'중지'**
  String get svcLabelStop;

  /// No description provided for @svcStateUnknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없음'**
  String get svcStateUnknown;

  /// No description provided for @svcListFailed.
  ///
  /// In ko, this message translates to:
  /// **'서비스 목록 조회 실패: {error}'**
  String svcListFailed(String error);

  /// No description provided for @catAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get catAll;

  /// No description provided for @catUncategorized.
  ///
  /// In ko, this message translates to:
  /// **'미분류'**
  String get catUncategorized;

  /// No description provided for @catEmptyFilter.
  ///
  /// In ko, this message translates to:
  /// **'이 카테고리에는 서비스가 없어요.'**
  String get catEmptyFilter;

  /// No description provided for @catManageTooltip.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 관리'**
  String get catManageTooltip;

  /// No description provided for @catManageTitle.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 관리'**
  String get catManageTitle;

  /// No description provided for @catManageHint.
  ///
  /// In ko, this message translates to:
  /// **'카테고리로 서비스를 묶어 두면 그 묶음만 켜고 끌 수 있고, 모드를 만들 때 재료로 써요. 카테고리를 지워도 서비스는 남아요.'**
  String get catManageHint;

  /// No description provided for @catAddField.
  ///
  /// In ko, this message translates to:
  /// **'새 카테고리 이름'**
  String get catAddField;

  /// No description provided for @catRename.
  ///
  /// In ko, this message translates to:
  /// **'이름 바꾸기'**
  String get catRename;

  /// No description provided for @catDelete.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 삭제'**
  String get catDelete;

  /// No description provided for @catExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 있거나 사용할 수 없는 이름이에요.'**
  String get catExists;

  /// No description provided for @catItemCount.
  ///
  /// In ko, this message translates to:
  /// **'서비스 {n}개'**
  String catItemCount(int n);

  /// No description provided for @catDefaultA.
  ///
  /// In ko, this message translates to:
  /// **'보안 무관'**
  String get catDefaultA;

  /// No description provided for @catDefaultB.
  ///
  /// In ko, this message translates to:
  /// **'웹 플러그인'**
  String get catDefaultB;

  /// No description provided for @catDefaultC.
  ///
  /// In ko, this message translates to:
  /// **'드라이버 연동'**
  String get catDefaultC;

  /// No description provided for @addDialogCategories.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 (여러 개 선택 가능)'**
  String get addDialogCategories;

  /// No description provided for @addDialogNewCategory.
  ///
  /// In ko, this message translates to:
  /// **'새 카테고리 만들기'**
  String get addDialogNewCategory;

  /// No description provided for @scopeTurnOn.
  ///
  /// In ko, this message translates to:
  /// **'{scope} 켜기'**
  String scopeTurnOn(String scope);

  /// No description provided for @scopeTurnOff.
  ///
  /// In ko, this message translates to:
  /// **'{scope} 끄기'**
  String scopeTurnOff(String scope);

  /// No description provided for @modeCurrent.
  ///
  /// In ko, this message translates to:
  /// **'현재 모드: {name}'**
  String modeCurrent(String name);

  /// No description provided for @modeMixed.
  ///
  /// In ko, this message translates to:
  /// **'혼합 상태 · {name} {ok}/{total}'**
  String modeMixed(String name, int ok, int total);

  /// No description provided for @modeUnknown.
  ///
  /// In ko, this message translates to:
  /// **'서비스 상태를 확인하는 중…'**
  String get modeUnknown;

  /// No description provided for @modeRevertIn.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 뒤 \'{name}\' 모드로 돌아가요'**
  String modeRevertIn(int minutes, String name);

  /// No description provided for @modeToggleTooltip.
  ///
  /// In ko, this message translates to:
  /// **'눌러서 \'{name}\' 모드로 바꿔요'**
  String modeToggleTooltip(String name);

  /// No description provided for @modeManageTooltip.
  ///
  /// In ko, this message translates to:
  /// **'모드 관리'**
  String get modeManageTooltip;

  /// No description provided for @modeManageTitle.
  ///
  /// In ko, this message translates to:
  /// **'모드 관리'**
  String get modeManageTitle;

  /// No description provided for @modeManageHint.
  ///
  /// In ko, this message translates to:
  /// **'모드는 \'켤 것 · 그대로 둘 것 · 끌 것\'을 정해 둔 목표 상태예요. 모드로 바꾸면 켤 카테고리는 켜고, 그대로 둘 카테고리는 건드리지 않고, 나머지 감시 서비스는 모두 꺼요. ★ 표시한 기본 모드는 앱이 시작될 때와 자동 복귀할 때 적용돼요.'**
  String get modeManageHint;

  /// No description provided for @modeDefaultHint.
  ///
  /// In ko, this message translates to:
  /// **'기본 모드로 지정 (앱 시작·자동 복귀 때 적용)'**
  String get modeDefaultHint;

  /// No description provided for @modeDefaultTag.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get modeDefaultTag;

  /// No description provided for @modeAdd.
  ///
  /// In ko, this message translates to:
  /// **'모드 추가'**
  String get modeAdd;

  /// No description provided for @modeDelete.
  ///
  /// In ko, this message translates to:
  /// **'모드 삭제 (마지막 하나는 지울 수 없어요)'**
  String get modeDelete;

  /// No description provided for @modeNameExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 있거나 사용할 수 없는 이름이에요.'**
  String get modeNameExists;

  /// No description provided for @modeNewTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 모드'**
  String get modeNewTitle;

  /// No description provided for @modeEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'모드 수정'**
  String get modeEditTitle;

  /// No description provided for @modeName.
  ///
  /// In ko, this message translates to:
  /// **'모드 이름'**
  String get modeName;

  /// No description provided for @modeCategoriesLabel.
  ///
  /// In ko, this message translates to:
  /// **'카테고리별 동작'**
  String get modeCategoriesLabel;

  /// No description provided for @modeCategoriesHint.
  ///
  /// In ko, this message translates to:
  /// **'켜기: 이 모드에서 켜요 · 그대로: 건드리지 않아요 · 끄기: 꺼요. 어떤 카테고리에도 속하지 않은 서비스는 꺼요.'**
  String get modeCategoriesHint;

  /// No description provided for @wantOn.
  ///
  /// In ko, this message translates to:
  /// **'켜기'**
  String get wantOn;

  /// No description provided for @wantKeep.
  ///
  /// In ko, this message translates to:
  /// **'그대로'**
  String get wantKeep;

  /// No description provided for @wantOff.
  ///
  /// In ko, this message translates to:
  /// **'끄기'**
  String get wantOff;

  /// No description provided for @modeRevertField.
  ///
  /// In ko, this message translates to:
  /// **'자동 복귀'**
  String get modeRevertField;

  /// No description provided for @modeRevertOff.
  ///
  /// In ko, this message translates to:
  /// **'복귀 안 함'**
  String get modeRevertOff;

  /// No description provided for @modeRevertAfter.
  ///
  /// In ko, this message translates to:
  /// **'{n}분 후 기본 모드로'**
  String modeRevertAfter(int n);

  /// No description provided for @modeRevertHint.
  ///
  /// In ko, this message translates to:
  /// **'이 모드로 바꾼 뒤 정한 시간이 지나면 기본 모드로 돌아가요. 1분 전에 알려 주고 연장할 수 있어요.'**
  String get modeRevertHint;

  /// No description provided for @modeSummaryOn.
  ///
  /// In ko, this message translates to:
  /// **'켜기: {list}'**
  String modeSummaryOn(String list);

  /// No description provided for @modeSummaryNoneOn.
  ///
  /// In ko, this message translates to:
  /// **'켜는 것 없음'**
  String get modeSummaryNoneOn;

  /// No description provided for @modeSummaryKeep.
  ///
  /// In ko, this message translates to:
  /// **'그대로: {list}'**
  String modeSummaryKeep(String list);

  /// No description provided for @logModePlan.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 모드로 전환: 켜기 {start}개, 끄기 {stop}개'**
  String logModePlan(String name, int start, int stop);

  /// No description provided for @logModeAlready.
  ///
  /// In ko, this message translates to:
  /// **'이미 \'{name}\' 모드예요.'**
  String logModeAlready(String name);

  /// No description provided for @logModeDone.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 모드 전환 완료 (모든 서비스 상태 확인됨)'**
  String logModeDone(String name);

  /// No description provided for @logModePartial.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 모드 전환이 완전하지 않아요: {ok}/{total}. 모드 버튼을 다시 누르면 남은 서비스만 다시 시도해요.'**
  String logModePartial(String name, int ok, int total);

  /// No description provided for @logModeRevert.
  ///
  /// In ko, this message translates to:
  /// **'자동 복귀: \'{name}\' 모드로 돌아갑니다'**
  String logModeRevert(String name);

  /// No description provided for @logModeStartup.
  ///
  /// In ko, this message translates to:
  /// **'앱 시작: 기본 모드 \'{name}\'를 적용합니다'**
  String logModeStartup(String name);

  /// No description provided for @revertWarnTitle.
  ///
  /// In ko, this message translates to:
  /// **'곧 \'{to}\' 모드로 돌아가요'**
  String revertWarnTitle(String to);

  /// No description provided for @revertWarnBody.
  ///
  /// In ko, this message translates to:
  /// **'\'{from}\' 모드로 바꾼 지 {minutes}분이 지났어요. 1분 뒤 \'{to}\' 모드로 자동으로 돌아가요.'**
  String revertWarnBody(String from, int minutes, String to);

  /// No description provided for @revertExtend.
  ///
  /// In ko, this message translates to:
  /// **'{n}분 연장'**
  String revertExtend(int n);

  /// No description provided for @revertNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 돌아가기'**
  String get revertNow;

  /// No description provided for @modeDefaultBanking.
  ///
  /// In ko, this message translates to:
  /// **'뱅킹'**
  String get modeDefaultBanking;

  /// No description provided for @modeDefaultDev.
  ///
  /// In ko, this message translates to:
  /// **'개발'**
  String get modeDefaultDev;

  /// No description provided for @planTitle.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 모드로 전환'**
  String planTitle(String name);

  /// No description provided for @planIntro.
  ///
  /// In ko, this message translates to:
  /// **'실행하면 아래처럼 바뀌어요. 확인 후 실행하세요.'**
  String get planIntro;

  /// No description provided for @planStopHeader.
  ///
  /// In ko, this message translates to:
  /// **'끌 서비스 {n}개'**
  String planStopHeader(int n);

  /// No description provided for @planStartHeader.
  ///
  /// In ko, this message translates to:
  /// **'켤 서비스 {n}개'**
  String planStartHeader(int n);

  /// No description provided for @planUnchanged.
  ///
  /// In ko, this message translates to:
  /// **'이미 맞는 서비스 {n}개는 그대로 둬요.'**
  String planUnchanged(int n);

  /// No description provided for @planRun.
  ///
  /// In ko, this message translates to:
  /// **'실행'**
  String get planRun;

  /// No description provided for @planEnableNote.
  ///
  /// In ko, this message translates to:
  /// **'시작 유형이 \'사용 안 함\'이라 \'수동\'으로 바꾼 뒤 시작해요'**
  String get planEnableNote;

  /// No description provided for @planAutoNote.
  ///
  /// In ko, this message translates to:
  /// **'시작 유형이 \'자동\'이라 PC를 다시 켜면 또 시작돼요'**
  String get planAutoNote;

  /// No description provided for @logModeCancelled.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 모드 전환을 취소했어요.'**
  String logModeCancelled(String name);

  /// No description provided for @catalogTooltip.
  ///
  /// In ko, this message translates to:
  /// **'보안 서비스 카탈로그'**
  String get catalogTooltip;

  /// No description provided for @catalogTooltipCount.
  ///
  /// In ko, this message translates to:
  /// **'보안 서비스 카탈로그 · 새 제안 {n}개'**
  String catalogTooltipCount(int n);

  /// No description provided for @catalogTitle.
  ///
  /// In ko, this message translates to:
  /// **'보안 서비스 카탈로그'**
  String get catalogTitle;

  /// No description provided for @catalogInfo.
  ///
  /// In ko, this message translates to:
  /// **'카탈로그 v{version} · {updated}'**
  String catalogInfo(int version, String updated);

  /// No description provided for @catalogSourceBundled.
  ///
  /// In ko, this message translates to:
  /// **'앱에 들어 있는 기본 카탈로그'**
  String get catalogSourceBundled;

  /// No description provided for @catalogSourceCache.
  ///
  /// In ko, this message translates to:
  /// **'받아 둔 카탈로그 (서명 확인됨)'**
  String get catalogSourceCache;

  /// No description provided for @catalogSourceRemote.
  ///
  /// In ko, this message translates to:
  /// **'방금 받은 카탈로그 (서명 확인됨)'**
  String get catalogSourceRemote;

  /// No description provided for @catalogChecked.
  ///
  /// In ko, this message translates to:
  /// **'마지막 확인: {when}'**
  String catalogChecked(String when);

  /// No description provided for @catalogNeverChecked.
  ///
  /// In ko, this message translates to:
  /// **'아직 확인하지 않았어요'**
  String get catalogNeverChecked;

  /// No description provided for @catalogCheckNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 확인'**
  String get catalogCheckNow;

  /// No description provided for @catalogChecking.
  ///
  /// In ko, this message translates to:
  /// **'확인하는 중…'**
  String get catalogChecking;

  /// No description provided for @catalogRemoteOff.
  ///
  /// In ko, this message translates to:
  /// **'원격 갱신이 꺼져 있어요 (서명 공개키가 설정되지 않았어요). 앱에 들어 있는 기본 카탈로그만 써요.'**
  String get catalogRemoteOff;

  /// No description provided for @catalogResultUpdated.
  ///
  /// In ko, this message translates to:
  /// **'새 카탈로그를 받았어요.'**
  String get catalogResultUpdated;

  /// No description provided for @catalogResultUpToDate.
  ///
  /// In ko, this message translates to:
  /// **'이미 최신이에요.'**
  String get catalogResultUpToDate;

  /// No description provided for @catalogResultRejected.
  ///
  /// In ko, this message translates to:
  /// **'받은 카탈로그를 쓰지 않았어요: {reason}'**
  String catalogResultRejected(String reason);

  /// No description provided for @catalogResultFailed.
  ///
  /// In ko, this message translates to:
  /// **'카탈로그를 받지 못했어요: {reason}'**
  String catalogResultFailed(String reason);

  /// No description provided for @catalogErrNetwork.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 오류'**
  String get catalogErrNetwork;

  /// No description provided for @catalogErrSignature.
  ///
  /// In ko, this message translates to:
  /// **'서명이 맞지 않아요'**
  String get catalogErrSignature;

  /// No description provided for @catalogErrFormat.
  ///
  /// In ko, this message translates to:
  /// **'형식이 맞지 않아요'**
  String get catalogErrFormat;

  /// No description provided for @catalogErrRollback.
  ///
  /// In ko, this message translates to:
  /// **'더 낮은 버전이라 쓰지 않았어요'**
  String get catalogErrRollback;

  /// No description provided for @catalogScanning.
  ///
  /// In ko, this message translates to:
  /// **'이 PC의 서비스를 확인하는 중…'**
  String get catalogScanning;

  /// No description provided for @catalogFindsHeader.
  ///
  /// In ko, this message translates to:
  /// **'이 PC에서 발견했지만 목록에 없는 서비스 {n}개'**
  String catalogFindsHeader(int n);

  /// No description provided for @catalogRenamesHeader.
  ///
  /// In ko, this message translates to:
  /// **'이름이 바뀐 것 같은 항목 {n}개'**
  String catalogRenamesHeader(int n);

  /// No description provided for @catalogNothing.
  ///
  /// In ko, this message translates to:
  /// **'새로 발견한 서비스도, 이름이 바뀐 항목도 없어요.'**
  String get catalogNothing;

  /// No description provided for @catalogAddSelected.
  ///
  /// In ko, this message translates to:
  /// **'선택한 {n}개 추가'**
  String catalogAddSelected(int n);

  /// No description provided for @catalogRenameApply.
  ///
  /// In ko, this message translates to:
  /// **'이름 바꾸기'**
  String get catalogRenameApply;

  /// No description provided for @catalogRenameLine.
  ///
  /// In ko, this message translates to:
  /// **'{from} → {to}'**
  String catalogRenameLine(String from, String to);

  /// No description provided for @catalogRenameNote.
  ///
  /// In ko, this message translates to:
  /// **'카탈로그가 \'{product}\'의 이름으로 알고 있는 서비스예요'**
  String catalogRenameNote(String product);

  /// No description provided for @catalogDriverTag.
  ///
  /// In ko, this message translates to:
  /// **'드라이버 연동'**
  String get catalogDriverTag;

  /// No description provided for @catalogAdded.
  ///
  /// In ko, this message translates to:
  /// **'서비스 {n}개를 목록에 추가했어요.'**
  String catalogAdded(int n);

  /// No description provided for @catalogNewCategoriesNote.
  ///
  /// In ko, this message translates to:
  /// **'새 카테고리({list})는 아직 어떤 모드에도 \'켜기\'로 지정되지 않았어요. 정하기 전에는 모든 모드에서 꺼져요. 모드 관리에서 정하세요.'**
  String catalogNewCategoriesNote(String list);

  /// No description provided for @catalogReport.
  ///
  /// In ko, this message translates to:
  /// **'목록에 없는 서비스 신고…'**
  String get catalogReport;

  /// No description provided for @catalogSuggestionNote.
  ///
  /// In ko, this message translates to:
  /// **'카탈로그는 제안만 해요. 서비스를 자동으로 켜거나 끄지 않아요.'**
  String get catalogSuggestionNote;

  /// No description provided for @reportTitle.
  ///
  /// In ko, this message translates to:
  /// **'서비스 신고'**
  String get reportTitle;

  /// No description provided for @reportHint.
  ///
  /// In ko, this message translates to:
  /// **'카탈로그에 없는 서비스를 골라 주세요. 아래 내용만 GitHub 이슈 초안에 담기고, 제출은 직접 해요.'**
  String get reportHint;

  /// No description provided for @reportSearch.
  ///
  /// In ko, this message translates to:
  /// **'서비스 검색'**
  String get reportSearch;

  /// No description provided for @reportWillSend.
  ///
  /// In ko, this message translates to:
  /// **'이슈 초안에 담기는 내용 (경로는 담지 않아요):'**
  String get reportWillSend;

  /// No description provided for @reportOpen.
  ///
  /// In ko, this message translates to:
  /// **'GitHub에서 열기'**
  String get reportOpen;

  /// No description provided for @reportBack.
  ///
  /// In ko, this message translates to:
  /// **'다른 서비스 고르기'**
  String get reportBack;

  /// No description provided for @reportOpenFailed.
  ///
  /// In ko, this message translates to:
  /// **'브라우저를 열지 못했어요.'**
  String get reportOpenFailed;

  /// No description provided for @reportChecking.
  ///
  /// In ko, this message translates to:
  /// **'서명자를 확인하는 중…'**
  String get reportChecking;

  /// No description provided for @helpCatalogTitle.
  ///
  /// In ko, this message translates to:
  /// **'보안 서비스 카탈로그'**
  String get helpCatalogTitle;

  /// No description provided for @helpCatalogBody.
  ///
  /// In ko, this message translates to:
  /// **'보안 서비스는 제품마다, 버전마다 이름이 달라서 고정된 목록은 금방 어긋나요. 그래서 \'어떤 제품이 어떤 이름·실행 파일로 설치되는지\'를 적은 카탈로그를 두고 정기적으로(24시간마다) 받아 와요.\n• 지구본 아이콘(보안 서비스 카탈로그)을 누르면 이 PC에서 발견했지만 목록에 없는 서비스와, 이름이 바뀐 것 같은 항목을 보여 줘요. 새 제안이 있으면 아이콘에 숫자가 붙어요.\n• 카탈로그는 제안만 해요. 서비스를 자동으로 켜거나 끄지 않고, 목록에 넣을지는 직접 골라요. 새로 만들어진 카테고리는 어떤 모드에도 \'켜기\'로 지정돼 있지 않아서, 모드 관리에서 정하기 전에는 모든 모드에서 꺼져요.\n• 받은 카탈로그는 서명을 확인해요. 서명이 맞지 않거나 이전 버전이면 쓰지 않고, 앱에 들어 있는 기본 카탈로그로 동작해요.\n• 카탈로그에 없는 서비스는 \'신고\'로 알릴 수 있어요. 서비스 이름·표시 이름·실행 파일 이름·서명자만 담긴 GitHub 이슈 초안이 열리고, 내용을 확인한 뒤 직접 제출해요 (경로는 담지 않아요).\n• 새로 설치된 서비스도 알아채요. 서비스를 읽을 때마다(앱을 켤 때, 30분마다) 지난번에 본 목록과 견주고, 카탈로그에 없어도 이름·경로·서명자가 보안 프로그램처럼 보이면 후보로 알려요. 아이콘 배지와 트레이 툴팁에 개수가 나와요. 처음 실행 때는 지금 있는 서비스를 기준으로 삼고 알리지 않아요.\n• 후보를 목록에 넣을 때는 카테고리와 켤 모드를 함께 정해요. 모드에서 켜지 않으면 그 서비스는 모든 모드에서 꺼져요. 후보가 아니라고 판단하면 \'무시\'해서 다시 보지 않을 수 있어요.\n• 처음 설치하면 이 PC에서 찾은 보안 서비스를 한 화면에 보여 줘요. 카탈로그가 아는 서비스는 미리 체크돼 있고, 보안 프로그램으로 보이는 후보는 체크하지 않은 채 이유와 함께 나와요. 확인하고 [추가하고 시작]을 누르면 목록과 카테고리, 뱅킹 모드가 만들어져요. [나중에]를 누르면 지구본 아이콘에서 같은 일을 할 수 있어요.\n• 후보와 발견한 서비스 옆의 돋보기 단추를 누르면 브라우저에서 그 서비스를 검색해요. 이 서비스가 무엇인지 보고 판단하는 데 쓰세요. 검색어는 서비스 이름과 실행 파일 이름뿐이고 경로는 보내지 않아요. Windows는 기본 검색엔진을 앱에 알려 주지 않아서, 카탈로그 창 아래에서 검색 엔진(Google, Naver, Bing, DuckDuckGo)을 고를 수 있어요.'**
  String get helpCatalogBody;

  /// No description provided for @catalogKeyInfo.
  ///
  /// In ko, this message translates to:
  /// **'서명 확인용 공개키: {fp}…'**
  String catalogKeyInfo(String fp);

  /// No description provided for @catalogErrSignatureDetail.
  ///
  /// In ko, this message translates to:
  /// **'서명이 맞지 않아요 (받은 카탈로그 {bytes}바이트, 서명 {sig}…, 공개키 {fp}…)'**
  String catalogErrSignatureDetail(int bytes, String sig, String fp);

  /// No description provided for @suspectsHeader.
  ///
  /// In ko, this message translates to:
  /// **'보안 프로그램으로 보이는 서비스 {n}개 (카탈로그에 없어요)'**
  String suspectsHeader(int n);

  /// No description provided for @suspectsHint.
  ///
  /// In ko, this message translates to:
  /// **'이름·경로·서명자로 짐작한 후보예요. 틀릴 수 있으니 이유를 보고 골라 주세요.'**
  String get suspectsHint;

  /// No description provided for @suspectReasonName.
  ///
  /// In ko, this message translates to:
  /// **'이름에 \'{v}\''**
  String suspectReasonName(String v);

  /// No description provided for @suspectReasonDisplay.
  ///
  /// In ko, this message translates to:
  /// **'표시 이름에 \'{v}\''**
  String suspectReasonDisplay(String v);

  /// No description provided for @suspectReasonPath.
  ///
  /// In ko, this message translates to:
  /// **'실행 경로에 \'{v}\''**
  String suspectReasonPath(String v);

  /// No description provided for @suspectReasonSigner.
  ///
  /// In ko, this message translates to:
  /// **'서명자에 \'{v}\''**
  String suspectReasonSigner(String v);

  /// No description provided for @suspectAdd.
  ///
  /// In ko, this message translates to:
  /// **'선택한 {n}개 추가…'**
  String suspectAdd(int n);

  /// No description provided for @suspectIgnore.
  ///
  /// In ko, this message translates to:
  /// **'선택한 {n}개 무시'**
  String suspectIgnore(int n);

  /// No description provided for @suspectUnignore.
  ///
  /// In ko, this message translates to:
  /// **'무시한 서비스 {n}개 다시 보기'**
  String suspectUnignore(int n);

  /// No description provided for @suspectAddTitle.
  ///
  /// In ko, this message translates to:
  /// **'서비스 {n}개를 목록에 추가'**
  String suspectAddTitle(int n);

  /// No description provided for @suspectCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get suspectCategory;

  /// No description provided for @suspectNewCategory.
  ///
  /// In ko, this message translates to:
  /// **'새 카테고리 이름'**
  String get suspectNewCategory;

  /// No description provided for @suspectCategoryDefault.
  ///
  /// In ko, this message translates to:
  /// **'새 보안 서비스'**
  String get suspectCategoryDefault;

  /// No description provided for @suspectModesTitle.
  ///
  /// In ko, this message translates to:
  /// **'어느 모드에서 켤까요?'**
  String get suspectModesTitle;

  /// No description provided for @suspectModeItem.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 모드에서 켜기'**
  String suspectModeItem(String name);

  /// No description provided for @suspectModesNote.
  ///
  /// In ko, this message translates to:
  /// **'체크하지 않은 모드에서는 이 서비스가 꺼져요. 뱅킹처럼 보안 서비스가 필요한 모드는 체크하세요. 나중에 모드 관리에서 바꿀 수 있어요.'**
  String get suspectModesNote;

  /// No description provided for @suspectNoMode.
  ///
  /// In ko, this message translates to:
  /// **'\'{category}\' 카테고리는 어느 모드에서도 켜지 않도록 추가했어요. 모든 모드에서 꺼져요. 필요하면 모드 관리에서 바꾸세요.'**
  String suspectNoMode(String category);

  /// No description provided for @trayAlerts.
  ///
  /// In ko, this message translates to:
  /// **'새 보안 서비스 의심 {n}개'**
  String trayAlerts(int n);

  /// No description provided for @setupTitle.
  ///
  /// In ko, this message translates to:
  /// **'처음 설정: 이 PC의 보안 서비스'**
  String get setupTitle;

  /// No description provided for @setupIntro.
  ///
  /// In ko, this message translates to:
  /// **'이 PC에서 보안 프로그램으로 보이는 서비스를 찾았어요. 확인하고 시작하세요. 나중에 언제든 바꿀 수 있어요.'**
  String get setupIntro;

  /// No description provided for @setupNothing.
  ///
  /// In ko, this message translates to:
  /// **'이 PC에서 보안 서비스를 찾지 못했어요. 은행 사이트에서 보안 프로그램이 새로 설치되면 알려 드릴게요.'**
  String get setupNothing;

  /// No description provided for @setupFoundHeader.
  ///
  /// In ko, this message translates to:
  /// **'카탈로그가 아는 서비스 {n}개'**
  String setupFoundHeader(int n);

  /// No description provided for @setupCandidatesHeader.
  ///
  /// In ko, this message translates to:
  /// **'보안 프로그램으로 보이는 후보 {n}개 (확인 필요)'**
  String setupCandidatesHeader(int n);

  /// No description provided for @setupCandidatesHint.
  ///
  /// In ko, this message translates to:
  /// **'이름·경로·서명자로 짐작한 후보예요. 틀릴 수 있어서 체크하지 않았어요. 이유를 보고 골라 주세요.'**
  String get setupCandidatesHint;

  /// No description provided for @setupModesTitle.
  ///
  /// In ko, this message translates to:
  /// **'어느 모드에서 켤까요?'**
  String get setupModesTitle;

  /// No description provided for @setupModesNote.
  ///
  /// In ko, this message translates to:
  /// **'체크하지 않은 모드에서는 고른 서비스가 꺼져요. 뱅킹처럼 보안 서비스가 필요한 모드는 체크하세요.'**
  String get setupModesNote;

  /// No description provided for @setupSkip.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get setupSkip;

  /// No description provided for @setupStart.
  ///
  /// In ko, this message translates to:
  /// **'추가하고 시작 ({n})'**
  String setupStart(int n);

  /// No description provided for @emptyFind.
  ///
  /// In ko, this message translates to:
  /// **'이 PC의 보안 서비스 찾기'**
  String get emptyFind;

  /// No description provided for @searchTooltip.
  ///
  /// In ko, this message translates to:
  /// **'{engine}에서 검색 (브라우저가 열려요)'**
  String searchTooltip(String engine);

  /// No description provided for @searchEngineLabel.
  ///
  /// In ko, this message translates to:
  /// **'검색 엔진: {engine}'**
  String searchEngineLabel(String engine);

  /// No description provided for @searchEngineTooltip.
  ///
  /// In ko, this message translates to:
  /// **'검색 엔진 바꾸기'**
  String get searchEngineTooltip;

  /// No description provided for @searchNote.
  ///
  /// In ko, this message translates to:
  /// **'검색 단추는 서비스 이름·실행 파일 이름만 검색어로 써서 브라우저에서 열어요. 경로는 보내지 않아요.'**
  String get searchNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
