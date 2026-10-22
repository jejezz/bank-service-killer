import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'mode_editor.dart';
import 'theme/app_theme.dart';
import 'watch_item.dart';

/// 모드 추가·수정·복제·삭제와 기본 모드 지정. 저장하면 고친 사본을, 취소하면 null 을 돌려준다.
/// [running]은 서비스 이름(소문자) → 지금 실행 중인지 (null 이면 설치되지 않음). 서비스별 편집의 거르기에 쓴다.
Future<WatchData?> showModeManager(
  BuildContext context,
  WatchData data, {
  Map<String, bool?> running = const {},
}) {
  return showDialog<WatchData>(
    context: context,
    builder: (_) => _ModeManager(data.copy(), running),
  );
}

class _ModeManager extends StatefulWidget {
  const _ModeManager(this.data, this.running);

  final WatchData data;
  final Map<String, bool?> running;

  @override
  State<_ModeManager> createState() => _ModeManagerState();
}

class _ModeManagerState extends State<_ModeManager> {
  WatchData get _d => widget.data;

  String _summary(AppLocalizations l, WatchMode m) {
    final parts = <String>[
      if (m.on.isNotEmpty) l.modeSummaryOn(m.on.join(', ')) else l.modeSummaryNoneOn,
      if (m.keep.isNotEmpty) l.modeSummaryKeep(m.keep.join(', ')),
      if (m.services.isNotEmpty) l.modeSummaryServices(m.services.length),
      if (m.revertMinutes > 0) l.modeRevertAfter(m.revertMinutes),
    ];
    return parts.join(' · ');
  }

  Future<void> _edit(WatchMode? existing) async {
    final result = await showModeEditor(
      context,
      categories: _d.categories,
      items: _d.items,
      running: widget.running,
      mode: existing,
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
                      tooltip: l.modeClone,
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () => setState(() => _d.addMode(m.copyWith(name: _d.uniqueModeName(l.modeCopyName(m.name))))),
                    ),
                    IconButton(
                      tooltip: l.modeEdit,
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
