import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'list_search.dart';
import 'mode_engine.dart';
import 'theme/app_theme.dart';
import 'watch_item.dart';

/// 보이는 서비스를 한꺼번에 정하는 메뉴 항목. (PopupMenu 는 값이 null 이면 "고르지 않음"으로 보므로 지정 풀기도 값이 필요하다.)
enum _Bulk { on, keep, off, clear }

/// 자동 복귀 시간 선택지(분). 0 = 복귀 안 함.
const _revertChoices = [0, 10, 15, 20, 30, 45, 60, 90, 120];

/// 모드 하나를 만들거나 고친다: 이름, 카테고리별 또는 **서비스별** 켜기/그대로/끄기, 자동 복귀.
///
/// - [running]: 서비스 이름(소문자) → 지금 실행 중인지. 값이 null 이면 이 PC에 설치되지 않은 서비스다. 거르기에 쓴다.
/// - 서비스를 직접 정한 값은 카테고리로 정한 값보다 우선한다.
Future<WatchMode?> showModeEditor(
  BuildContext context, {
  required List<String> categories,
  required List<WatchItem> items,
  Map<String, bool?> running = const {},
  WatchMode? mode,
}) {
  return showDialog<WatchMode>(
    context: context,
    builder: (_) => _ModeEditor(categories: categories, items: items, running: running, mode: mode),
  );
}

class _ModeEditor extends StatefulWidget {
  const _ModeEditor({required this.categories, required this.items, required this.running, this.mode});

  final List<String> categories;
  final List<WatchItem> items;
  final Map<String, bool?> running;
  final WatchMode? mode;

  @override
  State<_ModeEditor> createState() => _ModeEditorState();
}

class _ModeEditorState extends State<_ModeEditor> {
  late final TextEditingController _name;
  late final TextEditingController _query;
  late final Map<String, Want> _want; // 카테고리별
  late final Map<String, Want> _svc; // 서비스별 (키: 서비스 이름 소문자)
  late int _revert;

  // 서비스별 탭의 거르기
  bool _onlyInstalled = false;
  bool _onlyRunning = false;
  bool _onlyDirect = false;

  @override
  void initState() {
    super.initState();
    final m = widget.mode;
    _name = TextEditingController(text: m?.name ?? '');
    _query = TextEditingController();
    _want = {
      for (final c in widget.categories)
        c: m == null
            ? Want.off
            : m.on.contains(c)
                ? Want.on
                : m.keep.contains(c)
                    ? Want.keep
                    : Want.off,
    };
    _svc = Map.of(m?.services ?? const {});
    _revert = m?.revertMinutes ?? 0;
  }

