import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'catalog.dart';
import 'catalog_verify.dart';

/// 지금 쓰는 카탈로그가 어디서 왔는가.
enum CatalogSource {
  /// 앱에 들어 있는 기본 카탈로그 (서명 없이 앱과 함께 배포).
  bundled,

  /// 예전에 받아 둔, 서명이 확인된 카탈로그.
  cache,

  /// 이번 실행 중에 받아 서명을 확인한 카탈로그.
  remote,
}

/// 갱신을 시도한 결과.
enum CatalogRefresh { disabled, updated, upToDate, rejected, failed }

/// 마지막 갱신이 실패한 이유 (문구는 화면에서 언어에 맞게 만든다).
enum CatalogError { network, signature, format, rollback }

class FetchResult {
  const FetchResult(this.status, this.bytes, {this.etag});

  final int status;
  final List<int> bytes;
  final String? etag;
}

typedef Fetcher = Future<FetchResult> Function(Uri url, {String? etag});

const _maxCatalogBytes = 2 * 1024 * 1024;

/// https 로만 받고, 크기를 제한하고, 시간 제한을 둔다.
Future<FetchResult> httpsFetch(Uri url, {String? etag}) async {
  if (url.scheme != 'https') throw ArgumentError('catalog must be fetched over https');
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final req = await client.getUrl(url).timeout(const Duration(seconds: 15));
    if (etag != null) req.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
    final res = await req.close().timeout(const Duration(seconds: 20));
    final bytes = <int>[];
    await for (final chunk in res.timeout(const Duration(seconds: 20))) {
      bytes.addAll(chunk);
      if (bytes.length > _maxCatalogBytes) throw const FormatException('catalog too large');
    }
    return FetchResult(res.statusCode, bytes, etag: res.headers.value(HttpHeaders.etagHeader));
  } finally {
    client.close(force: true);
  }
}

/// 카탈로그를 들고 있고, 정해진 주기로 새 것을 받아 온다.
///
/// - 서명(Ed25519)이 맞지 않는 것은 받아도, 캐시에서 읽어도 쓰지 않는다. 공개키가 없으면 원격 갱신을 끈다.
/// - 버전이 낮거나 같은 카탈로그로는 바꾸지 않는다 (되돌리기·재생 방지).
/// - 새 카탈로그는 "제안"의 근거일 뿐 서비스를 자동으로 켜거나 끄지 않는다.
class CatalogController extends ChangeNotifier {
  CatalogController({
    required Catalog bundled,
    required this.cacheDir,
    required this.publicKey,
    required this.url,
    Fetcher fetcher = httpsFetch,
    DateTime Function() now = DateTime.now,
    this.interval = const Duration(hours: 24),
  })  : _catalog = bundled,
        _bundled = bundled,
        _fetcher = fetcher,
        _now = now;

  final Directory cacheDir;

  /// base64 Ed25519 공개키. 비면 원격 갱신과 캐시를 쓰지 않는다.
  final String publicKey;

  /// 카탈로그 주소(https). 서명은 같은 주소 뒤에 `.sig` 를 붙인 곳에 있다.
  final Uri? url;
  final Duration interval;
  final Fetcher _fetcher;
  final DateTime Function() _now;
  final Catalog _bundled;

  Catalog _catalog;
  CatalogSource _source = CatalogSource.bundled;
  DateTime? _checkedAt;
  String? _etag;
  CatalogError? _error;
  bool _checking = false;
  Timer? _first;
  Timer? _periodic;

  Catalog get catalog => _catalog;
  CatalogSource get source => _source;
  DateTime? get checkedAt => _checkedAt;
  CatalogError? get lastError => _error;
  bool get checking => _checking;
  bool get remoteEnabled => publicKey.isNotEmpty && url != null;

  File get _catalogFile => File('${cacheDir.path}${Platform.pathSeparator}catalog.json');
  File get _sigFile => File('${cacheDir.path}${Platform.pathSeparator}catalog.json.sig');
  File get _metaFile => File('${cacheDir.path}${Platform.pathSeparator}meta.json');

