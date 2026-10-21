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
