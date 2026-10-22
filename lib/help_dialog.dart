import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// 처음 쓰는 사람을 위한 사용 방법 창.
Future<void> showHelpDialog(BuildContext context) {
  final l = AppLocalizations.of(context);
  final sections = [
    (l.helpPurposeTitle, l.helpPurposeBody),
    (l.helpListTitle, l.helpListBody),
    (l.helpGroupTitle, l.helpGroupBody),
    (l.helpOnOffTitle, l.helpOnOffBody),
    (l.helpModeTitle, l.helpModeBody),
    (l.helpCatalogTitle, l.helpCatalogBody),
    (l.helpResidentTitle, l.helpResidentBody),
  ];
  final theme = Theme.of(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.helpTitle),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final (title, body) in sections) ...[
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(body, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
            ],
          ]),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.helpClose))],
    ),
  );
}
