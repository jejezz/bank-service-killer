import '../l10n/app_localizations.dart';
import 'heuristics.dart';

/// 후보로 짐작한 이유를 화면 언어의 문장으로 만든다 (예: "서명자에 'inca internet'").
String reasonText(AppLocalizations l, Reason r) => switch (r.kind) {
      ReasonKind.name => l.suspectReasonName(r.value),
      ReasonKind.display => l.suspectReasonDisplay(r.value),
      ReasonKind.path => l.suspectReasonPath(r.value),
      ReasonKind.signer => l.suspectReasonSigner(r.value),
    };
