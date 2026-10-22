import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/app_settings.dart';
import 'catalog.dart';
import 'web_search.dart';

/// 서비스 이름·실행 파일 이름으로 웹 검색을 여는 단추. 사용자가 이 서비스가 무엇인지 보고 판단하도록 돕는다.
/// 검색엔진은 설정(기본 Google)을 따르고, 브라우저가 열려 결과를 보여 준다. 경로는 검색어에 넣지 않는다.
class ServiceSearchButton extends StatelessWidget {
  const ServiceSearchButton(this.service, {super.key});

  final InstalledService service;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final engine = AppSettingsScope.maybeOf(context)?.searchEngine ?? SearchEngine.google;
    return IconButton(
      tooltip: l.searchTooltip(engine.label),
      icon: const Icon(Icons.search_rounded),
      onPressed: () async {
        final messenger = ScaffoldMessenger.maybeOf(context);
        final ok = await openSearch(engine, service);
        if (!ok) messenger?.showSnackBar(SnackBar(content: Text(l.reportOpenFailed)));
      },
    );
  }
}

/// 검색엔진 고르기. 설정 범위가 없으면(시험 등) 아무것도 그리지 않는다.
class SearchEngineMenu extends StatelessWidget {
  const SearchEngineMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.maybeOf(context);
    if (settings == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return PopupMenuButton<SearchEngine>(
      tooltip: l.searchEngineTooltip,
      initialValue: settings.searchEngine,
      onSelected: settings.setSearchEngine,
      itemBuilder: (_) => [
        for (final e in SearchEngine.values)
          CheckedPopupMenuItem(value: e, checked: e == settings.searchEngine, child: Text(e.label)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.travel_explore_rounded, size: 18),
          const SizedBox(width: 6),
          Text(l.searchEngineLabel(settings.searchEngine.label)),
          const Icon(Icons.arrow_drop_down_rounded),
        ]),
      ),
    );
  }
}
