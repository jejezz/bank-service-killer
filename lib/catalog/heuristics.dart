import 'catalog.dart';

/// 카탈로그가 모르는 서비스를 "보안 프로그램처럼 보이는가"로 가리는 규칙.
///
/// 확정이 아니라 **후보**다. 이유를 함께 보여 주고, 목록에 넣을지는 사용자가 정한다.
/// 기본 규칙은 앱에 들어 있고, 서명된 카탈로그의 `heuristics` 가 더해져 앱을 다시 배포하지 않고도 고칠 수 있다.
class Heuristics {
  const Heuristics({required this.keywords, required this.signers, required this.trustedSigners});

  /// 이름·표시 이름·경로에 들어 있으면 의심하는 낱말 (소문자).
  final List<String> keywords;

  /// 서명자에 들어 있으면 의심하는 보안 업체 이름 (소문자).
  final List<String> signers;

  /// 서명자에 들어 있으면 의심하지 않는 서명자 (소문자).
  final List<String> trustedSigners;

  /// 앱에 들어 있는 기본 규칙.
  static const defaults = Heuristics(
    keywords: [
      // 제품·업체 이름
      'nprotect', 'touchen', 'ahnlab', 'safe transaction', 'xecure', 'anysign', 'softforum', 'raon',
      'initech', 'inisafe', 'wizvera', 'veraport', 'interezen', 'ipinside', 'dreamsecurity', 'magicline',
      'markany', 'crossex', 'innorix', 'koscom', 'nxts', 'nxkey',
      // 일반 낱말
      'keyboard security', 'keylog', 'keypad', 'firewall', 'security', '보안', '방화벽', '키보드', '키패드', '인증서',
    ],
    signers: [
      'inca internet', 'ahnlab', 'softforum', 'raonsecure', 'raon secure', 'initech', 'wizvera', 'interezen',
      'dream security', 'dreamsecurity', 'markany', 'koscom', 'innorix', 'iniline', 'ini line',
    ],
    trustedSigners: ['microsoft windows', 'microsoft corporation'],
  );

  /// 카탈로그의 규칙을 기본 규칙에 합친다 (중복 없이).
  Heuristics merge(HeuristicsData extra) => Heuristics(
        keywords: {...keywords, ...extra.keywords}.toList(),
        signers: {...signers, ...extra.signers}.toList(),
        trustedSigners: {...trustedSigners, ...extra.trustedSigners}.toList(),
      );
}

enum ReasonKind { name, display, path, signer }

/// 왜 의심했는가: 어느 곳(이름·표시 이름·경로·서명자)에서 어떤 낱말이 걸렸는지.
class Reason {
  const Reason(this.kind, this.value);

  final ReasonKind kind;
  final String value;

  @override
  bool operator ==(Object other) => other is Reason && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);
}

class Suspect {
  const Suspect(this.service, this.reasons);

  final InstalledService service;
  final List<Reason> reasons;
}

/// [services] 중 보안 프로그램처럼 보이는 것을 이유 많은 순으로 돌려준다.
///
/// 빼는 것: Windows 폴더 아래 서비스, 서명자가 [Heuristics.trustedSigners] 인 서비스, 이름이 [skip] 에 든 서비스.
/// 서명자를 아직 모르는(null) 서비스는 서명자 규칙만 건너뛰고 나머지로 판정한다.
List<Suspect> findSuspects(Heuristics h, List<InstalledService> services, {Set<String> skip = const {}}) {
  final out = <Suspect>[];
  for (final s in services) {
    if (s.isWindowsOwn || skip.contains(s.name.toLowerCase())) continue;
    final signer = s.signer?.toLowerCase();
    if (signer != null && h.trustedSigners.any(signer.contains)) continue;

    final reasons = <Reason>[];
    final name = s.name.toLowerCase();
    final display = s.displayName.toLowerCase();
    final path = s.path.toLowerCase();
    for (final k in h.keywords) {
      if (name.contains(k)) reasons.add(Reason(ReasonKind.name, k));
      if (display.contains(k) && display != name) reasons.add(Reason(ReasonKind.display, k));
      if (path.contains(k)) reasons.add(Reason(ReasonKind.path, k));
    }
    if (signer != null) {
      for (final k in h.signers) {
        if (signer.contains(k)) reasons.add(Reason(ReasonKind.signer, k));
      }
    }
    if (reasons.isNotEmpty) out.add(Suspect(s, reasons));
  }
  out.sort((a, b) => b.reasons.length.compareTo(a.reasons.length));
  return out;
}
