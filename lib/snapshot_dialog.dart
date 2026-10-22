import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'watch_item.dart';

class SnapshotChoice {
  const SnapshotChoice(this.name, {required this.overwrite});

  /// 새 모드 이름, 또는 덮어쓸 기존 모드 이름.
  final String name;
  final bool overwrite;
}

/// "현재 상태를 모드로 저장": 새 모드로 만들지, 기존 모드를 덮어쓸지 고른다. 취소하면 null.
///
/// [on]/[off]는 저장될 서비스 개수(켜짐/꺼짐), [skipped]는 이 PC에 설치되지 않아 빠지는 개수다.
/// [suggested]는 덮어쓰기 대상으로 처음에 가리킬 모드 (보통 지금 모드).
Future<SnapshotChoice?> showSnapshotDialog(
  BuildContext context, {
  required WatchData data,
  required int on,
  required int off,
  required int skipped,
  String? suggested,
}) {
  return showDialog<SnapshotChoice>(
    context: context,
    builder: (_) => _SnapshotDialog(data: data, on: on, off: off, skipped: skipped, suggested: suggested),
  );
}

class _SnapshotDialog extends StatefulWidget {
  const _SnapshotDialog({
    required this.data,
    required this.on,
    required this.off,
    required this.skipped,
    this.suggested,
  });

  final WatchData data;
  final int on;
  final int off;
  final int skipped;
  final String? suggested;

  @override
  State<_SnapshotDialog> createState() => _SnapshotDialogState();
}

class _SnapshotDialogState extends State<_SnapshotDialog> {
  late final TextEditingController _name;
  bool _overwrite = false;
  late String _target;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    final names = [for (final m in widget.data.modes) m.name];
    _target = names.contains(widget.suggested) ? widget.suggested! : names.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? _nameError(AppLocalizations l) {
    final n = _name.text.trim();
    if (n.isEmpty) return null; // 비어 있는 동안은 오류를 띄우지 않고 저장만 막는다.
    return widget.data.modes.any((m) => m.name == n) ? l.modeNameExists : null;
  }

  bool get _valid {
    if (_overwrite) return widget.data.modeNamed(_target) != null;
    final n = _name.text.trim();
    return n.isNotEmpty && !widget.data.modes.any((m) => m.name == n);
  }

  void _save() => Navigator.pop(
        context,
        SnapshotChoice(_overwrite ? _target : _name.text.trim(), overwrite: _overwrite),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final target = widget.data.modeNamed(_target);
    return AlertDialog(
      title: Text(l.snapshotTitle),
      content: SizedBox(
        width: 520,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.snapshotSummary(widget.on + widget.off, widget.on, widget.off), style: theme.textTheme.bodyMedium),
          if (widget.skipped > 0)
            Text(l.snapshotSkipped(widget.skipped), style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l.snapshotNew)),
              ButtonSegment(value: true, label: Text(l.snapshotOverwrite)),
            ],
            selected: {_overwrite},
            onSelectionChanged: (s) => setState(() => _overwrite = s.single),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!_overwrite)
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.modeName,
                hintText: widget.data.uniqueModeName(l.snapshotDefaultName),
                errorText: _nameError(l),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _valid ? _save() : null,
            )
          else ...[
            DropdownButton<String>(
              value: _target,
              isExpanded: true,
              items: [
                for (final m in widget.data.modes)
                  DropdownMenuItem(
                    value: m.name,
                    child: Text(
                      m.name == widget.data.defaultMode ? '${m.name}  (${l.modeDefaultTag})' : m.name,
                      style: AppFonts.userContent,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _target = v ?? _target),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              target != null && target.name == widget.data.defaultMode
                  ? '${l.snapshotOverwriteNote}\n${l.snapshotOverwriteDefaultWarning}'
                  : l.snapshotOverwriteNote,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        FilledButton(onPressed: _valid ? _save : null, child: Text(_overwrite ? l.snapshotDoOverwrite : l.commonSave)),
      ],
    );
  }
}