  /// 캐시에 받아 둔 카탈로그가 있고 서명이 맞고 더 새것이면 그것을 쓴다.
  Future<void> init() async {
    try {
      if (await _metaFile.exists()) {
        final meta = jsonDecode(await _metaFile.readAsString()) as Map<String, dynamic>;
        _etag = meta['etag'] as String?;
        final at = meta['checkedAt'] as String?;
        _checkedAt = at == null ? null : DateTime.tryParse(at);
      }
      if (publicKey.isEmpty || !await _catalogFile.exists() || !await _sigFile.exists()) return;
      final bytes = await _catalogFile.readAsBytes();
      // 캐시는 사용자 폴더라 다른 프로세스가 바꿀 수 있다. 읽을 때마다 서명을 다시 확인한다.
      if (!await verifyCatalogSignature(bytes, await _sigFile.readAsString(), publicKey)) return;
      final cached = Catalog.fromJson(jsonDecode(utf8.decode(bytes)));
      if (Catalog.shouldReplace(_bundled, cached)) {
        _catalog = cached;
        _source = CatalogSource.cache;
      }
    } catch (_) {
      // 캐시가 깨졌으면 기본 카탈로그로 간다.
    }
    notifyListeners();
  }

  Future<CatalogRefresh> refresh() async {
    final base = url;
    if (!remoteEnabled || base == null) return CatalogRefresh.disabled;
    if (_checking) return CatalogRefresh.upToDate;
    _checking = true;
    notifyListeners();
    try {
      final res = await _fetcher(base, etag: _source == CatalogSource.bundled ? null : _etag);
      if (res.status == 304) {
        await _markChecked();
        return CatalogRefresh.upToDate;
      }
      if (res.status != 200) return _fail(CatalogError.network);
      final sig = await _fetcher(Uri.parse('${base.toString()}.sig'));
      if (sig.status != 200) return _fail(CatalogError.network);
      if (!await verifyCatalogSignature(res.bytes, utf8.decode(sig.bytes, allowMalformed: true), publicKey)) {
        return _fail(CatalogError.signature, rejected: true);
      }
      final Catalog incoming;
      try {
        incoming = Catalog.fromJson(jsonDecode(utf8.decode(res.bytes)));
      } on FormatException {
        return _fail(CatalogError.format, rejected: true);
      }
      if (!Catalog.shouldReplace(_catalog, incoming)) {
        await _markChecked(etag: res.etag);
        // 같은 버전이면 정상이고, 더 낮은 버전이면 되돌리기 시도다.
        if (incoming.version < _catalog.version) {
          _error = CatalogError.rollback;
          return CatalogRefresh.rejected;
        }
        return CatalogRefresh.upToDate;
      }
      await _store(res.bytes, sig.bytes, res.etag);
      _catalog = incoming;
      _source = CatalogSource.remote;
      _error = null;
      _etag = res.etag;
      await _markChecked(etag: res.etag);
      return CatalogRefresh.updated;
    } catch (_) {
      return _fail(CatalogError.network);
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  CatalogRefresh _fail(CatalogError e, {bool rejected = false}) {
    _error = e;
    return rejected ? CatalogRefresh.rejected : CatalogRefresh.failed;
  }

  Future<void> _store(List<int> catalogBytes, List<int> sigBytes, String? etag) async {
    await cacheDir.create(recursive: true);
    // 임시 파일에 쓰고 바꿔치기해서 중간에 끊겨도 반쪽 파일이 남지 않게 한다.
    Future<void> atomic(File f, List<int> bytes) async {
      final tmp = File('${f.path}.tmp');
      await tmp.writeAsBytes(bytes, flush: true);
      await tmp.rename(f.path);
    }

    await atomic(_catalogFile, catalogBytes);
    await atomic(_sigFile, sigBytes);
  }

  Future<void> _markChecked({String? etag}) async {
    _checkedAt = _now();
    if (etag != null) _etag = etag;
    try {
      await cacheDir.create(recursive: true);
      await _metaFile.writeAsString(jsonEncode({
        'etag': _etag,
        'checkedAt': _checkedAt!.toIso8601String(),
      }));
    } catch (_) {}
  }

  bool get _due => _checkedAt == null || _now().difference(_checkedAt!) >= interval;

  /// 시작하고 잠시 뒤 한 번, 그 뒤로는 몇 시간마다 "갱신할 때가 됐나"를 보고 필요할 때만 받는다.
  void startAutoRefresh({Duration firstDelay = const Duration(seconds: 20)}) {
    if (!remoteEnabled) return;
    _first?.cancel();
    _periodic?.cancel();
    _first = Timer(firstDelay, () {
      if (_due) refresh();
    });
    _periodic = Timer.periodic(const Duration(hours: 6), (_) {
      if (_due) refresh();
    });
  }

  @override
  void dispose() {
    _first?.cancel();
    _periodic?.cancel();
    super.dispose();
  }
}
