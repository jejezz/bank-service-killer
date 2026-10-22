import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'mode_engine.dart';
import 'theme/app_theme.dart';
import 'watch_item.dart';

/// 모드 추가·수정·삭제와 기본 모드 지정. 저장하면 고친 사본을, 취소하면 null 을 돌려준다.
Future<WatchData?> showModeManager(BuildContext context, WatchData data) {
  return showDialog<WatchData>(
    context: context,
    builder: (_) => _ModeManager(data.copy()),
  );
}

/// 자동 복귀 시간 선택지(분). 0 = 복귀 안 함.
const _revertChoices = [0, 10, 15, 20, 30, 45, 60, 90, 120];

class _ModeManager extends StatefulWidget {
  const _ModeManager(this.data);

  final WatchData data;

  @override
  State<_ModeManager> createState() => _ModeManagerState();
}

class _ModeManagerState extends State<_ModeManager> {
  WatchData get _d => widget.data;

  String _summary(AppLocalizations l, WatchMode m) {
    final parts = <String>[
      if (m.on.isNotEmpty) l.modeSummaryOn(m.on.join(', ')) else l.modeSummaryNoneOn,
      if (m.keep.isNotEmpty) l.modeSummaryKeep(m.keep.join(', ')),
      if (m.revertMinutes > 0) l.modeRevertAfter(m.revertMinutes),
    ];
    return parts.join(' · ');
  }

  Future<void> _edit(WatchMode? existing) async {
    final result = await showDialog<WatchMode>(
      context: context,
      builder: (_) => _ModeEditor(categories: _d.categories, mode: existing),
    );
    if (result == null || !mounted) return;
    final l = AppLocalizations.of(context);
    final ok = existing == null ? _d.addMode(result) : _d.updateMode(existing.name, result);
    setState(() {});
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.modeNameExists)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l.modeManageTitle),
      content: SizedBox(
        width: 560,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.modeManageHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: ListView(shrinkWrap: true, children: [
              for (final m in _d.modes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Tooltip(
                    message: l.modeDefaultHint,
                    child: IconButton(
                      icon: Icon(m.name == _d.defaultMode ? Icons.star_rounded : Icons.star_border_rounded,
                          color: m.name == _d.defaultMode ? AppColors.warning : null),
                      onPressed: () => setState(() => _d.setDefaultMode(m.name)),
                    ),
                  ),
                  title: Text(
                    m.name == _d.defaultMode ? '${m.name}  (${l.modeDefaultTag})' : m.name,
                    style: AppFonts.userContent,
                  ),
                  subtitle: Text(_summary(l, m), style: AppFonts.userContent),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      tooltip: l.editTooltip,
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => _edit(m),
                    ),
                    IconButton(
                      tooltip: l.modeDelete,
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: _d.modes.length <= 1 ? null : () => setState(() => _d.deleteMode(m.name)),
                    ),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _edit(null),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.modeAdd),
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _d), child: Text(l.commonSave)),
      ],
    );
  }
}

/// 모드 하나를 만들거나 고친다: 이름, 카테고리별 켜기/그대로/끄기, 자동 복귀.
class _ModeEditor extends StatefulWidget {
  const _ModeEditor({required this.categories, this.mode});

  final List<String> categories;
  final WatchMode? mode;

  @override
  State<_ModeEditor> createState() => _ModeEditorState();
}

class _ModeEditorState extends State<_ModeEditor> {
  late final TextEditingController _name;
  late final Map<String, Want> _want;
  late int _revert;

  @override
  void initState() {
    super.initState();
    final m = widget.mode;
    _name = TextEditingController(text: m?.name ?? '');
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
    _revert = m?.revertMinutes ?? 0;
  }

  @override
  void dispose() {
    _name.dispose();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final choices = {..._revertChoices, _revert}.toList()..sort();
    return AlertDialog(
      title: Text(widget.mode == null ? l.modeNewTitle : l.modeEditTitle),
      content: SizedBox(
        width: 560,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: l.modeName),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l.modeCategoriesLabel, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(l.modeCategoriesHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: ListView(shrinkWrap: true, children: [
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
          const SizedBox(height: AppSpacing.lg),
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
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        FilledButton(onPressed: _save, child: Text(l.commonSave)),
      ],
    );
  }
}
