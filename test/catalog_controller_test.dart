import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/catalog_controller.dart';
import 'package:bank_service_killer/catalog/catalog_verify.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

final _url = Uri.parse('https://example.test/catalog/catalog.json');

Map<String, dynamic> _json(int version, {String extraProduct = 'extra'}) => {
      'schema': 1,
      'version': version,
      'updated': '2026-01-0$version',
      'categories': {
        'web': {'en': 'Web plugin'},
      },
      'products': [
        {
          'id': extraProduct,
          'name': extraProduct,
          'categories': ['web'],
          'match': [
            {'service': extraProduct},
          ],
        },
      ],
    };

Uint8List _bytes(Map<String, dynamic> j) => Uint8List.fromList(utf8.encode(jsonEncode(j)));

class _Keys {
  _Keys(this.pair, this.publicB64);

  final SimpleKeyPair pair;
  final String publicB64;

  static Future<_Keys> create(int fill) async {
    final pair = await Ed25519().newKeyPairFromSeed(List.filled(32, fill));
    final pub = await pair.extractPublicKey();
    return _Keys(pair, base64.encode(pub.bytes));
  }

  Future<List<int>> sign(List<int> bytes) async => (await Ed25519().sign(bytes, keyPair: pair)).bytes;
}

/// 주소별로 정해 둔 응답을 주는 가짜 가져오기. 요청을 기록한다.
class _FakeNet {
  final responses = <String, FetchResult>{};
  final requests = <String>[];
  final etags = <String?>[];
  Object? failWith;

  Future<FetchResult> call(Uri url, {String? etag}) async {
    requests.add(url.toString());
    etags.add(etag);
    if (failWith != null) throw failWith!;
    return responses[url.toString()] ?? const FetchResult(404, []);
  }

  Future<void> publish(_Keys keys, Map<String, dynamic> catalog, {String? etag}) async {
    final bytes = _bytes(catalog);
    responses[_url.toString()] = FetchResult(200, bytes, etag: etag);
    responses['$_url.sig'] = FetchResult(200, utf8.encode(base64.encode(await keys.sign(bytes))));
  }
}

