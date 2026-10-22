import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_identity.dart';
import '../l10n/app_localizations.dart';
import '../service_manager.dart';
import '../theme/app_theme.dart';
import '../watch_item.dart';
import 'catalog.dart';
import 'catalog_controller.dart';
import 'discovery.dart';
import 'installed.dart';
import 'report.dart';

/// 카탈로그 창: 이 PC에서 발견한 서비스와 이름이 바뀐 항목을 제안하고, 승인하면 목록에 반영한다.
/// 고친 사본을 돌려준다 (바꾼 것이 없으면 null). 카탈로그는 제안만 하고 아무것도 자동으로 하지 않는다.
Future<WatchData?> showCatalogDialog(
  BuildContext context, {
  required CatalogController controller,
  required WatchData data,
  required List<SvcInfo> services,
}) {
  return showDialog<WatchData>(
    context: context,
    builder: (_) => _CatalogDialog(controller: controller, data: data.copy(), services: services),
  );
}

/// 지금 카탈로그와 이 PC·목록을 견준 제안 개수 (창 밖의 배지에 쓴다). 서명자는 조사하지 않는 가벼운 판정.
int suggestionCount(Catalog catalog, WatchData data, List<SvcInfo> services) =>
    discover(catalog, data, [for (final s in services) s.toInstalled()]).count;

String _fmt(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}

class _CatalogDialog extends StatefulWidget {
  const _CatalogDialog({required this.controller, required this.data, required this.services});

  final CatalogController controller;
  final WatchData data;
  final List<SvcInfo> services;

  @override
  State<_CatalogDialog> createState() => _CatalogDialogState();
}

class _CatalogDialogState extends State<_CatalogDialog> {
  late final WatchData _d = widget.data;
  List<InstalledService>? _installed;
  final Set<String> _picked = {};
  bool _changed = false;
  String? _message;
  String? _notice;

  CatalogController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onCatalog);
    _scan();
  }

  @override
  void dispose() {
    _c.removeListener(_onCatalog);
    super.dispose();
  }

  void _onCatalog() {
    if (mounted) _scan(); // 새 카탈로그를 받았으면 다시 견준다.
  }

  Future<void> _scan() async {
    final list = await loadInstalled(widget.services, _c.catalog);
    if (mounted) setState(() => _installed = list);
  }

  Discovery get _discovery =>
      _installed == null ? const Discovery() : discover(_c.catalog, _d, _installed!);

  String _lang() => Localizations.localeOf(context).languageCode;

  String _errText(AppLocalizations l, CatalogError? e) => switch (e) {
        CatalogError.network || null => l.catalogErrNetwork,
        CatalogError.signature => _c.lastBytes == null
            ? l.catalogErrSignature
            : l.catalogErrSignatureDetail(_c.lastBytes!, _c.lastSigHead ?? '', _c.keyFingerprint),
        CatalogError.format => l.catalogErrFormat,
        CatalogError.rollback => l.catalogErrRollback,
      };

  Future<void> _checkNow() async {
    final l = AppLocalizations.of(context);
    final r = await _c.refresh();
    if (!mounted) return;
    setState(() {
      _message = switch (r) {
        CatalogRefresh.updated => l.catalogResultUpdated,
        CatalogRefresh.upToDate => l.catalogResultUpToDate,
        CatalogRefresh.rejected => l.catalogResultRejected(_errText(l, _c.lastError)),
        CatalogRefresh.failed => l.catalogResultFailed(_errText(l, _c.lastError)),
        CatalogRefresh.disabled => null,
      };
    });
  }

  void _addPicked() {
    final l = AppLocalizations.of(context);
    final hits = [for (final h in _discovery.newFinds) if (_picked.contains(h.service.name)) h];
    if (hits.isEmpty) return;
    final created = addFinds(_d, _c.catalog, hits, _lang());
    setState(() {
      _changed = true;
      _picked.clear();
      _message = l.catalogAdded(hits.length);
      _notice = created.isEmpty ? null : l.catalogNewCategoriesNote(created.join(', '));
    });
  }

  void _rename(RenameSuggestion r) {
    applyRename(_d, r);
    setState(() => _changed = true);
  }

  Future<void> _report() async {
    final known = {for (final h in findHits(_c.catalog, _installed ?? const [])) h.service.name.toLowerCase()};
    await showDialog<void>(
      context: context,
      builder: (_) => _ReportDialog(
        services: [
          for (final s in widget.services)
            if (!s.isWindowsOwn && !known.contains(s.name.toLowerCase())) s,
        ],
        catalogVersion: _c.catalog.version,
      ),
    );
  }

  String _sourceText(AppLocalizations l) => switch (_c.source) {
        CatalogSource.bundled => l.catalogSourceBundled,
        CatalogSource.cache => l.catalogSourceCache,
        CatalogSource.remote => l.catalogSourceRemote,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final lang = _lang();
    final cat = _c.catalog;
    final d = _discovery;
    final checked = _c.checkedAt;
    return AlertDialog(
      title: Text(l.catalogTitle),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.catalogInfo(cat.version, cat.updated), style: theme.textTheme.titleSmall),
            Text(_sourceText(l), style: theme.textTheme.bodySmall),
            Text(checked == null ? l.catalogNeverChecked : l.catalogChecked(_fmt(checked)),
                style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              OutlinedButton.icon(
                onPressed: _c.remoteEnabled && !_c.checking ? _checkNow : null,
                icon: _c.checking
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync_rounded),
                label: Text(_c.checking ? l.catalogChecking : l.catalogCheckNow),
              ),
              const SizedBox(width: AppSpacing.md),
              if (_message != null) Expanded(child: Text(_message!, style: theme.textTheme.bodySmall)),
            ]),
            if (_c.remoteEnabled)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(l.catalogKeyInfo(_c.keyFingerprint), style: theme.textTheme.bodySmall),
              ),
            if (!_c.remoteEnabled)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(l.catalogRemoteOff, style: theme.textTheme.bodySmall),
              ),
            const Divider(height: AppSpacing.xl),
            Text(l.catalogSuggestionNote, style: theme.textTheme.bodySmall),
            if (_notice != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(_notice!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: dark ? AppColors.warning : AppColors.warningTextLight)),
              ),
            if (_installed == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Row(children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: AppSpacing.md),
                  Text(l.catalogScanning),
                ]),
              )
            else if (d.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(l.catalogNothing),
              )
            else ...[
              if (d.renames.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
                  child: Text(l.catalogRenamesHeader(d.renames.length), style: theme.textTheme.titleSmall),
                ),
                for (final r in d.renames)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.catalogRenameLine(r.item.name, r.hit.service.name), style: AppFonts.userContent),
                    subtitle: Text(l.catalogRenameNote(r.hit.product.name)),
                    trailing: FilledButton.tonal(
                      onPressed: () => _rename(r),
                      child: Text(l.catalogRenameApply),
                    ),
                  ),
              ],
              if (d.newFinds.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
                  child: Text(l.catalogFindsHeader(d.newFinds.length), style: theme.textTheme.titleSmall),
                ),
                for (final h in d.newFinds)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _picked.contains(h.service.name),
                    onChanged: (v) => setState(() => v == true ? _picked.add(h.service.name) : _picked.remove(h.service.name)),
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
                        if (h.product.categories.isNotEmpty)
                          h.product.categories.map((c) => cat.categoryLabel(c, lang)).join(', '),
                      ].join('  ·  '),
                      style: AppFonts.userContent,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _picked.isEmpty ? null : _addPicked,
                    child: Text(l.catalogAddSelected(_picked.length)),
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: _installed == null ? null : _report,
              icon: const Icon(Icons.flag_outlined),
              label: Text(l.catalogReport),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _changed ? _d : null),
          child: Text(l.commonClose),
        ),
      ],
    );
  }
}

