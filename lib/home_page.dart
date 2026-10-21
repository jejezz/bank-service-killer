import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'help_dialog.dart';
import 'l10n/app_localizations.dart';
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
  const HomePage({super.key, required this.onAbout});

  final VoidCallback onAbout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WatchItem> _items = [];
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
    _init();
  }

  Future<void> _init() async {
    _items = await WatchStore.load();
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
        for (final it in _items)
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

  Future<void> _runAll(Future<void> Function(SvcRow) op) async {
    setState(() => _busy = true);
    for (final r in _rows) {
      if (r.svc != null) await op(r);
    }
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

  Future<void> _addDialog() async {
    final l = _l10n;
    final nameCtl = TextEditingController();
    String group = 'B';
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
            title: Text(l.addDialogTitle),
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
                DropdownButton<String>(
                  value: group,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'A', child: Text(l.groupA)),
                    DropdownMenuItem(value: 'B', child: Text(l.groupB)),
                    DropdownMenuItem(value: 'C', child: Text(l.groupC)),
                  ],
                  onChanged: (v) => setD(() => group = v ?? 'B'),
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
                  if (n.isNotEmpty) Navigator.pop(ctx, WatchItem(n, group: group));
                },
                child: Text(l.commonAdd),
              ),
            ],
          );
        },
      ),
    );
    if (result == null) return;
    if (_items.any((e) => e.name.toLowerCase() == result.name.toLowerCase())) {
      _addLog(l.logAlreadyInList(result.name));
      return;
    }
    _items.add(result);
    await WatchStore.save(_items);
    await _refresh();
  }

  Future<void> _remove(SvcRow r) async {
    _items.removeWhere((e) => e.name == r.item.name);
    await WatchStore.save(_items);
    await _refresh();
  }

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
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                tooltip: l.addServiceTooltip,
                onPressed: _busy ? null : _addDialog,
                icon: const Icon(Icons.add_rounded),
              ),
              IconButton(
                tooltip: l.helpTooltip,
                icon: const Icon(Icons.help_outline_rounded),
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
              child: Row(children: [
                FilledButton.icon(
                  onPressed: _busy || _rows.isEmpty ? null : () => _runAll(_turnOn),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l.homeTurnOnAll),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _busy || _rows.isEmpty ? null : () => _runAll(_turnOff),
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(l.homeTurnOffAll),
                ),
              ]),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, c) {
                // 목록·로그 모두 최소 높이를 남긴다.
                const minList = 120.0, minLog = 64.0, handle = 10.0;
                final maxLog = (c.maxHeight - minList - handle).clamp(minLog, double.infinity);
                final logH = (_logHeight ?? AppSettingsScope.of(context).logHeight ?? 150.0)
                    .clamp(minLog, maxLog);
                return Column(children: [
                  Expanded(
                    child: _loaded && _rows.isEmpty ? _emptyState(l, theme) : _list(l, theme),
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

  Widget _list(AppLocalizations l, ThemeData theme) => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = _rows[i];
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
                    Text('${r.item.name}  [${r.item.group}]',
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
                    icon: Icon(s.running ? Icons.stop_circle_outlined : Icons.play_circle_outline),
                  ),
                ],
                IconButton(
                  tooltip: l.removeTooltip,
                  onPressed: _busy ? null : () => _remove(r),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ]),
            ),
          );
        },
      );
}
