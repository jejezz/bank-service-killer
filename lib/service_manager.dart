import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'l10n/app_localizations.dart';
import 'watch_item.dart';

/// Win32_Service 한 건의 스냅샷.
class SvcInfo {
  final String name;
  final String displayName;
  final String state; // Running, Stopped, Start Pending, Stop Pending ...
  final String startMode; // Auto, Manual, Disabled, Boot, System
  final String path;
  final int pid;

  const SvcInfo({
    required this.name,
    required this.displayName,
    required this.state,
    required this.startMode,
    required this.path,
    required this.pid,
  });

  bool get running => state == 'Running';

  factory SvcInfo.fromJson(Map<String, dynamic> j) => SvcInfo(
        name: (j['Name'] ?? '') as String,
        displayName: (j['DisplayName'] ?? '') as String,
        state: (j['State'] ?? '') as String,
        startMode: (j['StartMode'] ?? '') as String,
        path: (j['PathName'] ?? '') as String,
        pid: (j['ProcessId'] ?? 0) as int,
      );
}

/// 서비스 조작 결과. 문구는 화면 언어로 만들어야 해서 [text]에 로케일을 받아 쓴다.
class OpResult {
  final bool ok;
  final String Function(AppLocalizations l) text;
  const OpResult(this.ok, this.text);

  /// sc.exe 가 낸 원문처럼 번역할 수 없는 문구.
  OpResult.raw(this.ok, String message) : text = ((_) => message);
}

class ServiceListException implements Exception {
  final String detail;
  ServiceListException(this.detail);
  @override
  String toString() => detail;
}

/// 서비스 조회/제어. sc.exe, PowerShell, reg.exe 만 사용하므로 별도 패키지가 필요 없다.
class ServiceManager {
  /// 관리자 권한 여부 (net session 은 관리자만 성공).
  static Future<bool> isAdmin() async {
    final r = await Process.run('net', ['session']);
    return r.exitCode == 0;
  }

  /// 설치된 모든 서비스.
  static Future<List<SvcInfo>> listAll() async {
    const script =
        '[Console]::OutputEncoding=[Text.Encoding]::UTF8; '
        'Get-CimInstance Win32_Service | '
        'Select-Object Name,DisplayName,State,StartMode,PathName,ProcessId | '
        'ConvertTo-Json -Compress';
    final r = await Process.run(
      'powershell',
      ['-NoProfile', '-NonInteractive', '-Command', script],
      stdoutEncoding: utf8,
    );
    if (r.exitCode != 0) {
      throw ServiceListException('${r.stderr}');
    }
    final text = (r.stdout as String).trim();
    if (text.isEmpty) return [];
    final decoded = jsonDecode(text);
    final list = decoded is List ? decoded : [decoded];
    return list.map((e) => SvcInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// msconfig 에서 "사용 안 함"으로 바꾼 서비스 이름 집합.
  /// msconfig 는 원래 시작 유형을 이 레지스트리 키 아래에 보관한다.
  static Future<Set<String>> msconfigDisabled() async {
    final r = await Process.run('reg', [
      'query',
      r'HKLM\SOFTWARE\Microsoft\Shared Tools\MSConfig\services',
    ]);
    if (r.exitCode != 0) return {};
    final result = <String>{};
    for (final line in (r.stdout as String).split(RegExp(r'\r?\n'))) {
      final t = line.trim();
      if (t.startsWith('HKEY_') && t.contains(r'\services\')) {
        result.add(t.split(r'\').last.toLowerCase());
      }
    }
    return result;
  }

  /// 감시 항목 이름으로 실제 서비스를 찾는다. 서비스 이름/표시 이름 정확 일치를 우선하고,
  /// 없으면 부분 일치를 사용한다.
  static SvcInfo? match(WatchItem item, List<SvcInfo> all) {
    final key = item.name.toLowerCase();
    for (final s in all) {
      if (s.name.toLowerCase() == key || s.displayName.toLowerCase() == key) return s;
    }
    for (final s in all) {
      if (s.name.toLowerCase().contains(key) || s.displayName.toLowerCase().contains(key)) {
        return s;
      }
    }
    return null;
  }

  static Future<SvcInfo?> query(String name) async {
    final all = await listAll();
    for (final s in all) {
      if (s.name.toLowerCase() == name.toLowerCase()) return s;
    }
    return null;
  }

  /// 시작 유형 변경. mode: auto | demand | disabled
  static Future<OpResult> setStartMode(String name, String mode) async {
    final r = await Process.run('sc.exe', ['config', name, 'start=', mode]);
    final out = '${r.stdout}${r.stderr}'.trim();
    return r.exitCode == 0
        ? OpResult(true, (l) => l.svcModeChanged(mode))
        : OpResult.raw(false, out);
  }

  /// 시작 후 실제로 Running 이 되는지 [timeout] 동안 확인한다.
  static Future<OpResult> start(String name,
      {Duration timeout = const Duration(seconds: 15)}) async {
    final r = await Process.run('sc.exe', ['start', name]);
    if (r.exitCode != 0 && r.exitCode != 1056) {
      // 1056: 이미 실행 중
      return OpResult(false, (l) => l.svcStartCmdFailed(r.exitCode, _firstLine(r.stdout)));
    }
    return _waitState(name, 'Running', timeout, (l) => l.svcLabelStart);
  }

  /// 중지 후 실제로 Stopped 가 되는지 확인한다. 드라이버 연동/감시 프로세스가 있으면
  /// 중지되지 않거나 다시 살아날 수 있으므로 안정화 시간 뒤 한 번 더 확인한다.
  static Future<OpResult> stop(String name,
      {Duration timeout = const Duration(seconds: 15)}) async {
    final r = await Process.run('sc.exe', ['stop', name]);
    if (r.exitCode != 0 && r.exitCode != 1062) {
      // 1062: 이미 중지됨
      return OpResult(false, (l) => l.svcStopCmdFailed(r.exitCode, _firstLine(r.stdout)));
    }
    final first = await _waitState(name, 'Stopped', timeout, (l) => l.svcLabelStop);
    if (!first.ok) return first;
    await Future.delayed(const Duration(seconds: 3));
    final again = await query(name);
    if (again != null && again.running) {
      return OpResult(false, (l) => l.svcRestarted);
    }
    return OpResult(true, (l) => l.svcStopVerified);
  }

  static Future<OpResult> _waitState(
      String name, String target, Duration timeout, String Function(AppLocalizations) label) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      final s = await query(name);
      if (s == null) return OpResult(false, (l) => l.svcNotFound);
      if (s.state == target) return OpResult(true, (l) => l.svcStateVerified(label(l), target));
      await Future.delayed(const Duration(milliseconds: 700));
    }
    final s = await query(name);
    return OpResult(false, (l) => l.svcStateFailed(label(l), s?.state ?? l.svcStateUnknown));
  }

  static String _firstLine(Object? o) {
    final lines = '$o'.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty);
    return lines.isEmpty ? '' : lines.first.trim();
  }
}
