import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'category_dialog.dart';
import 'help_dialog.dart';
import 'l10n/app_localizations.dart';
import 'mode_actions.dart';
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
  const HomePage({super.key, required this.onAbout, this.modeActions});

  final VoidCallback onAbout;

  /// 트레이 메뉴 같은 바깥에서 뱅킹/개발 모드를 부를 수 있게 연결한다.
  final ModeActions? modeActions;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WatchData _data = WatchData(categories: const [], items: const []);
  // null = 전체, _uncategorized = 카테고리가 없는 항목, 그 밖에는 카테고리 이름.
  String? _filter;
  static const _uncategorized = '\u0000uncategorized';
  List<SvcInfo> _all = [];
  List<SvcRow> _rows = [];
  final List<String> _log = [];
  bool _busy = false;
  bool _admin = true;
  bool _loaded = false;
  double? _logHeight;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    widget.modeActions
      ?..banking = _bankingMode
      ..dev = _devMode;
    _init();
  }

  @override
  void dispose() {
    widget.modeActions
      ?..banking = null
      ..dev = null;
    super.dispose();
  }

  Future<void> _init() async {
    // initState 안에서는 context 로 로케일을 읽을 수 없어 한 프레임 미룬다.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final l = _l10n;
    _data = await WatchStore.load(legacyGroups: {
      'A': l.catDefaultA,
      'B': l.catDefaultB,
      'C': l.catDefaultC,
    });
    _admin = await ServiceManager.isAdmin();
    await _refresh();
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
        _busy = false;
        _loaded = true;
      });
    }
  }

  /// 시작 유형을 Manual 로 맞춘 뒤 시작하고 실제 상태를 검증.
  Future<void> _turnOn(SvcRow r) async {
    final s = r.svc;
    if (s == null) return;
    if (s.startMode == 'Disabled') {
      final c = await ServiceManager.setStartMode(s.name, 'demand');
      if (!mounted) return;
      _logResult(s.name, c);
      if (!c.ok) return;
    }
    final res = await ServiceManager.start(s.name);
    if (mounted) _logResult(s.name, res, withStatus: true);
  }

  Future<void> _turnOff(SvcRow r) async {
    final s = r.svc;
    if (s == null) return;
    final res = await ServiceManager.stop(s.name);
    if (mounted) _logResult(s.name, res, withStatus: true);
  }

  /// 지금 필터에 보이는 항목.
  List<SvcRow> get _visible => switch (_filter) {
        null => _rows,
        _uncategorized => [for (final r in _rows) if (r.item.categories.isEmpty) r],
        final c => [for (final r in _rows) if (r.item.categories.contains(c)) r],
      };

  String get _scopeLabel => switch (_filter) {
        null => _l10n.catAll,
        _uncategorized => _l10n.catUncategorized,
        final c => c,
      };

  Future<void> _runRows(List<SvcRow> rows, Future<void> Function(SvcRow) op) async {
    setState(() => _busy = true);
    for (final r in rows) {
      if (r.svc != null) await op(r);
    }
    await _refresh();
  }

  /// 뱅킹 모드: 뱅킹용으로 정한 카테고리의 서비스를 켠다.
  Future<void> _bankingMode() async {
    if (_busy) return;
    final rows = [for (final r in _rows) if (_data.isInBankingMode(r.item)) r];
    _addLog(_l10n.logModeBanking(rows.length));
    await _runRows(rows, _turnOn);
  }

  /// 개발 모드: 감시 중인 서비스를 모두 끈다.
  Future<void> _devMode() async {
    if (_busy) return;
    _addLog(_l10n.logModeDev(_rows.length));
    await _runRows(_rows, _turnOff);
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
      items[index] = result;
    } else {
      items.add(result);
    }
    await WatchStore.save(_data);
    await _refresh();
  }

  Future<void> _remove(SvcRow r) async {
    _data.items.removeWhere((e) => e.name == r.item.name);
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
                  Tooltip(
                    message: l.bankingModeTooltip,
                    child: FilledButton.icon(
                      onPressed: _busy || _rows.isEmpty ? null : _bankingMode,
                      icon: const Icon(Icons.account_balance_rounded),
                      label: Text(l.bankingModeButton),
                    ),
                  ),
                  Tooltip(
                    message: l.devModeTooltip,
                    child: OutlinedButton.icon(
                      onPressed: _busy || _rows.isEmpty ? null : _devMode,
                      icon: const Icon(Icons.code_rounded),
                      label: Text(l.devModeButton),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
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
                            ? Center(child: Text(l.catEmptyFilter, style: theme.textTheme.bodyMedium))
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
          FilledButton(onPressed: _busy ? null : _addDialog, child: Text(l.homeEmptyAction)),
        ]),
      );

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