  @override
  void dispose() {
    _name.dispose();
    _query.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      WatchMode(
        name,
        on: [for (final c in widget.categories) if (_want[c] == Want.on) c],
        keep: [for (final c in widget.categories) if (_want[c] == Want.keep) c],
        revertMinutes: _revert,
        services: Map.of(_svc),
      ),
    );
  }

  String _wantLabel(AppLocalizations l, Want w) => switch (w) {
        Want.on => l.wantOn,
        Want.keep => l.wantKeep,
        Want.off => l.wantOff,
      };

  /// 카테고리 탭의 선택만으로 정해지는 동작 (서비스 직접 지정을 빼고).
  Want _byCategory(WatchItem item) => wantFor(
        WatchMode(
          'x',
          on: [for (final c in widget.categories) if (_want[c] == Want.on) c],
          keep: [for (final c in widget.categories) if (_want[c] == Want.keep) c],
        ),
        item,
      );

  /// 검색어와 거르기에 맞는 서비스. 검색은 이름·메모·카테고리를 본다 (대소문자 무시).
  List<WatchItem> get _visible {
    return [
      for (final it in widget.items)
        if (matchesSearch(_query.text, name: it.name, note: it.note, categories: it.categories) &&
            (!_onlyInstalled || widget.running[it.name.toLowerCase()] != null) &&
            (!_onlyRunning || widget.running[it.name.toLowerCase()] == true) &&
            (!_onlyDirect || _svc.containsKey(it.name.toLowerCase())))
          it,
    ];
  }

  void _setAll(Iterable<WatchItem> items, Want? w) {
    setState(() {
      for (final it in items) {
        final k = it.name.toLowerCase();
        if (w == null) {
          _svc.remove(k);
        } else {
          _svc[k] = w;
        }
      }
    });
  }

  Widget _categoriesTab(AppLocalizations l, ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Text(l.modeCategoriesHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(children: [
              for (final c in widget.categories)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Expanded(child: Text(c, style: AppFonts.userContent)),
                    SegmentedButton<Want>(
                      showSelectedIcon: false,
                      style: const ButtonStyle(visualDensity: VisualDensity.compact),
                      segments: [
                        ButtonSegment(value: Want.on, label: Text(l.wantOn)),
                        ButtonSegment(value: Want.keep, label: Text(l.wantKeep)),
                        ButtonSegment(value: Want.off, label: Text(l.wantOff)),
                      ],
                      selected: {_want[c]!},
                      onSelectionChanged: (s) => setState(() => _want[c] = s.single),
                    ),
                  ]),
                ),
            ]),
          ),
        ],
      );

  Widget _servicesTab(AppLocalizations l, ThemeData theme) {
    final shown = _visible;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: AppSpacing.sm),
      Text(l.svcTabHint, style: theme.textTheme.bodySmall),
      const SizedBox(height: AppSpacing.sm),
      TextField(
        controller: _query,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: l.svcSearchHint,
          suffixIcon: _query.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => setState(_query.clear),
                ),
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(children: [
        Expanded(
          child: Wrap(spacing: AppSpacing.sm, children: [
            FilterChip(
              label: Text(l.svcFilterInstalled),
              selected: _onlyInstalled,
              onSelected: (v) => setState(() => _onlyInstalled = v),
            ),
            FilterChip(
              label: Text(l.svcFilterRunning),
              selected: _onlyRunning,
              onSelected: (v) => setState(() => _onlyRunning = v),
            ),
            FilterChip(
              label: Text('${l.svcFilterDirect} (${_svc.length})'),
              selected: _onlyDirect,
              onSelected: (v) => setState(() => _onlyDirect = v),
            ),
          ]),
        ),
        PopupMenuButton<_Bulk>(
          tooltip: l.svcBulkTooltip,
          enabled: shown.isNotEmpty,
          onSelected: (b) => _setAll(
            shown,
            switch (b) {
              _Bulk.on => Want.on,
              _Bulk.keep => Want.keep,
              _Bulk.off => Want.off,
              _Bulk.clear => null,
            },
          ),
          itemBuilder: (_) => [
            PopupMenuItem(value: _Bulk.on, child: Text(l.svcBulkSet(l.wantOn))),
            PopupMenuItem(value: _Bulk.keep, child: Text(l.svcBulkSet(l.wantKeep))),
            PopupMenuItem(value: _Bulk.off, child: Text(l.svcBulkSet(l.wantOff))),
            const PopupMenuDivider(),
            PopupMenuItem(value: _Bulk.clear, child: Text(l.svcBulkClear)),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.checklist_rounded, size: 18),
              const SizedBox(width: 4),
              Text(l.svcShown(shown.length)),
              const Icon(Icons.arrow_drop_down_rounded),
            ]),
          ),
        ),
      ]),
      Expanded(
        child: shown.isEmpty
            ? Center(child: Text(l.svcNoResults, style: theme.textTheme.bodyMedium))
            : ListView.builder(
                itemCount: shown.length,
                itemBuilder: (_, i) {
                  final it = shown[i];
                  final key = it.name.toLowerCase();
                  final direct = _svc[key];
                  final installed = widget.running[key] != null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            installed ? it.name : '${it.name}  (${l.notInstalledShort})',
                            style: AppFonts.userContent,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            direct != null
                                ? (it.categories.isEmpty ? l.svcNoCategory : it.categories.join(', '))
                                : '${it.categories.isEmpty ? l.svcNoCategory : it.categories.join(', ')}  ·  '
                                    '${l.svcByCategory(_wantLabel(l, _byCategory(it)))}',
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]),
                      ),
                      SegmentedButton<Want>(
                        emptySelectionAllowed: true,
                        showSelectedIcon: false,
                        style: const ButtonStyle(visualDensity: VisualDensity.compact),
                        segments: [
                          ButtonSegment(value: Want.on, label: Text(l.wantOn)),
                          ButtonSegment(value: Want.keep, label: Text(l.wantKeep)),
                          ButtonSegment(value: Want.off, label: Text(l.wantOff)),
                        ],
                        selected: {if (direct != null) direct},
                        // 눌린 것을 다시 누르면 지정이 풀려 카테고리 기준으로 돌아간다.
                        onSelectionChanged: (s) => _setAll([it], s.isEmpty ? null : s.first),
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final choices = {..._revertChoices, _revert}.toList()..sort();
    return AlertDialog(
      title: Text(widget.mode == null ? l.modeNewTitle : l.modeEditTitle),
      content: SizedBox(
        width: 700,
        height: 540,
        child: DefaultTabController(
          length: 2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: l.modeName),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.sm),
            TabBar(tabs: [Tab(text: l.modeTabCategories), Tab(text: l.modeTabServices)]),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [_categoriesTab(l, theme), _servicesTab(l, theme)],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              Expanded(child: Text(l.modeRevertField, style: theme.textTheme.labelLarge)),
              DropdownButton<int>(
                value: _revert,
                items: [
                  for (final m in choices)
                    DropdownMenuItem(value: m, child: Text(m == 0 ? l.modeRevertOff : l.modeRevertAfter(m))),
                ],
                onChanged: (v) => setState(() => _revert = v ?? 0),
              ),
            ]),
            Text(l.modeRevertHint, style: theme.textTheme.bodySmall),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        FilledButton(onPressed: _save, child: Text(l.commonSave)),
      ],
    );
  }
}
