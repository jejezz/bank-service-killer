import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// 미리보기 창의 한 줄: 서비스 이름과 덧붙이는 말.
class PlanLine {
  const PlanLine(this.title, {this.note});

  final String title;
  final String? note;
}

/// 모드 전환 드라이런: 실제로 바꾸기 전에 무엇을 끄고 켤지 보여 주고, 실행/취소를 묻는다.
/// 실행하면 true, 취소하면 false.
Future<bool> showModePlanDialog(
  BuildContext context, {
  required String modeName,
  required List<PlanLine> stop,
  required List<PlanLine> start,
  required int unchanged,
}) async {
  final answer = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ModePlanDialog(modeName: modeName, stop: stop, start: start, unchanged: unchanged),
  );
  return answer ?? false;
}

class _ModePlanDialog extends StatelessWidget {
  const _ModePlanDialog({
    required this.modeName,
    required this.stop,
    required this.start,
    required this.unchanged,
  });

  final String modeName;
  final List<PlanLine> stop;
  final List<PlanLine> start;
  final int unchanged;

  Widget _section(BuildContext context, String header, IconData icon, Color color, List<PlanLine> lines) {
    if (lines.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(header, style: theme.textTheme.titleSmall),
        ]),
      ),
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl, bottom: 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(line.title, style: AppFonts.userContent.merge(theme.textTheme.bodyMedium)),
            if (line.note != null) Text(line.note!, style: AppFonts.userContent.merge(theme.textTheme.bodySmall)),
          ]),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return AlertDialog(
      title: Text(l.planTitle(modeName)),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.planIntro, style: theme.textTheme.bodySmall),
            _section(
              context,
              l.planStopHeader(stop.length),
              Icons.stop_circle_rounded,
              dark ? AppColors.danger : AppColors.dangerTextLight,
              stop,
            ),
            _section(
              context,
              l.planStartHeader(start.length),
              Icons.play_circle_fill_rounded,
              dark ? AppColors.success : AppColors.successTextLight,
              start,
            ),
            if (unchanged > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(l.planUnchanged(unchanged), style: theme.textTheme.bodySmall),
              ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.commonCancel)),
        FilledButton(autofocus: true, onPressed: () => Navigator.pop(context, true), child: Text(l.planRun)),
      ],
    );
  }
}
