import 'dart:convert';
import 'dart:io';

/// 감시 대상 서비스 항목. name은 서비스 이름 또는 표시 이름(부분 일치 가능).
class WatchItem {
  final String name;
  final String group; // A: 보안 무관, B: 웹 플러그인, C: 드라이버 연동 가능
  final String note;

  const WatchItem(this.name, {this.group = 'B', this.note = ''});

  Map<String, dynamic> toJson() => {'name': name, 'group': group, 'note': note};

  factory WatchItem.fromJson(Map<String, dynamic> j) => WatchItem(
        j['name'] as String,
        group: (j['group'] ?? 'B') as String,
        note: (j['note'] ?? '') as String,
      );
}

/// 기본 목록. 처음 실행할 때만 사용되고, 이후에는 watchlist.json이 우선한다.
const defaultWatchItems = <WatchItem>[
  WatchItem('Nahimic service', group: 'A', note: '오디오 효과 (보안 아님)'),
  WatchItem('AnySign4PC Launcher'),
  WatchItem('CrossEX Live Checker'),
  WatchItem('Image SAFER 5.0 Service'),
  WatchItem('INNORIX EX Management'),
  WatchItem('INNORIX EX Service'),
  WatchItem('Interezen LWS'),
  WatchItem('KOSCOMSecLogGather'),
  WatchItem('MagicLine4NX Service'),
  WatchItem('nxTS Process Manager Service', group: 'C', note: '키보드보안, 드라이버 연동 가능'),
  WatchItem('OZWLservice'),
  WatchItem('SignKoreaWD'),
  WatchItem('ToucnEn_nxFireWell', group: 'C', note: '개인방화벽, 드라이버 연동 가능'),
  WatchItem('WIZVERA Process Manager Service'),
];

/// %APPDATA%\BankServiceKiller\watchlist.json 에 감시 목록을 저장/로드한다.
class WatchStore {
  static File get _file {
    final base = Platform.environment['APPDATA'] ?? Directory.current.path;
    return File('$base\\BankServiceKiller\\watchlist.json');
  }

  /// 이름을 바꾸기 전(Bank Breaker)에 쓰던 위치. 새 파일이 없을 때만 읽는다.
  static File get _legacyFile {
    final base = Platform.environment['APPDATA'] ?? Directory.current.path;
    return File('$base\\BankBreaker\\watchlist.json');
  }

  static Future<List<WatchItem>> load() async {
    try {
      final file = await _file.exists() ? _file : _legacyFile;
      if (await file.exists()) {
        final list = jsonDecode(await file.readAsString()) as List;
        return list.map((e) => WatchItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return List.of(defaultWatchItems);
  }

  static Future<void> save(List<WatchItem> items) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(items.map((e) => e.toJson()).toList()),
    );
  }
}