/// 신고 창: 카탈로그에 없는 서비스를 고르면, 이슈 초안에 담길 내용을 그대로 보여 주고 브라우저로 연다.
class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.services, required this.catalogVersion});

  final List<SvcInfo> services;
  final int catalogVersion;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _search = TextEditingController();
  ServiceReport? _report;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pick(SvcInfo s) async {
    setState(() => _loading = true);
    final signers = await ServiceManager.signers([s.exePath]);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _report = ServiceReport(
        serviceName: s.name,
        displayName: s.displayName,
        exeName: exeBaseName(s.path),
        signer: signers[s.exePath],
        catalogVersion: widget.catalogVersion,
      );
    });
  }

  Future<void> _open() async {
    final l = AppLocalizations.of(context);
    final r = _report;
    if (r == null) return;
    final ok = await launchUrl(r.url(AppIdentity.newIssueUrl), mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _error = l.reportOpenFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final q = _search.text.trim().toLowerCase();
    final list = [
      for (final s in widget.services)
        if (q.isEmpty || s.name.toLowerCase().contains(q) || s.displayName.toLowerCase().contains(q)) s,
    ];
    final r = _report;
    return AlertDialog(
      title: Text(l.reportTitle),
      content: SizedBox(
        width: 560,
        height: 420,
        child: _loading
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(l.reportChecking),
                ]),
              )
            : r != null
                ? SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.reportWillSend, style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                        child: SelectableText('${r.title}\n\n${r.body}', style: AppFonts.mono.copyWith(fontSize: 12)),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                        ),
                    ]),
                  )
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.reportHint, style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _search,
                      decoration: InputDecoration(labelText: l.reportSearch, prefixIcon: const Icon(Icons.search_rounded)),
                      onChanged: (_) => setState(() {}),
                    ),
                    Expanded(
                      child: ListView(children: [
                        for (final s in list)
                          ListTile(
                            dense: true,
                            title: Text(s.displayName.isEmpty ? s.name : s.displayName, style: AppFonts.userContent),
                            subtitle: Text('${s.name} · ${exeBaseName(s.path)}', style: AppFonts.userContent),
                            onTap: () => _pick(s),
                          ),
                      ]),
                    ),
                  ]),
      ),
      actions: [
        if (r != null && !_loading) ...[
          TextButton(onPressed: () => setState(() => _report = null), child: Text(l.reportBack)),
          FilledButton.icon(onPressed: _open, icon: const Icon(Icons.open_in_new_rounded), label: Text(l.reportOpen)),
        ] else
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonClose)),
      ],
    );
  }
}
