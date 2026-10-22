import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'catalog/catalog.dart';
import 'catalog/catalog_controller.dart';
import 'catalog/catalog_dialog.dart';
import 'catalog/discovery.dart';
import 'catalog/heuristics.dart';
import 'catalog/installed.dart';
import 'catalog/search_button.dart';
import 'catalog/seen_state.dart';
import 'catalog/setup_dialog.dart';
import 'category_dialog.dart';
import 'help_dialog.dart';
import 'l10n/app_localizations.dart';
import 'list_search.dart';
import 'mode_actions.dart';
import 'mode_dialog.dart';
import 'mode_engine.dart';
import 'mode_plan_dialog.dart';
import 'service_manager.dart';
import 'settings/app_settings.dart';
import 'settings/settings_menus.dart';
import 'startup_manager.dart';
import 'theme/app_theme.dart';
import 'watch_item.dart';
import 'window/focus_tint.dart';

/// 감시 항목 + 실제 서비스 조회 결과.
class SvcRow {
  final WatchItem item;
  final SvcInfo? svc;
  final bool msconfigOff;
  const SvcRow(this.item, this.svc, this.msconfigOff);
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onAbout,
    required this.catalog,
    this.modeActions,
    this.applyDefaultModeAtStart = false,
  });

  final VoidCallback onAbout;

  /// 보안 서비스 카탈로그 (이 PC에서 새로 발견한 서비스·이름 변경을 제안하는 근거).
  final CatalogController catalog;

  /// 트레이 메뉴 같은 바깥에서 모드를 바꾸고 상태를 알 수 있게 연결한다.
  final ModeActions? modeActions;

  /// 시작프로그램(--background)으로 떴을 때: 목록을 읽은 뒤 기본 모드를 적용한다.
  final bool applyDefaultModeAtStart;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WatchData _data = WatchData(categories: const [], items: const []);
  // null = 전체, _uncategorized = 카테고리가 없는 항목, 그 밖에는 카테고리 이름.
  String? _filter;
  final TextEditingController _search = TextEditingController();
  static const _uncategorized = '\u0000uncategorized';
  List<SvcInfo> _all = [];
  List<SvcRow> _rows = [];
  final List<String> _log = [];
  bool _busy = false;
  bool _admin = true;
  bool _loaded = false;
  int _suggestions = 0; // 카탈로그가 제안하는 개수 (배지)
  int _newSuspects = 0; // 새로 생긴 서비스 중 보안 프로그램처럼 보이는 것 (배지)
  SeenState _seen = SeenState();
  final SignerCache _signers = SignerCache();
  Timer? _rescanTimer;
  double? _logHeight;

  // ── 모드 ──
  ModeStatus _status = const ModeStatus();
  bool _switching = false;
  String? _lastMode; // 마지막으로 적용한 모드 (여러 모드가 동시에 맞을 때 우선)
  Timer? _revertTimer;
  Timer? _warnTimer;
  Timer? _tickTimer;
  DateTime? _revertAt;
  String? _revertFrom; // 자동 복귀 타이머가 걸린 모드
  BuildContext? _warnContext;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    widget.modeActions?.apply = (name) => _applyMode(name);
    widget.catalog.addListener(_onCatalogChanged);
    // 상주하는 동안 새로 설치된 서비스를 알아채도록 30분마다 다시 읽는다 (바쁠 때는 건너뛴다).
    _rescanTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (mounted && !_busy && !_switching) _refresh();
    });
    _init();
  }

  @override
  void dispose() {
    _rescanTimer?.cancel();
    _search.dispose();
    widget.catalog.removeListener(_onCatalogChanged);
    _cancelRevert(closeDialog: false);
    widget.modeActions?.detach();
    super.dispose();
  }

  Future<void> _init() async {
    // initState 안에서는 context 로 로케일을 읽을 수 없어 한 프레임 미룬다.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final l = _l10n;
    // 저장된 목록이 없으면 새로 설치한 것이다 (첫 실행 마법사 대상).
    final firstRun = !await WatchStore.hasSaved();
    _data = await WatchStore.load(
      defaults: WatchDefaults(
        groupA: l.catDefaultA,
        groupB: l.catDefaultB,
        groupC: l.catDefaultC,
        bankingMode: l.modeDefaultBanking,
        devMode: l.modeDefaultDev,
      ),
    );
    _seen = await SeenStore.load();
    _admin = await ServiceManager.isAdmin();
    await _refresh();
    // 로그온 때 자동 시작(창 없음)으로 처음 뜬 것이면 마법사를 미루고, 사용자가 창을 연 첫 실행에 보여 준다.
    if (mounted && firstRun && !widget.applyDefaultModeAtStart) await _firstRun();
    // 로그온 때 자동 시작이면 PC가 늘 같은 상태(기본 모드)에서 출발하게 한다.
    final start = _data.defaultMode;
    if (mounted && widget.applyDefaultModeAtStart && _admin && start != null) {
      _addLog(_l10n.logModeStartup(start));
      await _applyMode(start, confirm: false); // 무인 실행이라 묻지 않는다.
    }
  }

  void _addLog(String s) {
    final t = TimeOfDay.now();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    setState(() => _log.insert(0, '[$hh:$mm] $s'));
  }

  void _logResult(String name, OpResult r, {bool withStatus = false}) {
    final l = _l10n;
    final status = withStatus ? '${r.ok ? l.logOk : l.logFail} - ' : '';
    _addLog(l.logLine(name, '$status${r.text(l)}'));
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      _all = await ServiceManager.listAll();
      final off = await ServiceManager.msconfigDisabled();
      _rows = [
        for (final it in _data.items)
          () {
            final s = ServiceManager.match(it, _all);
            return SvcRow(it, s, s != null && off.contains(s.name.toLowerCase()));
          }()
      ];
    } catch (e) {
      if (mounted) _addLog(_l10n.logQueryError('$e'));
    }
    if (mounted) {
      setState(() {
        _busy = _switching; // 모드 전환 중에는 잠금을 풀지 않는다.
        _loaded = true;
        _updateStatus();
      });
      _updateAlerts(); // 새로 생긴 서비스를 살핀다 (기다리지 않는다).
    }
  }

  /// 첫 실행 마법사: 이 PC에서 찾은 보안 서비스로 목록과 모드를 만든다.
  /// 건너뛰어도 빈 목록을 저장해 다시 묻지 않는다 (지구본 아이콘에서 같은 일을 할 수 있다).
  Future<void> _firstRun() async {
    final result = await showSetupDialog(
      context,
      catalog: widget.catalog,
      data: _data,
      services: _all,
      signers: _signers,
    );
    if (!mounted) return;
    if (result != null) setState(() => _data = result);
    await WatchStore.save(_data);
    await _refresh();
  }

  /// 지난번에 본 서비스와 견줘 새로 생긴 것을 찾고, 그중 보안 프로그램처럼 보이는 것을 센다 (배지·트레이).
  /// 첫 실행에는 지금 있는 서비스를 기준선으로만 삼고 알리지 않는다.
  Future<void> _updateAlerts() async {
    if (_all.isEmpty) return;
    final names = [for (final s in _all) s.name];
    if (!_seen.initialized) {
      _seen.markSeen(names);
      await SeenStore.save(_seen);
      return;
    }
    final fresh = _seen.newNames(names);
    var count = 0;
    if (fresh.isNotEmpty) {
      final catalog = widget.catalog.catalog;
      // 서명자는 새로 생긴 서비스만 조사한다 (조사한 파일은 캐시에서 쓴다).
      final installed = await loadInstalled(_all, catalog, cache: _signers, withSigners: true, signerFor: fresh);
      if (!mounted) return;
      final skip = <String>{
        ..._seen.ignored,
        for (final h in findHits(catalog, installed)) h.service.name.toLowerCase(),
        for (final s in installed)
          if (_data.items.any((i) => itemCovers(i, s))) s.name.toLowerCase(),
      };
      count = findSuspects(
        Heuristics.defaults.merge(catalog.heuristics),
        [for (final s in installed) if (fresh.contains(s.name.toLowerCase())) s],
        skip: skip,
      ).length;
    }
    if (!mounted) return;
    setState(() {
      _newSuspects = count;
      _publishModes();
    });
  }

  /// 시작 유형을 Manual 로 맞춘 뒤 시작하고 실제 상태를 검증.
  Future<bool> _turnOn(SvcRow r) async {
    final s = r.svc;
    if (s == null) return false;
    if (s.startMode == 'Disabled') {
      final c = await ServiceManager.setStartMode(s.name, 'demand');
      if (!mounted) return false;
      _logResult(s.name, c);
      if (!c.ok) return false;
    }
    final res = await ServiceManager.start(s.name);
    if (mounted) _logResult(s.name, res, withStatus: true);
    return res.ok;
  }

  Future<bool> _turnOff(SvcRow r) async {
    final s = r.svc;
    if (s == null) return false;
    final res = await ServiceManager.stop(s.name);
    if (mounted) _logResult(s.name, res, withStatus: true);
    return res.ok;
  }

  /// 지금 카테고리 필터와 검색어에 맞는 항목. 검색은 이름·표시 이름·메모·카테고리를 본다 (대소문자 무시).
  List<SvcRow> get _visible {
    final byCategory = switch (_filter) {
      null => _rows,
      _uncategorized => [for (final r in _rows) if (r.item.categories.isEmpty) r],
      final c => [for (final r in _rows) if (r.item.categories.contains(c)) r],
    };
    return [
      for (final r in byCategory)
        if (matchesSearch(
          _search.text,
          name: r.item.name,
          displayName: r.svc?.displayName ?? '',
          note: r.item.note,
          categories: r.item.categories,
        ))
          r,
    ];
  }

  String get _scopeLabel => _search.text.trim().isNotEmpty
      ? _l10n.searchResultsLabel
      : switch (_filter) {
          null => _l10n.catAll,
          _uncategorized => _l10n.catUncategorized,
          final c => c,
        };

  Future<void> _runRows(List<SvcRow> rows, Future<bool> Function(SvcRow) op) async {
    setState(() => _busy = true);
    for (final r in rows) {
      if (r.svc != null) await op(r);
    }
    await _refresh();
  }

  // ── 모드 ─────────────────────────────────────────────────

  List<ItemState> get _states => [for (final r in _rows) ItemState(r.item, r.svc?.running)];

  /// 서비스의 실제 상태로 현재 모드를 다시 판정하고, 트레이 쪽에도 알린다.
  void _onCatalogChanged() {
    if (!mounted) return;
    setState(() {
      _suggestions = suggestionCount(widget.catalog.catalog, _data, _all);
      _publishModes();
    });
    _updateAlerts();
  }

  Future<void> _openCatalog() async {
    final result = await showCatalogDialog(
      context,
      controller: widget.catalog,
      data: _data,
      services: _all,
      seen: _seen,
      signers: _signers,
      onSeenChanged: SeenStore.save,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _data = result);
      await WatchStore.save(_data);
      await _refresh();
    } else {
      _updateAlerts(); // 창을 열어 본 것으로 새 서비스 배지가 꺼진다.
    }
  }

  void _updateStatus() {
    _suggestions = suggestionCount(widget.catalog.catalog, _data, _all);
    _status = detect(_data, _states, preferred: _lastMode);
    final cur = _status.current;
    // 자동 복귀 타이머는 그 모드에 머무는 동안만 의미가 있다.
    if (cur == null || cur.name != _revertFrom) _cancelRevert();
    _publishModes();
  }

  /// 트레이 쪽(메뉴·툴팁)에 모드와 알림 개수를 알린다.
  void _publishModes() {
    widget.modeActions?.update(
      names: [for (final m in _data.modes) m.name],
      current: _status.current?.name,
      summary: _statusText(_l10n),
      alerts: _suggestions + _newSuspects,
    );
  }

  String _statusText(AppLocalizations l) {
    final cur = _status.current;
    if (cur != null) return l.modeCurrent(cur.name);
    final c = _status.closest;
    if (c == null) return l.modeUnknown;
    return l.modeMixed(c.name, _status.closestProgress.ok, _status.closestProgress.total);
  }

  /// 이름의 모드로 바꾼다: 계획 → 끄기(거꾸로) → 켜기 → 실제 상태 검증 → 보고.
  /// 혼합일 때 다시 부르면 아직 맞지 않은 서비스만 다시 시도한다.
  /// [confirm]이 true(사람이 누른 경우)면 실행 전에 계획을 보여 주고 확인을 받는다.
  /// 시작 시 기본 모드·자동 복귀는 사람이 없어도 돌아야 하므로 false 로 부른다.
  Future<void> _applyMode(String name, {bool confirm = true}) async {
    if (_busy || _switching) return;
    final mode = _data.modeNamed(name);
    if (mode == null) return;
    final l = _l10n;
    setState(() {
      _switching = true;
      _busy = true;
    });
    await _refresh(); // 계획은 방금 읽은 실제 상태로 세운다.
    if (!mounted) return;
    final plan = planFor(mode, _states);
    final byName = {for (final r in _rows) r.item.name: r};
    if (plan.isEmpty) {
      _addLog(l.logModeAlready(name));
    } else {
      if (confirm && !await _confirmPlan(name, plan, byName)) {
        if (!mounted) return;
        _addLog(l.logModeCancelled(name));
        setState(() {
          _switching = false;
          _busy = false;
        });
        return;
      }
      if (!mounted) return;
      _addLog(l.logModePlan(name, plan.start.length, plan.stop.length));
      for (final it in plan.stop) {
        await _turnOff(byName[it.name]!);
      }
      for (final it in plan.start) {
        await _turnOn(byName[it.name]!);
      }
    }
    _lastMode = name;
    await _refresh();
    if (!mounted) return;
    setState(() => _switching = false);
    final cur = _status.current;
    if (cur?.name == name) {
      if (!plan.isEmpty) _addLog(l.logModeDone(name));
      _scheduleRevert(mode);
    } else {
      _addLog(l.logModePartial(name, _status.closestProgress.ok, _status.closestProgress.total));
    }
    setState(() => _busy = false);
  }

  /// 드라이런: 바꾸기 전에 무엇을 끄고 켤지 보여 주고 실행/취소를 묻는다.
  Future<bool> _confirmPlan(String name, ModePlan plan, Map<String, SvcRow> byName) async {
    final l = _l10n;
    // 트레이에서 눌렀다면 창이 숨어 있을 수 있다.
    await windowManager.show();
    await windowManager.focus();
    if (!mounted) return false;
    PlanLine line(WatchItem it, {required bool starting}) {
      final svc = byName[it.name]?.svc;
      final title = svc == null || svc.displayName.isEmpty ? it.name : svc.displayName;
      String? note;
      if (starting && svc?.startMode == 'Disabled') note = l.planEnableNote;
      if (!starting && svc?.startMode == 'Auto') note = l.planAutoNote;
      return PlanLine(title, note: note);
    }

    final touched = plan.total;
    final installed = _rows.where((r) => r.svc != null).length;
    return showModePlanDialog(
      context,
      modeName: name,
      stop: [for (final it in plan.stop) line(it, starting: false)],
      start: [for (final it in plan.start) line(it, starting: true)],
      unchanged: installed - touched,
    );
  }

  // ── 자동 복귀 ──

  void _cancelRevert({bool closeDialog = true}) {
    _revertTimer?.cancel();
    _warnTimer?.cancel();
    _tickTimer?.cancel();
    _revertTimer = _warnTimer = _tickTimer = null;
    _revertAt = null;
    _revertFrom = null;
    final ctx = _warnContext;
    if (closeDialog && ctx != null && ctx.mounted) Navigator.of(ctx).pop();
    _warnContext = null;
  }

  /// [mode]에 머무는 시간이 정해져 있으면 기본 모드로 돌아갈 타이머를 건다.
  void _scheduleRevert(WatchMode mode, {int? minutes}) {
    _cancelRevert();
    final back = _data.defaultMode;
    final mins = minutes ?? mode.revertMinutes;
    if (mins <= 0 || back == null || back == mode.name) return;
    final total = Duration(minutes: mins);
    _revertFrom = mode.name;
    _revertAt = DateTime.now().add(total);
    _revertTimer = Timer(total, () => _revertNow(mode.name));
    if (total > const Duration(minutes: 1)) {
      _warnTimer = Timer(total - const Duration(minutes: 1), () => _warnRevert(mode, mins));
    }
    // 남은 시간 표시를 분 단위로 갱신한다.
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
    if (mounted) setState(() {});
  }

  Future<void> _revertNow(String from) async {
    final back = _data.defaultMode;
    if (!mounted || back == null || _revertFrom != from) return;
    _addLog(_l10n.logModeRevert(back));
    _cancelRevert();
    await _applyMode(back, confirm: false); // 알림에서 이미 물었다.
  }

  /// 1분 전 알림: 창을 앞으로 가져와 연장하거나 지금 돌아갈지 묻는다.
  Future<void> _warnRevert(WatchMode mode, int mins) async {
    final back = _data.defaultMode;
    if (!mounted || back == null || _revertFrom != mode.name) return;
    await windowManager.show();
    await windowManager.focus();
    if (!mounted) return;
    final l = _l10n;
    final answer = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _warnContext = ctx;
        return AlertDialog(
          title: Text(l.revertWarnTitle(back)),
          content: Text(l.revertWarnBody(mode.name, mins, back)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, 'now'), child: Text(l.revertNow)),
            FilledButton(onPressed: () => Navigator.pop(ctx, 'extend'), child: Text(l.revertExtend(mins))),
          ],
        );
      },
    );
    _warnContext = null;
    if (!mounted || _revertFrom != mode.name) return; // 그 사이 모드가 바뀌었거나 복귀가 끝났다.
    if (answer == 'extend') {
      _scheduleRevert(mode, minutes: mins);
    } else if (answer == 'now') {
      await _revertNow(mode.name);
    }
  }

  Future<void> _manageModes() async {
    final result = await showModeManager(
      context,
      _data,
      running: {for (final r in _rows) r.item.name.toLowerCase(): r.svc?.running},
    );
    if (result == null) return;
    setState(() {
      _data = result;
      _updateStatus();
    });
    await WatchStore.save(_data);
  }

  Future<void> _manageCategories() async {
    final result = await showCategoryManager(context, _data);
    if (result == null) return;
    setState(() {
      _data = result;
      if (_filter != null && _filter != _uncategorized && !_data.categories.contains(_filter)) {
        _filter = null;
      }
    });
    await WatchStore.save(_data);
    await _refresh();
  }

  Future<void> _runOne(Future<void> Function(SvcRow) op, SvcRow r) async {
    setState(() => _busy = true);
    await op(r);
    await _refresh();
  }

  Future<void> _setMode(SvcRow r, String mode) async {
    final s = r.svc;
    if (s == null) return;
    setState(() => _busy = true);
    final res = await ServiceManager.setStartMode(s.name, mode);
    if (mounted) _logResult(s.name, res);
    await _refresh();
  }

  /// [edit]이 있으면 그 항목의 이름·분류를 고친다 (오타 수정 등).
  Future<void> _addDialog({SvcRow? edit}) async {
    final l = _l10n;
    final nameCtl = TextEditingController(text: edit?.item.name ?? '');
    final newCatCtl = TextEditingController();
    // 새로 만든 카테고리는 저장할 때 목록에 더한다.
    final extra = <String>[];
    final selected = <String>{
      if (edit != null)
        ...edit.item.categories
      else if (_filter != null && _filter != _uncategorized)
        _filter!,
    };
    final result = await showDialog<WatchItem>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final q = nameCtl.text.trim().toLowerCase();
          final hits = q.isEmpty
              ? <SvcInfo>[]
              : _all
                  .where((s) =>
                      s.name.toLowerCase().contains(q) ||
                      s.displayName.toLowerCase().contains(q))
                  .take(8)
                  .toList();
          return AlertDialog(
            title: Text(edit == null ? l.addDialogTitle : l.editDialogTitle),
            content: SizedBox(
              width: 460,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: nameCtl,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l.addDialogField),
                  onChanged: (_) => setD(() {}),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l.addDialogCategories, style: Theme.of(ctx).textTheme.labelLarge),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(spacing: AppSpacing.sm, children: [
                    for (final c in [..._data.categories, ...extra])
                      FilterChip(
                        label: Text(c, style: AppFonts.userContent),
                        selected: selected.contains(c),
                        onSelected: (on) => setD(() => on ? selected.add(c) : selected.remove(c)),
                      ),
                  ]),
                ),
                TextField(
                  controller: newCatCtl,
                  decoration: InputDecoration(
                    labelText: l.addDialogNewCategory,
                    suffixIcon: IconButton(
                      tooltip: l.commonAdd,
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () {
                        final n = newCatCtl.text.trim();
                        if (n.isEmpty) return;
                        setD(() {
                          if (!_data.categories.contains(n) && !extra.contains(n)) extra.add(n);
                          selected.add(n);
                          newCatCtl.clear();
                        });
                      },
                    ),
                  ),
                ),
                for (final s in hits)
                  ListTile(
                    dense: true,
                    title: Text(s.displayName, style: AppFonts.userContent),
                    subtitle: Text('${s.name} · ${s.state}', style: AppFonts.userContent),
                    onTap: () => setD(() => nameCtl.text = s.name),
                  ),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.commonCancel)),
              FilledButton(
                onPressed: () {
                  final n = nameCtl.text.trim();
                  if (n.isNotEmpty) {
                    // 입력칸에 쓰다 만 새 카테고리도 놓치지 않는다.
                    final pending = newCatCtl.text.trim();
                    if (pending.isNotEmpty) {
                      if (!_data.categories.contains(pending) && !extra.contains(pending)) extra.add(pending);
                      selected.add(pending);
                    }
                    final ordered = [..._data.categories, ...extra].where(selected.contains).toList();
                    Navigator.pop(ctx, WatchItem(n, categories: ordered, note: edit?.item.note ?? ''));
                  }
                },
                child: Text(edit == null ? l.commonAdd : l.commonSave),
              ),
            ],
          );
        },
      ),
    );
    if (result == null) return;
    final items = _data.items;
    final index = edit == null ? -1 : items.indexWhere((e) => e.name == edit.item.name);
    if (items.asMap().entries.any(
        (e) => e.key != index && e.value.name.toLowerCase() == result.name.toLowerCase())) {
      _addLog(l.logAlreadyInList(result.name));
      return;
    }
    for (final c in result.categories) {
      _data.addCategory(c);
    }
    if (index >= 0) {
      // 이름이 바뀌면 모드에서 그 서비스에 직접 정한 동작도 따라가야 하므로 renameItem 을 거친다.
      _data.renameItem(edit!.item.name, result.name);
      final k = _data.items.indexWhere((e) => e.name == result.name);
      if (k >= 0) items[k] = result;
    } else {
      items.add(result);
    }
    await WatchStore.save(_data);
    await _refresh();
  }

  Future<void> _remove(SvcRow r) async {
    _data.removeItem(r.item.name);
    await WatchStore.save(_data);
    await _refresh();
  }

  /// 아이콘 색: 다크는 밝은 의미색, 라이트는 대비를 확보한 짙은 변형.
  Color _tone(Color dark, Color light) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  Color get _runColor => _tone(AppColors.success, AppColors.successTextLight);
  Color get _stopColor => _tone(AppColors.danger, AppColors.dangerTextLight);
  Color get _editColor => _tone(AppColors.primary, AppColors.primaryDeep);
  Color get _toolColor => _tone(AppColors.warning, AppColors.warningTextLight);

  Color _stateColor(SvcInfo? s) {
    if (s == null) return AppColors.textLow;
    return s.running ? AppColors.success : AppColors.warning;
  }

  String _startModeLabel(String mode) {
    final l = _l10n;
    return switch (mode) {
      'Auto' => l.startModeAuto,
      'Manual' => l.startModeManual,
      'Disabled' => l.startModeDisabled,
      _ => mode,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = _l10n;
    final theme = Theme.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f5): () {
          if (!_busy) _refresh();
        },
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () {
          if (!_busy) _refresh();
        },
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (!_busy) _addDialog();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: const FocusTint(),
            title: const Text('Bank Service Killer'),
            actions: [
              IconButton(
                tooltip: l.refreshTooltip,
                onPressed: _busy ? null : _refresh,
                icon: Icon(Icons.refresh_rounded, color: _editColor),
              ),
              IconButton(
                tooltip: l.addServiceTooltip,
                onPressed: _busy ? null : _addDialog,
                icon: Icon(Icons.add_rounded, color: _runColor),
              ),
              PopupMenuButton<String>(
                tooltip: l.systemToolsTooltip,
                icon: Icon(Icons.settings_applications_outlined, color: _toolColor),
                onSelected: (tool) => Process.start(
                  tool == 'msconfig' ? 'msconfig.exe' : 'mmc.exe',
                  // -3 = 서비스 탭
                  tool == 'msconfig' ? ['-3'] : ['services.msc'],
                  mode: ProcessStartMode.detached,
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'msconfig', child: Text(l.openMsconfig)),
                  PopupMenuItem(value: 'services', child: Text(l.openServicesMsc)),
                ],
              ),
              IconButton(
                tooltip: _suggestions + _newSuspects > 0
                    ? l.catalogTooltipCount(_suggestions + _newSuspects)
                    : l.catalogTooltip,
                onPressed: _busy ? null : _openCatalog,
                icon: Badge(
                  isLabelVisible: _suggestions + _newSuspects > 0,
                  label: Text('${_suggestions + _newSuspects}'),
                  child: Icon(Icons.travel_explore_rounded, color: _toolColor),
                ),
              ),
              IconButton(
                tooltip: l.helpTooltip,
                icon: const Icon(Icons.help_outline_rounded, color: AppColors.accent),
                onPressed: () => showHelpDialog(context),
              ),
              const StartupMenuButton(),
              const ThemeMenuButton(),
              const LanguageMenuButton(),
              IconButton(
                tooltip: l.aboutTooltip,
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: widget.onAbout,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            bottom: _busy
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(3), child: LinearProgressIndicator())
                : null,
          ),
          body: Column(children: [
            if (!_admin)
              MaterialBanner(
                content: Text(l.adminWarning),
                leading: const Icon(Icons.shield_outlined),
                actions: const [SizedBox.shrink()],
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _modeToggle(l),
                  IconButton(
                    tooltip: l.modeManageTooltip,
                    onPressed: _busy ? null : _manageModes,
                    icon: Icon(Icons.tune_rounded, color: _editColor),
                  ),
                  _modeStatus(l, theme),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 240,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: l.listSearchHint,
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l.listSearchClear,
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () => setState(_search.clear),
                              ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _busy || _visible.isEmpty ? null : () => _runRows(_visible, _turnOn),
                    icon: Icon(Icons.play_arrow_rounded, color: _runColor),
                    label: Text(l.scopeTurnOn(_scopeLabel), style: AppFonts.userContent),
                  ),
                  TextButton.icon(
                    onPressed: _busy || _visible.isEmpty ? null : () => _runRows(_visible, _turnOff),
                    icon: Icon(Icons.stop_rounded, color: _stopColor),
                    label: Text(l.scopeTurnOff(_scopeLabel), style: AppFonts.userContent),
                  ),
                ],
              ),
            ),
            _categoryBar(l),
            Expanded(
              child: LayoutBuilder(builder: (context, c) {
                // 목록·로그 모두 최소 높이를 남긴다.
                const minList = 120.0, minLog = 64.0, handle = 10.0;
                final maxLog = (c.maxHeight - minList - handle).clamp(minLog, double.infinity);
                final logH = (_logHeight ?? AppSettingsScope.of(context).logHeight ?? 150.0)
                    .clamp(minLog, maxLog);
                return Column(children: [
                  Expanded(
                    child: _loaded && _rows.isEmpty
                        ? _emptyState(l, theme)
                        : _visible.isEmpty
                            ? Center(
                                child: Text(
                                  _search.text.trim().isNotEmpty ? l.searchNoResults : l.catEmptyFilter,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            : _list(l, theme, _visible),
                  ),
                  Tooltip(
                    message: l.logResizeTooltip,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeRow,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: (d) =>
                            setState(() => _logHeight = (logH - d.delta.dy).clamp(minLog, maxLog)),
                        onVerticalDragEnd: (_) {
                          if (_logHeight != null) AppSettingsScope.of(context).setLogHeight(_logHeight!);
                        },
                        child: SizedBox(
                          height: handle,
                          child: Center(child: Divider(height: 1, color: theme.dividerColor)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: logH,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
                        child: Text(l.logTitle, style: theme.textTheme.labelLarge),
                      ),
                      Expanded(
                        child: _log.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: Text(l.logEmpty, style: theme.textTheme.bodySmall),
                              )
                            : ListView(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                children: [
                                  for (final line in _log)
                                    Text(line, style: AppFonts.mono.copyWith(fontSize: 12)),
                                ],
                              ),
                      ),
                    ]),
                  ),
                ]);
              }),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _emptyState(AppLocalizations l, ThemeData theme) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.shield_outlined, size: 48),
          const SizedBox(height: AppSpacing.lg),
          Text(l.homeEmptyTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: _busy ? null : _openCatalog, child: Text(l.emptyFind)),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: _busy ? null : _addDialog, child: Text(l.homeEmptyAction)),
        ]),
      );

  /// [뱅킹 | 개발 | …] 토글. 현재 모드가 눌려 보이고, 혼합이면 아무것도 눌려 있지 않다.
  Widget _modeToggle(AppLocalizations l) {
    final cur = _status.current?.name;
    return SegmentedButton<String>(
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      segments: [
        for (final m in _data.modes)
          ButtonSegment(
            value: m.name,
            tooltip: l.modeToggleTooltip(m.name),
            label: Text(m.name, style: AppFonts.userContent),
          ),
      ],
      selected: {if (cur != null) cur},
      // 눌린 모드를 다시 누르면 빈 선택이 오는데, 그때도 그 모드를 다시 맞춘다.
      onSelectionChanged: _busy || _rows.isEmpty
          ? null
          : (sel) {
              final target = sel.isNotEmpty ? sel.first : cur;
              if (target != null) _applyMode(target);
            },
    );
  }

  /// "현재 모드: 뱅킹" / "혼합 상태 · 뱅킹 7/9" + 자동 복귀까지 남은 시간.
  Widget _modeStatus(AppLocalizations l, ThemeData theme) {
    final at = _revertAt;
    final back = _data.defaultMode;
    String? revert;
    if (at != null && back != null) {
      final left = at.difference(DateTime.now()).inSeconds;
      revert = l.modeRevertIn(left <= 0 ? 0 : (left / 60).ceil(), back);
    }
    final mixed = _status.current == null && _loaded && _status.closest != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          _loaded ? _statusText(l) : l.modeUnknown,
          style: theme.textTheme.labelLarge?.copyWith(color: mixed ? _toolColor : null),
        ),
        if (revert != null) Text(revert, style: theme.textTheme.bodySmall),
      ]),
    );
  }

  /// 카테고리 필터 칩 + 카테고리 관리 단추.
  Widget _categoryBar(AppLocalizations l) {
    Widget chip(String? value, String label, int count) => ChoiceChip(
          label: Text('$label  $count', style: AppFonts.userContent),
          selected: _filter == value,
          onSelected: (_) => setState(() => _filter = value),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.sm, AppSpacing.sm),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.xs, children: [
            chip(null, l.catAll, _data.items.length),
            for (final c in _data.categories) chip(c, c, _data.countIn(c)),
            if (_data.uncategorizedCount > 0)
              chip(_uncategorized, l.catUncategorized, _data.uncategorizedCount),
          ]),
        ),
        IconButton(
          tooltip: l.catManageTooltip,
          onPressed: _busy ? null : _manageCategories,
          icon: Icon(Icons.label_rounded, color: _editColor),
        ),
      ]),
    );
  }

  Widget _list(AppLocalizations l, ThemeData theme, List<SvcRow> rows) => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = rows[i];
          final s = r.svc;
          final small = theme.textTheme.bodySmall;
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(children: [
                Icon(Icons.circle, size: 14, color: _stateColor(s)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        r.item.categories.isEmpty
                            ? r.item.name
                            : '${r.item.name}  [${r.item.categories.join(', ')}]',
                        style: AppFonts.userContent.merge(theme.textTheme.bodyMedium)),
                    const SizedBox(height: 2),
                    Text(
                      s == null
                          ? l.notInstalled
                          : l.serviceSubtitle(
                                  s.displayName, s.state, _startModeLabel(s.startMode)) +
                              (r.msconfigOff ? l.msconfigDisabledNote : ''),
                      style: AppFonts.userContent.merge(small),
                    ),
                    if (r.item.note.isNotEmpty)
                      Text(r.item.note, style: AppFonts.userContent.merge(small)),
                    if (s != null)
                      Text(s.path,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.userContent.merge(small)),
                  ]),
                ),
                if (s != null) ...[
                  DropdownButton<String>(
                    value: const {'Auto': 'auto', 'Manual': 'demand', 'Disabled': 'disabled'}[
                        s.startMode],
                    hint: Text(_startModeLabel(s.startMode)),
                    items: [
                      DropdownMenuItem(value: 'auto', child: Text(l.startModeAuto)),
                      DropdownMenuItem(value: 'demand', child: Text(l.startModeManual)),
                      DropdownMenuItem(value: 'disabled', child: Text(l.startModeDisabled)),
                    ],
                    onChanged: _busy ? null : (v) => v == null ? null : _setMode(r, v),
                  ),
                  IconButton(
                    tooltip: s.running ? l.stopVerifyTooltip : l.startVerifyTooltip,
                    onPressed: _busy ? null : () => _runOne(s.running ? _turnOff : _turnOn, r),
                    icon: Icon(
                      s.running ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                      color: s.running ? _stopColor : _runColor,
                    ),
                  ),
                ],
                ServiceSearchButton(searchTargetFor(svc: s, itemName: r.item.name)),
                IconButton(
                  tooltip: l.editTooltip,
                  onPressed: _busy ? null : () => _addDialog(edit: r),
                  icon: Icon(Icons.edit_rounded, color: _editColor),
                ),
                IconButton(
                  tooltip: l.removeTooltip,
                  onPressed: _busy ? null : () => _remove(r),
                  icon: Icon(Icons.delete_rounded, color: _stopColor),
                ),
              ]),
            ),
          );
        },
      );
}
