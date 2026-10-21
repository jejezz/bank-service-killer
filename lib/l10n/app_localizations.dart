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

  /// No description provided for @homeTurnOnAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 켜기 (뱅킹용)'**
  String get homeTurnOnAll;

  /// No description provided for @homeTurnOffAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 끄기'**
  String get homeTurnOffAll;

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
  /// **'서비스 이름 뒤의 [A] [B] [C]'**
  String get helpGroupTitle;

  /// No description provided for @helpGroupBody.
  ///
  /// In ko, this message translates to:
  /// **'항목을 추가할 때 고른 분류 표시예요.\n• A: 보안과 무관한 서비스 (예: 오디오 효과)\n• B: 웹 플러그인형 보안 서비스 (대부분의 금융 보안 프로그램)\n• C: 드라이버와 연동될 수 있는 서비스 (키보드보안·개인방화벽 등). 끄면 문제가 생길 수 있으니 주의하세요.\n분류는 참고용이라 켜기·끄기 동작에는 영향이 없어요.'**
  String get helpGroupBody;

  /// No description provided for @helpOnOffTitle.
  ///
  /// In ko, this message translates to:
  /// **'켜기·끄기'**
  String get helpOnOffTitle;

  /// No description provided for @helpOnOffBody.
  ///
  /// In ko, this message translates to:
  /// **'• 전체 켜기 / 끄기, 그리고 항목 오른쪽의 재생·정지 단추는 서비스를 지금 바로 시작하거나 중지해요. 시작 유형이 \'사용 안 함\'이면 \'수동\'으로 바꾼 뒤 시작해요.\n• 시작·중지 후 실제 상태가 바뀌었는지 확인하고 결과를 아래 로그에 남겨요. 중지 후 3초 뒤 다시 살아났는지도 한 번 더 확인해요.\n• 끄기는 서비스를 멈출 뿐 시작 유형은 바꾸지 않아요. 시작 유형이 \'자동\'이면 PC를 다시 켤 때 서비스가 또 시작돼요.'**
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

  /// No description provided for @groupA.
  ///
  /// In ko, this message translates to:
  /// **'A: 보안 무관'**
  String get groupA;

  /// No description provided for @groupB.
  ///
  /// In ko, this message translates to:
  /// **'B: 웹 플러그인'**
  String get groupB;

  /// No description provided for @groupC.
  ///
  /// In ko, this message translates to:
  /// **'C: 드라이버 연동 가능'**
  String get groupC;

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