void main() {
  late Directory dir;
  late _Keys keys;
  late _FakeNet net;
  late Catalog bundled;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('bsk_catalog_test');
    keys = await _Keys.create(7);
    net = _FakeNet();
    bundled = Catalog.fromJson(_json(1, extraProduct: 'bundled'));
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  CatalogController make({String? publicKey, Uri? url, DateTime Function()? now}) => CatalogController(
        bundled: bundled,
        cacheDir: dir,
        publicKey: publicKey ?? keys.publicB64,
        url: url ?? _url,
        fetcher: net.call,
        now: now ?? DateTime.now,
      );

  group('서명 확인', () {
    test('맞는 서명은 통과하고, 내용이 바뀌었거나 다른 키면 실패한다', () async {
      final bytes = _bytes(_json(1));
      final sig = base64.encode(await keys.sign(bytes));
      expect(await verifyCatalogSignature(bytes, sig, keys.publicB64), isTrue);

      final tampered = Uint8List.fromList([...bytes]..[5] ^= 1);
      expect(await verifyCatalogSignature(tampered, sig, keys.publicB64), isFalse);

      final other = await _Keys.create(9);
      expect(await verifyCatalogSignature(bytes, sig, other.publicB64), isFalse);
    });

    test('깨진 입력은 예외 없이 실패한다', () async {
      final bytes = _bytes(_json(1));
      expect(await verifyCatalogSignature(bytes, 'not base64!!', keys.publicB64), isFalse);
      expect(await verifyCatalogSignature(bytes, base64.encode([1, 2, 3]), keys.publicB64), isFalse);
      expect(await verifyCatalogSignature(bytes, '', ''), isFalse);
    });
  });

  group('refresh', () {
    test('공개키가 없으면 원격 갱신을 하지 않는다', () async {
      final c = make(publicKey: '');
      expect(c.remoteEnabled, isFalse);
      expect(await c.refresh(), CatalogRefresh.disabled);
      expect(net.requests, isEmpty);
      expect(c.source, CatalogSource.bundled);
    });

    test('서명이 맞고 버전이 더 높으면 바꾸고 캐시에 쓴다', () async {
      await net.publish(keys, _json(2, extraProduct: 'remote'), etag: '"v2"');
      final c = make();
      await c.init();
      expect(await c.refresh(), CatalogRefresh.updated);
      expect(c.catalog.version, 2);
      expect(c.catalog.products.single.id, 'remote');
      expect(c.source, CatalogSource.remote);
      expect(c.lastError, isNull);
      expect(await File('${dir.path}${Platform.pathSeparator}catalog.json').exists(), isTrue);
      expect(await File('${dir.path}${Platform.pathSeparator}catalog.json.sig').exists(), isTrue);
    });

    test('서명이 틀리면 버리고 오류를 남기며 기존 카탈로그를 유지한다', () async {
      final bytes = _bytes(_json(5, extraProduct: 'evil'));
      net.responses[_url.toString()] = FetchResult(200, bytes);
      net.responses['$_url.sig'] = FetchResult(200, utf8.encode(base64.encode(List.filled(64, 1))));
      final c = make();
      await c.init();
      expect(await c.refresh(), CatalogRefresh.rejected);
      expect(c.lastError, CatalogError.signature);
      expect(c.catalog.version, 1);
      expect(c.source, CatalogSource.bundled);
    });

    test('다른 키로 서명한 것(공개키가 다른 서버)도 버린다', () async {
      final attacker = await _Keys.create(42);
      await net.publish(attacker, _json(9, extraProduct: 'evil'));
      final c = make();
      expect(await c.refresh(), CatalogRefresh.rejected);
      expect(c.catalog.version, 1);
    });

    test('버전이 낮으면 되돌리기로 보고 거절한다', () async {
      await net.publish(keys, _json(3, extraProduct: 'v3'));
      final c = make();
      await c.refresh();
      expect(c.catalog.version, 3);

      await net.publish(keys, _json(2, extraProduct: 'old'));
      expect(await c.refresh(), CatalogRefresh.rejected);
      expect(c.lastError, CatalogError.rollback);
      expect(c.catalog.version, 3);
    });

    test('같은 버전이면 그대로 둔다', () async {
      await net.publish(keys, _json(3));
      final c = make();
      await c.refresh();
      expect(await c.refresh(), CatalogRefresh.upToDate);
      expect(c.catalog.version, 3);
    });

    test('형식이 틀린 카탈로그는 서명이 맞아도 버린다', () async {
      final bad = <String, dynamic>{'schema': 99, 'version': 5};
      await net.publish(keys, bad);
      final c = make();
      expect(await c.refresh(), CatalogRefresh.rejected);
      expect(c.lastError, CatalogError.format);
      expect(c.catalog.version, 1);
    });

    test('네트워크 오류·404 는 실패로 남기고 기존 것을 유지한다', () async {
      final c = make();
      net.failWith = const SocketException('offline');
      expect(await c.refresh(), CatalogRefresh.failed);
      expect(c.lastError, CatalogError.network);
      net.failWith = null;
      expect(await c.refresh(), CatalogRefresh.failed); // 404
      expect(c.catalog.version, 1);
    });

    test('받아 둔 뒤에는 ETag 로 물어보고 304 면 확인 시각만 갱신한다', () async {
      await net.publish(keys, _json(2), etag: '"abc"');
      var t = DateTime(2026, 1, 1, 9);
      final c = make(now: () => t);
      await c.refresh();
      expect(net.etags.first, isNull);

      t = DateTime(2026, 1, 2, 9);
      net.responses[_url.toString()] = const FetchResult(304, []);
      expect(await c.refresh(), CatalogRefresh.upToDate);
      expect(net.etags, contains('"abc"'));
      expect(c.checkedAt, DateTime(2026, 1, 2, 9));
    });

    test('http 주소는 가져오지 않는다 (https 만)', () async {
      await expectLater(httpsFetch(Uri.parse('http://example.test/c.json')), throwsArgumentError);
    });
  });

  group('init (캐시)', () {
    test('서명이 맞는 캐시는 기본 카탈로그보다 새것이면 쓴다', () async {
      await net.publish(keys, _json(4, extraProduct: 'cached'));
      await make().refresh();

      final again = make();
      await again.init();
      expect(again.source, CatalogSource.cache);
      expect(again.catalog.version, 4);
    });

    test('캐시 파일을 몰래 바꾸면 서명이 안 맞아 기본 카탈로그로 돌아간다', () async {
      await net.publish(keys, _json(4, extraProduct: 'cached'));
      await make().refresh();

      final f = File('${dir.path}${Platform.pathSeparator}catalog.json');
      await f.writeAsString(jsonEncode(_json(99, extraProduct: 'planted')));

      final again = make();
      await again.init();
      expect(again.source, CatalogSource.bundled);
      expect(again.catalog.version, 1);
    });

    test('공개키가 없으면 캐시를 읽지 않는다', () async {
      await net.publish(keys, _json(4));
      await make().refresh();
      final again = make(publicKey: '');
      await again.init();
      expect(again.source, CatalogSource.bundled);
    });

    test('캐시가 기본 카탈로그보다 오래됐으면 기본을 쓴다', () async {
      await net.publish(keys, _json(4));
      await make().refresh();
      bundled = Catalog.fromJson(_json(10, extraProduct: 'newerBundled'));
      final again = make();
      await again.init();
      expect(again.source, CatalogSource.bundled);
      expect(again.catalog.version, 10);
    });
  });
}
