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
  String get logTitle => 'Log';

  @override
  String get logEmpty => 'Results of your actions appear here.';

  @override
  String get logResizeTooltip => 'Drag to resize the log panel';

  @override
  String get helpTooltip => 'How to use';

  @override
  String get helpTitle => 'How to use';

  @override
  String get helpClose => 'Close';

  @override
  String get helpPurposeTitle => 'What is this app?';

  @override
  String get helpPurposeBody =>
      'Security programs required for online banking often slow your PC or cause conflicts the rest of the time. This app turns those resident services on only when you bank, turns them off afterwards, and verifies they really started or stopped. Controlling services needs administrator rights, so Windows shows a UAC prompt when you launch it.';

  @override
  String get helpListTitle => 'Where does the service list come from?';

  @override
  String get helpListBody =>
      'The list is not built automatically. It starts with common banking/security services, and after that you manage it yourself.\n• Add: press + (Ctrl+N) and type a service name or display name; matching services installed on this PC appear below — click one to pick it.\n• Newly installed services are NOT detected automatically; add them yourself. You can find service names in msconfig (Services tab) or services.msc.\n• Partial names match too. \"Not installed / name mismatch\" means the service isn\'t on this PC or the name differs.\n• The list is saved to %APPDATA%\\BankServiceKiller\\watchlist.json. Refresh (F5) re-reads the current service states.';

  @override
  String get helpGroupTitle => 'Categories and modes';

  @override
  String get helpGroupBody =>
      '• Categories: labels that group services (e.g. keyboard security, certificates, per bank). A service can be in several. Click a chip at the top to show only that category; \"Turn … on / off\" then applies only to it.\n• Modes: target states — what to turn on, what to leave alone and what to turn off. Pick one in the [Banking | Dev …] toggle at the top and the services are started/stopped to match. Services already in the right state are left alone.\n• Pressing a mode first opens a preview of the services to turn off / on. Nothing changes until you press Run; Cancel leaves everything as it is. (The default mode at app start and auto-return run without asking, since nobody may be there.)\n• The current mode is judged from the real service states, not a saved value. If nothing matches it shows \'Mixed\'; pressing a mode while mixed only fixes the remaining services.\n• Manage modes (sliders icon) lets you create and edit modes. The ★ default mode is applied when the app starts (including at Windows sign-in) and on auto-return.\n• Auto-return: give a mode a time and it falls back to the default mode afterwards, with a warning 1 minute before.\n• The tray icon\'s right-click menu also switches modes, with a check on the current one.\n• A mode can be defined per service, not just per category. Open a mode in Manage modes and use the \'By service\' tab to choose On / Keep / Off. A direct setting overrides the category setting. Sites usually need only a few services, so a small mode that turns on just those also switches faster. The search box, the Installed / Running / Set directly filters and \'Set all shown at once\' make large lists easy, and the duplicate button starts from an existing mode.\n• The search box on the main screen finds services in the list right away. You can also turn just the search results on or off.\n• Turn services on and off the way you want, then press [Save current state as a mode]: services that are running become \'On\' and stopped ones \'Off\' in a new mode. It\'s handy for keeping the state that works on a site. You can create a new mode or overwrite an existing one (overwriting replaces that mode\'s category and service settings with the current state; its auto-return time stays). Services not installed on this PC are left out.';

  @override
  String get helpOnOffTitle => 'Turning on and off';

  @override
  String get helpOnOffBody =>
      '• Switching modes, \"Turn … on / off\" and the play/stop button on each row start or stop services right now. If the startup type is Disabled it is set to Manual first, then started.\n• After starting or stopping, the app verifies the real state and writes the result to the log below. After a stop it checks again 3 seconds later in case the service came back.\n• Turning off only stops the service; it doesn\'t change the startup type. If it is Automatic, it starts again the next time the PC boots.';

  @override
  String get helpModeTitle => 'Startup type (Automatic / Manual / Disabled)';

  @override
  String get helpModeBody =>
      'Pick it from the dropdown on a row; it applies immediately. It doesn\'t start or stop the running service now — it affects how the service starts from the next boot onward.\n• Automatic: starts at boot.\n• Manual: doesn\'t start at boot; start it with the on button when needed. Recommended for banking services.\n• Disabled: starting is blocked. This app\'s on button switches it to Manual first, then starts it.\n\"disabled in msconfig\" marks a service you turned off in msconfig.';

  @override
  String get helpResidentTitle => 'Resident mode and startup';

  @override
  String get helpResidentBody =>
      'Closing the window doesn\'t quit; the app stays in the system tray. Click the tray icon to open the window, and use Exit in its right-click menu to quit completely. On first run it registers itself to start at Windows sign-in (tray only, no window); toggle this from the power icon in the top bar.';

  @override
  String get commonSave => 'Save';

  @override
  String get editTooltip => 'Edit name / group';

  @override
  String get editDialogTitle => 'Edit Watched Service';

  @override
  String get systemToolsTooltip => 'Open Windows service tools';

  @override
  String get openMsconfig => 'msconfig (Services tab)';

  @override
  String get openServicesMsc => 'Services (services.msc)';

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

  @override
  String get catAll => 'All';

  @override
  String get catUncategorized => 'Uncategorized';

  @override
  String get catEmptyFilter => 'No services in this category.';

  @override
  String get catManageTooltip => 'Manage categories';

  @override
  String get catManageTitle => 'Manage categories';

  @override
  String get catManageHint =>
      'Group services into categories to turn just that group on or off, and to build modes from. Deleting a category keeps its services.';

  @override
  String get catAddField => 'New category name';

  @override
  String get catRename => 'Rename';

  @override
  String get catDelete => 'Delete category';

  @override
  String get catExists => 'That name already exists or can\'t be used.';

  @override
  String catItemCount(int n) {
    return '$n services';
  }

  @override
  String get catDefaultA => 'Not security-related';

  @override
  String get catDefaultB => 'Web plugin';

  @override
  String get catDefaultC => 'Driver-linked';

  @override
  String get addDialogCategories => 'Categories (pick any)';

  @override
  String get addDialogNewCategory => 'Create a new category';

  @override
  String scopeTurnOn(String scope) {
    return 'Turn $scope on';
  }

  @override
  String scopeTurnOff(String scope) {
    return 'Turn $scope off';
  }

  @override
  String modeCurrent(String name) {
    return 'Current mode: $name';
  }

  @override
  String modeMixed(String name, int ok, int total) {
    return 'Mixed · $name $ok/$total';
  }

  @override
  String get modeUnknown => 'Checking service states…';

  @override
  String modeRevertIn(int minutes, String name) {
    return 'Returns to \'$name\' in $minutes min';
  }

  @override
  String modeToggleTooltip(String name) {
    return 'Switch to \'$name\' mode';
  }

  @override
  String get modeManageTooltip => 'Manage modes';

  @override
  String get modeManageTitle => 'Manage modes';

  @override
  String get modeManageHint =>
      'A mode is a target state: what to turn on, what to leave alone, and what to turn off. Switching turns on the \'on\' categories, leaves the \'keep\' ones untouched, and turns off every other watched service. The ★ default mode is applied when the app starts and on auto-return.';

  @override
  String get modeDefaultHint =>
      'Set as default mode (applied at app start and on auto-return)';

  @override
  String get modeDefaultTag => 'default';

  @override
  String get modeAdd => 'Add mode';

  @override
  String get modeDelete => 'Delete mode (the last one can\'t be deleted)';

  @override
  String get modeNameExists => 'That name already exists or can\'t be used.';

  @override
  String get modeNewTitle => 'New mode';

  @override
  String get modeEditTitle => 'Edit mode';

  @override
  String get modeName => 'Mode name';

  @override
  String get modeCategoriesLabel => 'What to do per category';

  @override
  String get modeCategoriesHint =>
      'On: turned on in this mode · Keep: left untouched · Off: turned off. Services in no category are turned off.';

  @override
  String get wantOn => 'On';

  @override
  String get wantKeep => 'Keep';

  @override
  String get wantOff => 'Off';

  @override
  String get modeRevertField => 'Auto-return';

  @override
  String get modeRevertOff => 'Don\'t return';

  @override
  String modeRevertAfter(int n) {
    return 'Back to default after $n min';
  }

  @override
  String get modeRevertHint =>
      'After switching to this mode, the default mode is restored once the time is up. You get a warning 1 minute before and can extend.';

  @override
  String modeSummaryOn(String list) {
    return 'On: $list';
  }

  @override
  String get modeSummaryNoneOn => 'Turns nothing on';

  @override
  String modeSummaryKeep(String list) {
    return 'Keep: $list';
  }

  @override
  String logModePlan(String name, int start, int stop) {
    return 'Switching to \'$name\': $start on, $stop off';
  }

  @override
  String logModeAlready(String name) {
    return 'Already in \'$name\' mode.';
  }

  @override
  String logModeDone(String name) {
    return 'Switched to \'$name\' (all service states verified)';
  }

  @override
  String logModePartial(String name, int ok, int total) {
    return 'Switch to \'$name\' is incomplete: $ok/$total. Press the mode button again to retry only the remaining services.';
  }

  @override
  String logModeRevert(String name) {
    return 'Auto-return: going back to \'$name\'';
  }

  @override
  String logModeStartup(String name) {
    return 'App start: applying default mode \'$name\'';
  }

  @override
  String revertWarnTitle(String to) {
    return 'Returning to \'$to\' soon';
  }

  @override
  String revertWarnBody(String from, int minutes, String to) {
    return 'It\'s been $minutes min since you switched to \'$from\'. It will return to \'$to\' automatically in 1 minute.';
  }

  @override
  String revertExtend(int n) {
    return 'Extend $n min';
  }

  @override
  String get revertNow => 'Return now';

  @override
  String get modeDefaultBanking => 'Banking';

  @override
  String get modeDefaultDev => 'Dev';

  @override
  String planTitle(String name) {
    return 'Switch to \'$name\' mode';
  }

  @override
  String get planIntro => 'This is what will change. Review it, then run.';

  @override
  String planStopHeader(int n) {
    return '$n services to turn off';
  }

  @override
  String planStartHeader(int n) {
    return '$n services to turn on';
  }

  @override
  String planUnchanged(int n) {
    return '$n services already match and are left alone.';
  }

  @override
  String get planRun => 'Run';

  @override
  String get planEnableNote =>
      'Startup type is Disabled, so it\'s set to Manual first, then started';

  @override
  String get planAutoNote =>
      'Startup type is Automatic, so it starts again after a reboot';

  @override
  String logModeCancelled(String name) {
    return 'Cancelled the switch to \'$name\'.';
  }

  @override
  String get catalogTooltip => 'Security service catalog';

  @override
  String catalogTooltipCount(int n) {
    return 'Security service catalog · $n new suggestions';
  }

  @override
  String get catalogTitle => 'Security service catalog';

  @override
  String catalogInfo(int version, String updated) {
    return 'Catalog v$version · $updated';
  }

  @override
  String get catalogSourceBundled => 'Built-in catalog shipped with the app';

  @override
  String get catalogSourceCache => 'Downloaded catalog (signature verified)';

  @override
  String get catalogSourceRemote => 'Just downloaded (signature verified)';

  @override
  String catalogChecked(String when) {
    return 'Last checked: $when';
  }

  @override
  String get catalogNeverChecked => 'Not checked yet';

  @override
  String get catalogCheckNow => 'Check now';

  @override
  String get catalogChecking => 'Checking…';

  @override
  String get catalogRemoteOff =>
      'Remote updates are off (no signing public key is set). Only the built-in catalog is used.';

  @override
  String get catalogResultUpdated => 'Got a new catalog.';

  @override
  String get catalogResultUpToDate => 'Already up to date.';

  @override
  String catalogResultRejected(String reason) {
    return 'The downloaded catalog was not used: $reason';
  }

  @override
  String catalogResultFailed(String reason) {
    return 'Couldn\'t get the catalog: $reason';
  }

  @override
  String get catalogErrNetwork => 'network error';

  @override
  String get catalogErrSignature => 'signature does not match';

  @override
  String get catalogErrFormat => 'invalid format';

  @override
  String get catalogErrRollback => 'older version';

  @override
  String get catalogScanning => 'Checking this PC\'s services…';

  @override
  String catalogFindsHeader(int n) {
    return '$n services found on this PC that aren\'t in your list';
  }

  @override
  String catalogRenamesHeader(int n) {
    return '$n items that look renamed';
  }

  @override
  String get catalogNothing => 'No new services found and no renamed items.';

  @override
  String catalogAddSelected(int n) {
    return 'Add $n selected';
  }

  @override
  String get catalogRenameApply => 'Rename';

  @override
  String catalogRenameLine(String from, String to) {
    return '$from → $to';
  }

  @override
  String catalogRenameNote(String product) {
    return 'The catalog knows the old name as part of \'$product\'';
  }

  @override
  String get catalogDriverTag => 'Driver-linked';

  @override
  String catalogAdded(int n) {
    return 'Added $n services to your list.';
  }

  @override
  String catalogNewCategoriesNote(String list) {
    return 'The new categories ($list) aren\'t set to \'On\' in any mode yet, so every mode turns them off until you decide. Set them in Manage modes.';
  }

  @override
  String get catalogReport => 'Report a service that\'s not listed…';

  @override
  String get catalogSuggestionNote =>
      'The catalog only suggests. It never turns services on or off by itself.';

  @override
  String get reportTitle => 'Report a service';

  @override
  String get reportHint =>
      'Pick a service the catalog doesn\'t know. Only the content below goes into a draft GitHub issue, and you submit it yourself.';

  @override
  String get reportSearch => 'Search services';

  @override
  String get reportWillSend => 'What goes into the draft issue (no paths):';

  @override
  String get reportOpen => 'Open on GitHub';

  @override
  String get reportBack => 'Pick another';

  @override
  String get reportOpenFailed => 'Couldn\'t open the browser.';

  @override
  String get reportChecking => 'Checking the signer…';

  @override
  String get helpCatalogTitle => 'Security service catalog';

  @override
  String get helpCatalogBody =>
      'Security services change names between products and versions, so a fixed list goes stale quickly. The app keeps a catalog of which product installs under which names and executables, and refreshes it regularly (every 24 hours).\n• The globe icon (Security service catalog) shows services found on this PC that aren\'t in your list, and items that look renamed. A number appears on the icon when there are new suggestions.\n• The catalog only suggests. It never turns services on or off by itself, and you choose what to add. Newly created categories aren\'t set to \'On\' in any mode, so every mode turns them off until you decide in Manage modes.\n• Downloaded catalogs are signature-checked. One with a bad signature or an older version is ignored and the built-in catalog is used.\n• For a service the catalog doesn\'t know, use \'Report\'. It opens a draft GitHub issue containing only the service name, display name, executable name and signer; you review it and submit it yourself (no paths are included).\n• New installs are noticed too. Each time services are read (at start and every 30 minutes) they are compared with what was seen last time, and even if the catalog doesn\'t know a service, it\'s flagged as a candidate when its name, path or signer looks like security software. The count shows on the icon badge and the tray tooltip. On the first run the current services become the baseline and nothing is flagged.\n• When you add a candidate you also pick its category and which modes turn it on. A mode you leave unchecked turns it off. If you decide it isn\'t security software, \'Ignore\' it so it isn\'t shown again.\n• On first install, the security services found on this PC are shown on one screen. Ones the catalog knows are pre-checked; candidates that merely look like security software are unchecked and come with their reasons. Press [Add and start] and your list, categories and Banking mode are created. If you press [Later], the globe icon does the same thing.\n• The magnifier button next to a candidate or found service searches for it in your browser, so you can see what it is before deciding. The query is only the service name and executable name; no path is sent. Windows doesn\'t tell apps your default search engine, so you pick one (Google, Naver, Bing, DuckDuckGo) at the bottom of the catalog window.';

  @override
  String catalogKeyInfo(String fp) {
    return 'Signing public key: $fp…';
  }

  @override
  String catalogErrSignatureDetail(int bytes, String sig, String fp) {
    return 'signature does not match (catalog $bytes bytes, signature $sig…, public key $fp…)';
  }

  @override
  String suspectsHeader(int n) {
    return '$n services that look like security software (not in the catalog)';
  }

  @override
  String get suspectsHint =>
      'Guessed from the name, path and signer. They can be wrong, so check the reasons before choosing.';

  @override
  String suspectReasonName(String v) {
    return 'name contains \'$v\'';
  }

  @override
  String suspectReasonDisplay(String v) {
    return 'display name contains \'$v\'';
  }

  @override
  String suspectReasonPath(String v) {
    return 'path contains \'$v\'';
  }

  @override
  String suspectReasonSigner(String v) {
    return 'signer contains \'$v\'';
  }

  @override
  String suspectAdd(int n) {
    return 'Add $n selected…';
  }

  @override
  String suspectIgnore(int n) {
    return 'Ignore $n selected';
  }

  @override
  String suspectUnignore(int n) {
    return 'Show $n ignored services again';
  }

  @override
  String suspectAddTitle(int n) {
    return 'Add $n services to the list';
  }

  @override
  String get suspectCategory => 'Category';

  @override
  String get suspectNewCategory => 'New category name';

  @override
  String get suspectCategoryDefault => 'New security services';

  @override
  String get suspectModesTitle => 'Turn on in which modes?';

  @override
  String suspectModeItem(String name) {
    return 'Turn on in \'$name\' mode';
  }

  @override
  String get suspectModesNote =>
      'In modes you leave unchecked, this service is turned off. Check modes that need security services, like Banking. You can change this later in Manage modes.';

  @override
  String suspectNoMode(String category) {
    return 'Added the \'$category\' category without turning it on in any mode, so every mode turns it off. Change this in Manage modes if needed.';
  }

  @override
  String trayAlerts(int n) {
    return '$n suspected new security services';
  }

  @override
  String get setupTitle => 'First setup: security services on this PC';

  @override
  String get setupIntro =>
      'These services on this PC look like security software. Review them and start. You can change everything later.';

  @override
  String get setupNothing =>
      'No security services were found on this PC. You\'ll be told when a bank site installs new security software.';

  @override
  String setupFoundHeader(int n) {
    return '$n services the catalog knows';
  }

  @override
  String setupCandidatesHeader(int n) {
    return '$n candidates that look like security software (please check)';
  }

  @override
  String get setupCandidatesHint =>
      'Guessed from the name, path and signer. They can be wrong, so they\'re unchecked. Check the reasons before choosing.';

  @override
  String get setupModesTitle => 'Turn on in which modes?';

  @override
  String get setupModesNote =>
      'In modes you leave unchecked, the chosen services are turned off. Check modes that need security services, like Banking.';

  @override
  String get setupSkip => 'Later';

  @override
  String setupStart(int n) {
    return 'Add and start ($n)';
  }

  @override
  String get emptyFind => 'Find security services on this PC';

  @override
  String searchTooltip(String engine) {
    return 'Search on $engine (opens your browser)';
  }

  @override
  String searchEngineLabel(String engine) {
    return 'Search engine: $engine';
  }

  @override
  String get searchEngineTooltip => 'Change search engine';

  @override
  String get searchNote =>
      'The search button uses only the service name and executable name as the query, in your browser. No path is sent.';

  @override
  String get modeTabCategories => 'By category';

  @override
  String get modeTabServices => 'By service';

  @override
  String get svcTabHint =>
      'Pick services one by one and set On / Keep / Off. What you set here overrides the category setting; press it again to clear it and fall back to the category.';

  @override
  String get svcSearchHint => 'Search services (name, note, category)';

  @override
  String get svcFilterInstalled => 'Installed';

  @override
  String get svcFilterRunning => 'Running';

  @override
  String get svcFilterDirect => 'Set directly';

  @override
  String svcShown(int n) {
    return '$n shown';
  }

  @override
  String get svcBulkTooltip => 'Set all shown services at once';

  @override
  String svcBulkSet(String want) {
    return 'Set all shown to \'$want\'';
  }

  @override
  String get svcBulkClear => 'Clear direct settings of shown';

  @override
  String svcByCategory(String want) {
    return 'By category: $want';
  }

  @override
  String get svcNoCategory => 'No category';

  @override
  String get svcNoResults => 'No services match.';

  @override
  String get notInstalledShort => 'not installed';

  @override
  String get modeClone => 'Duplicate mode';

  @override
  String modeCopyName(String name) {
    return '$name copy';
  }

  @override
  String modeSummaryServices(int n) {
    return '$n services set directly';
  }

  @override
  String get listSearchHint => 'Search services';

  @override
  String get listSearchClear => 'Clear search';

  @override
  String get searchResultsLabel => 'search results';

  @override
  String get searchNoResults => 'No search results.';

  @override
  String get modeEdit => 'Edit mode';

  @override
  String get snapshotButton => 'Save current state as a mode';

  @override
  String get snapshotTooltip =>
      'Save which services are on and which are off right now as a mode';

  @override
  String get snapshotTitle => 'Save current state as a mode';

  @override
  String snapshotSummary(int total, int on, int off) {
    return 'Saves the current state of $total services: $on on, $off off.';
  }

  @override
  String snapshotSkipped(int n) {
    return '$n services not installed on this PC are left out.';
  }

  @override
  String get snapshotNew => 'New mode';

  @override
  String get snapshotOverwrite => 'Overwrite existing';

  @override
  String get snapshotDefaultName => 'Current state';

  @override
  String get snapshotOverwriteNote =>
      'Overwriting replaces that mode\'s category and service settings with the current state. Its name and auto-return time stay.';

  @override
  String get snapshotOverwriteDefaultWarning =>
      'This is the default mode. The app returns to this state at start and on auto-return.';

  @override
  String get snapshotDoOverwrite => 'Overwrite';

  @override
  String logSnapshotSaved(String name, int n) {
    return 'Saved the current state as mode \'$name\' ($n services)';
  }

  @override
  String logSnapshotOverwritten(String name, int n) {
    return 'Overwrote mode \'$name\' with the current state ($n services)';
  }
}
