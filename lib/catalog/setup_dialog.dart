import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../service_manager.dart';
import '../theme/app_theme.dart';
import '../watch_item.dart';
import 'catalog_controller.dart';
import 'installed.dart';
import 'reason_text.dart';
import 'search_button.dart';
import 'setup.dart';

/// 첫 실행 마법사: 이 PC에서 찾은 보안 서비스를 보여 주고, 확인하면 목록과 모드를 만들어 준다.
/// "추가하고 시작"이면 반영한 사본을, "나중에"(또는 찾은 것이 없을 때)면 null 을 돌려준다.
///
/// - 카탈로그가 아는 서비스는 미리 체크해 두고, 후보(추정)는 체크하지 않은 채 이유와 함께 보여 준다.
/// - 고른 서비스는 기본 모드가 아닌 모드(보통 뱅킹)에서 켜는 것으로 시작한다. 모드는 직접 바꿀 수 있다.
Future<WatchData?> showSetupDialog(
  BuildContext context, {
  required CatalogController catalog,
  required WatchData data,
  required List<SvcInfo> services,
  SignerCache? signers,
}) {
  return showDialog<WatchData>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _SetupDialog(catalog: catalog, data: data.copy(), services: services, signers: signers ?? SignerCache()),
  );
}

class _SetupDialog extends StatefulWidget {
  const _SetupDialog({required this.catalog, required this.data, required this.services, required this.signers});

  final CatalogController catalog;
  final WatchData data;
  final List<SvcInfo> services;
  final SignerCache signers;

  @override
  State<_SetupDialog> createState() => _SetupDialogState();
}

class _SetupDialogState extends State<_SetupDialog> {
  SetupPlan? _plan;
  final Set<String> _found = {};
  final Set<String> _candidates = {};
  late final Set<String> _modes = {
    for (final m in widget.data.modes)
      if (m.name != widget.data.defaultMode) m.name,
  };

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    final cat = widget.catalog.catalog;
    final installed = await loadInstalled(widget.services, cat, cache: widget.signers, withSigners: true);
    if (!mounted) return;
    final plan = planSetup(cat, widget.data, installed);
    setState(() {
      _plan = plan;
      _found.addAll(plan.found.map((h) => h.service.name)); // 카탈로그가 아는 것은 미리 체크
    });
  }

  int get _count => _found.length + _candidates.length;

  void _start() {
    final plan = _plan!;
    final l = AppLocalizations.of(context);
    applySetup(
      widget.data,
      widget.catalog.catalog,
      hits: [for (final h in plan.found) if (_found.contains(h.service.name)) h],
      suspects: [for (final s in plan.candidates) if (_candidates.contains(s.service.name)) s],
      modeNames: _modes,
      lang: Localizations.localeOf(context).languageCode,
      candidateCategory: l.suspectCategoryDefault,
    );
    Navigator.pop(context, widget.data);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cat = widget.catalog.catalog;
    final lang = Localizations.localeOf(context).languageCode;
    final plan = _plan;
    return AlertDialog(
      title: Text(l.setupTitle),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.setupIntro, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            if (plan == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Row(children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: AppSpacing.md),
                  Text(l.catalogScanning),
                ]),
              )
            else if (plan.isEmpty)
              Text(l.setupNothing)
            else ...[
              if (plan.found.isNotEmpty) ...[
                Text(l.setupFoundHeader(plan.found.length), style: theme.textTheme.titleSmall),
                for (final h in plan.found)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: ServiceSearchButton(h.service),
                    value: _found.contains(h.service.name),
                    onChanged: (v) => setState(() => v == true ? _found.add(h.service.name) : _found.remove(h.service.name)),
                    title: Row(children: [
                      Flexible(
                        child: Text(
                          h.product.vendor == null ? h.product.name : '${h.product.name}  ·  ${h.product.vendor}',
                          style: AppFonts.userContent,
                        ),
                      ),
                      if (h.product.driver)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: Chip(
                            label: Text(l.catalogDriverTag),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                    ]),
                    subtitle: Text(
                      [
                        h.service.name,
                        if (h.product.categories.isNotEmpty) h.product.categories.map((c) => cat.categoryLabel(c, lang)).join(', '),
                      ].join('  ·  '),
                      style: AppFonts.userContent,
                    ),
                  ),
              ],
              if (plan.candidates.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Text(l.setupCandidatesHeader(plan.candidates.length), style: theme.textTheme.titleSmall),
                ),
                Text(l.setupCandidatesHint, style: theme.textTheme.bodySmall),
                for (final sp in plan.candidates)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: ServiceSearchButton(sp.service),
                    value: _candidates.contains(sp.service.name),
                    onChanged: (v) =>
                        setState(() => v == true ? _candidates.add(sp.service.name) : _candidates.remove(sp.service.name)),
                    title: Text(
                      sp.service.displayName.isEmpty ? sp.service.name : sp.service.displayName,
                      style: AppFonts.userContent,
                    ),
                    subtitle: Text(
                      '${sp.service.name}  ·  ${[for (final r in sp.reasons) reasonText(l, r)].join(', ')}',
                      style: AppFonts.userContent,
                    ),
                  ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Text(l.setupModesTitle, style: theme.textTheme.titleSmall),
              ),
              for (final m in widget.data.modes)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _modes.contains(m.name),
                  onChanged: (v) => setState(() => v == true ? _modes.add(m.name) : _modes.remove(m.name)),
                  title: Text(l.suspectModeItem(m.name), style: AppFonts.userContent),
                ),
              Text(l.setupModesNote, style: theme.textTheme.bodySmall),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(plan != null && plan.isEmpty ? l.commonClose : l.setupSkip),
        ),
        if (plan != null && !plan.isEmpty)
          FilledButton(
            onPressed: _count == 0 ? null : _start,
            child: Text(l.setupStart(_count)),
          ),
      ],
    );
  }
}
