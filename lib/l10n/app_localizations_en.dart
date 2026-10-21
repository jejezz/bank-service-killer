// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutTooltip => 'About';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get aboutOpenSourceLicenses => 'Open Source Licenses';

  @override
  String get aboutRepository => 'GitHub';

  @override
  String get commonClose => 'Close';

  @override
  String aboutMenuItem(String appName) {
    return 'About $appName';
  }

  @override
  String get themeMenuTooltip => 'Theme';

  @override
  String get themeSystem => 'Follow System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageMenuTooltip => 'Language';

  @override
  String get languageSystem => 'System / 시스템 설정 따르기';

  @override
  String get languageSystemShort => 'System';

  @override
  String get aboutTagline =>
      'Turn resident security services on only when you need them';

  @override
  String get aboutDescription =>
      'Switch banking and keyboard security services on for banking and off afterwards, and verify the change actually took effect.';

  @override
  String get homeEmptyTitle => 'No services to watch';

  @override
  String get homeEmptyAction => 'Add Service';

  @override
  String get updateCheckMenuItem => 'Check for Updates';

  @override
  String get updateChecking => 'Checking for updates…';

  @override
  String get updateAvailableTitle => 'A new version is available';

  @override
  String updateAvailableBody(String appName, String current, String latest) {
    return '$appName $latest is available. You have $current.';
  }

  @override
  String get updateReleaseNotes => 'What\'s new';

  @override
  String get updateNow => 'Update now';

  @override
  String get updateLater => 'Later';

  @override
  String get updateSkipVersion => 'Skip this version';

  @override
  String get updateDownloading => 'Downloading…';

  @override
  String get updateVerifying => 'Verifying the file…';

  @override
  String updateDownloadProgress(String received, String total) {
    return '$received / $total';
  }

  @override
  String get updateCancel => 'Cancel';

  @override
  String get updateFailedTitle => 'Couldn\'t update';

  @override
  String get updateCheckFailedTitle => 'Couldn\'t check for updates';

  @override
  String get updateErrorNetwork =>
      'Couldn\'t reach the update server. Check your internet connection and try again.';

  @override
  String get updateErrorChecksum =>
      'The downloaded file didn\'t pass verification, so it was not installed. Please try again later.';

  @override
  String get updateErrorInstall => 'Couldn\'t start the installation.';

  @override
  String get updateErrorGeneric =>
      'The update server sent an unexpected response. Please try again later.';

  @override
  String get updateUpToDateTitle => 'You\'re up to date';

  @override
  String updateUpToDateBody(String version) {
    return 'You\'re using version $version.';
  }

  @override
  String get updateUnavailableTitle => 'Install it manually';

  @override
  String updateUnavailableBody(String latest) {
    return 'Version $latest is available, but the app can\'t install it automatically. Please download it from the release page.';
  }

  @override
  String get updateOpenReleasePage => 'Open release page';

  @override
  String get updateBrowserDownloadTitle => 'Downloading in your browser';

  @override
  String updateBrowserDownloadBody(String appName) {
    return 'Your browser is downloading the new version. Open the DMG and drag $appName to the Applications folder. If it\'s running, quit it first and replace the old copy.';
  }

  @override
  String get updateMacosOpenedTitle => 'The installer window is open';

  @override
  String updateMacosOpenedBody(String appName) {
    return 'In the window that opened, drag $appName to the Applications folder. If it\'s running, quit it first and replace the old copy.';
  }

  @override
  String get updateWindowsInstallTitle => 'The installer is open';

  @override
  String updateWindowsInstallBody(String appName) {
    return '$appName must quit before it can be updated. Follow the installer\'s instructions.';
  }

  @override
  String updateQuitApp(String appName) {
    return 'Quit $appName';
  }

  @override
  String get updateLinuxInstallTitle => 'Ready to install';

  @override
  String updateLinuxInstallBody(String appName) {
    return '$appName will quit and install the update, then start again automatically.';
  }

  @override
  String get updateQuitAndInstall => 'Quit and install';

  @override
  String get updateBusyTitle => 'Can\'t update right now';

  @override
  String get updateBusyBody =>
      'A task is in progress. Please try again when it has finished.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAdd => 'Add';

  @override
  String get homeTurnOnAll => 'Turn All On (for Banking)';

  @override
  String get homeTurnOffAll => 'Turn All Off';

  @override
  String get refreshTooltip => 'Refresh (F5)';

  @override
  String get addServiceTooltip => 'Add Service (Ctrl+N)';

  @override
  String get adminWarning =>
      'Not running as administrator. Starting, stopping and changing services only works with administrator rights.';

  @override
  String get trayShow => 'Open window';

  @override
  String get trayExit => 'Exit';

  @override
  String get startupMenuTooltip => 'Startup';

  @override
  String get startupAutoRun => 'Run at Windows startup (stay in tray)';

  @override
  String startupChangeFailed(String detail) {
    return 'Couldn\'t change the startup setting: $detail';
  }

  @override
  String get notInstalled => 'Not installed / name mismatch';

  @override
  String serviceSubtitle(String displayName, String state, String startMode) {
    return '$displayName · $state · Startup $startMode';
  }

  @override
  String get msconfigDisabledNote => ' · disabled in msconfig';

  @override
  String get startModeAuto => 'Automatic';

  @override
  String get startModeManual => 'Manual';

  @override
  String get startModeDisabled => 'Disabled';

  @override
  String get stopVerifyTooltip => 'Stop and verify';

  @override
  String get startVerifyTooltip => 'Start and verify';

  @override
  String get removeTooltip => 'Remove from list';

  @override
  String get addDialogTitle => 'Add Watched Service';

  @override
  String get addDialogField => 'Service name or display name';

  @override
  String get groupA => 'A: Not security-related';

  @override
  String get groupB => 'B: Web plugin';

  @override
  String get groupC => 'C: May be tied to a driver';

  @override
  String logQueryError(String error) {
    return 'Query error: $error';
  }

  @override
  String logAlreadyInList(String name) {
    return 'Already in the list: $name';
  }

  @override
  String logLine(String name, String message) {
    return '$name: $message';
  }

  @override
  String get logOk => 'OK';

  @override
  String get logFail => 'Failed';

  @override
  String get logEmptyTitle => 'Activity log';

  @override
  String svcModeChanged(String mode) {
    return 'Startup type changed to $mode';
  }

  @override
  String svcStartCmdFailed(int code, String detail) {
    return 'Start command failed ($code): $detail';
  }

  @override
  String svcStopCmdFailed(int code, String detail) {
    return 'Stop command failed ($code): $detail';
  }

  @override
  String get svcRestarted =>
      'Service restarted after stopping (a watchdog may be recovering it)';

  @override
  String get svcStopVerified => 'Stop verified (still Stopped after 3 seconds)';

  @override
  String get svcNotFound => 'Service not found';

  @override
  String svcStateVerified(String label, String target) {
    return '$label verified ($target)';
  }

  @override
  String svcStateFailed(String label, String state) {
    return '$label not verified: current state $state';
  }

  @override
  String get svcLabelStart => 'Start';

  @override
  String get svcLabelStop => 'Stop';

  @override
  String get svcStateUnknown => 'unknown';

  @override
  String svcListFailed(String error) {
    return 'Failed to list services: $error';
  }
}
