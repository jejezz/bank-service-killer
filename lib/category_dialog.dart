import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'watch_item.dart';

/// 카테고리 이름 바꾸기·추가·삭제와 "뱅킹 모드에 포함" 설정.
/// 저장을 누르면 고친 사본을, 취소하면 null 을 돌려준다.
Future<WatchData?> showCategoryManager(BuildContext context, WatchData data) {
  return showDialog<WatchData>(
    context: context,
    builder: (_) => _CategoryManager(data.copy()),
  );
}

class _CategoryManager extends StatefulWidget {
  const _CategoryManager(this.data);

  final WatchData data;

  @override
  State<_CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<_CategoryManager> {
  final _newCtl = TextEditingController();
  String? _error;

  WatchData get _d => widget.data;

  @override
  void dispose() {
    _newCtl.dispose();
    super.dispose();
  }

  void _add() {
    final l = AppLocalizations.of(context);
    final name = _newCtl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      if (_d.addCategory(name)) {
        _d.setBanking(name, true);
        _newCtl.clear();
        _error = null;
      } else {
        _error = l.catExists;
      }
    });
  }

  Future<void> _rename(String from) async {
    final l = AppLocalizations.of(context);
    final ctl = TextEditingController(text: from);
    final to = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.catRename),
        content: TextField(
          controller: ctl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctl.text), child: Text(l.commonSave)),
        ],
      ),
    );
    ctl.dispose();
    if (to == null || to.trim() == from) return;
    setState(() => _error = _d.renameCategory(from, to) ? null : l.catExists);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l.catManageTitle),
      content: SizedBox(
        width: 520,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.catManageHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: ListView(shrinkWrap: true, children: [
              for (final c in _d.categories)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Tooltip(
                    message: l.catBankingInclude,
                    child: Checkbox(
                      value: _d.bankingCategories.contains(c),
                      onChanged: (v) => setState(() => _d.setBanking(c, v ?? false)),
                    ),
                  ),
                  title: Text(c, style: AppFonts.userContent),
                  subtitle: Text(l.catItemCount(_d.countIn(c))),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      tooltip: l.catRename,
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => _rename(c),
                    ),
                    IconButton(
                      tooltip: l.catDelete,
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: () => setState(() => _d.deleteCategory(c)),
                    ),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _newCtl,
            decoration: InputDecoration(
              labelText: l.catAddField,
              errorText: _error,
              suffixIcon: IconButton(
                tooltip: l.commonAdd,
                icon: const Icon(Icons.add_rounded),
                onPressed: _add,
              ),
            ),
            onSubmitted: (_) => _add(),
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
