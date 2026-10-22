// From jejezz/application-release-templates common/ @ conventions-v1.
//
// 새 앱의 시작점. 규약이 요구하는 연결을 한곳에 모았다:
//   창 크기(window_manager) · 추가 라이선스 · 설정 로드 · 라이트/다크 ·
//   언어 해석 · macOS 앱 메뉴 About · 앱 바 [테마 | 언어 | 정보] · 빈 상태.
// 기존 앱에는 통째로 덮어쓰지 말고 필요한 부분만 옮긴다.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'about/about_dialog.dart';
import 'catalog/catalog.dart';
import 'catalog/catalog_controller.dart';
import 'catalog/public_key.dart';
import 'about/app_menu_bar.dart';
import 'about/extra_licenses.dart';
import 'app_identity.dart';
import 'home_page.dart';
import 'mode_actions.dart';
import 'l10n/app_localizations.dart';
import 'service_manager.dart';
import 'settings/app_settings.dart';
import 'startup_manager.dart';
import 'theme/app_theme.dart';
import 'update/update_scope.dart';
import 'update/update_service.dart';

const _modeKeyPrefix = 'mode:';

final bool _isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  registerExtraLicenses();

  if (_isDesktop) {
    await windowManager.ensureInitialized();
    // ui-ux.md §5: 최소 크기는 960×600 이하 (1366×768 노트북).
    const options = WindowOptions(
      minimumSize: Size(960, 600),
      title: AppIdentity.displayName,
    );
    // 상주 프로그램: 닫기 단추는 종료가 아니라 트레이로 숨기기다.
    await windowManager.setPreventClose(true);
    // 시작프로그램으로 실행됐으면 창 없이 트레이에만 둔다.
    final background = args.contains(StartupManager.backgroundArg);
    await windowManager.waitUntilReadyToShow(options, () async {
      if (background) return;
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final settings = await AppSettings.load();
  final catalog = await _createCatalog();
  if (Platform.isWindows) await _registerStartupOnce(settings);
  // 데스크톱이 아니거나 UPDATE_SERVER 가 비어 있으면 null — 업데이트 확인 없음.
  final updates = await UpdateService.create();
  // UpdateScope 는 MaterialApp 위에 둔다 — 정보 창이 이것을 읽어 "업데이트 확인" 단추를 붙인다.
  runApp(UpdateScope(
    service: updates,
    child: App(
      settings: settings,
      updates: updates,
      catalog: catalog,
      startedInBackground: args.contains(StartupManager.backgroundArg),
    ),
  ));
}

/// 앱에 들어 있는 기본 카탈로그를 읽고, 받아 둔 카탈로그가 있으면 얹고, 정해진 주기로 갱신하게 한다.
Future<CatalogController> _createCatalog() async {
  final bundled = Catalog.fromJson(jsonDecode(await rootBundle.loadString('catalog/catalog.json')));
  final base = Platform.environment['APPDATA'] ?? Directory.systemTemp.path;
  const url = AppIdentity.catalogUrl;
  final controller = CatalogController(
    bundled: bundled,
    cacheDir: Directory('$base\\BankServiceKiller\\catalog'),
    publicKey: await resolveCatalogPublicKey(
      defined: AppIdentity.catalogPublicKey,
      readAsset: () => rootBundle.loadString('catalog/public_key.txt'),
    ),
    url: url.isEmpty ? null : Uri.parse(url),
  );
  await controller.init();
  controller.startAutoRefresh();
  return controller;
}

/// 첫 실행 때 한 번만 시작프로그램으로 등록한다. 사용자가 나중에 끄면 다시 켜지 않는다.
Future<void> _registerStartupOnce(AppSettings settings) async {
  if (settings.startupRegistrationAttempted) return;
  if (!await ServiceManager.isAdmin()) return;
  final failed = !await StartupManager.isRegistered() && await StartupManager.register() != null;
  if (!failed) await settings.markStartupRegistrationAttempted();
}

class App extends StatefulWidget {
  const App({
    super.key,
    required this.settings,
    required this.catalog,
    this.updates,
    this.startedInBackground = false,
  });

  final AppSettings settings;
  final UpdateService? updates;
  final CatalogController catalog;

  /// 시작프로그램(--background)으로 떴는가. 그러면 목록을 읽은 뒤 기본 모드를 적용한다.
  final bool startedInBackground;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver, WindowListener, TrayListener {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _modeActions = ModeActions();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.settings.addListener(_syncWindowBrightness);
    _syncWindowBrightness();
    if (Platform.isWindows) {
      windowManager.addListener(this);
      trayManager.addListener(this);
      widget.settings.addListener(_updateTray);
      _modeActions.addListener(_updateTray);
      _initTray();
    }
    widget.updates?.startAutomaticCheck(_navigatorKey);
  }

  @override
  void dispose() {
    widget.settings.removeListener(_syncWindowBrightness);
    if (Platform.isWindows) {
      widget.settings.removeListener(_updateTray);
      _modeActions.removeListener(_updateTray);
      windowManager.removeListener(this);
      trayManager.removeListener(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 앱에서 다크를 골라도 OS가 라이트면 제목 표시줄은 밝게 남는다 (theming.md §4).
  @override
  void didChangePlatformBrightness() => _syncWindowBrightness();

  void _syncWindowBrightness() {
    if (!_isDesktop || Platform.isLinux) return;
    final brightness = switch (widget.settings.themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    windowManager.setBrightness(brightness);
  }

  // ── 상주(트레이) ─────────────────────────────────────────────

  Future<void> _initTray() async {
    await trayManager.setIcon('assets/icon/app_icon.ico');
    await trayManager.setToolTip(AppIdentity.displayName);
    await _updateTray();
  }

  Future<void> _updateTray() async {
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    final l10n = lookupAppLocalizations(AppSettings.resolveLocale(widget.settings.locale ?? device, const []));
    final current = _modeActions.current;
    final summary = _modeActions.summary;
    await trayManager.setToolTip(summary == null ? AppIdentity.displayName : '${AppIdentity.displayName} · $summary');
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show', label: l10n.trayShow),
      MenuItem.separator(),
      // 현재 모드에 체크 표시. 눌러서 그 모드로 바꾼다.
      for (final name in _modeActions.names)
        MenuItem.checkbox(key: '$_modeKeyPrefix$name', label: name, checked: name == current),
      if (_modeActions.names.isNotEmpty) MenuItem.separator(),
      MenuItem(key: 'exit', label: l10n.trayExit),
    ]));
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.restore();
    await windowManager.focus();
  }

  @override
  void onWindowClose() => windowManager.hide();

  @override
  void onTrayIconMouseDown() => _showWindow();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        _showWindow();
      case final key? when key.startsWith(_modeKeyPrefix):
        _modeActions.apply?.call(key.substring(_modeKeyPrefix.length));
      case 'exit':
        () async {
          await trayManager.destroy();
          await windowManager.destroy();
        }();
    }
  }

  void _showAbout() {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    final l10n = AppLocalizations.of(context);
    showAppAboutDialog(
      context,
      tagline: l10n.aboutTagline,
      description: l10n.aboutDescription,
      onCheckForUpdates: widget.updates == null ? null : () => widget.updates!.checkManually(context),
    );
  }

  void _checkForUpdates() {
    final context = _navigatorKey.currentContext;
    if (context != null) widget.updates?.checkManually(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: widget.settings,
      child: ListenableBuilder(
        listenable: widget.settings,
        builder: (context, _) => MaterialApp(
          navigatorKey: _navigatorKey,
          title: AppIdentity.displayName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(dense: _isDesktop),
          darkTheme: AppTheme.dark(dense: _isDesktop),
          themeMode: widget.settings.themeMode,
          locale: widget.settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: AppSettings.resolveLocale,
          builder: (context, child) => AppMenuBar(
            onAbout: _showAbout,
            onCheckForUpdates: widget.updates == null ? null : _checkForUpdates,
            child: child!,
          ),
          home: HomePage(
            onAbout: _showAbout,
            catalog: widget.catalog,
            modeActions: _modeActions,
            applyDefaultModeAtStart: widget.startedInBackground,
          ),
        ),
      ),
    );
  }
}
