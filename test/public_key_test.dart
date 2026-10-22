import 'dart:convert';
import 'dart:io';

import 'package:bank_service_killer/catalog/public_key.dart';
import 'package:flutter_test/flutter_test.dart';

final _good = base64.encode(List.filled(32, 7));
final _other = base64.encode(List.filled(32, 9));

void main() {
  group('isValidPublicKey', () {
    test('32바이트 base64 만 통과한다', () {
      expect(isValidPublicKey(_good), isTrue);
      expect(isValidPublicKey('  $_good\n'), isTrue);
      expect(isValidPublicKey(base64.encode(List.filled(31, 1))), isFalse);
      expect(isValidPublicKey(base64.encode(List.filled(64, 1))), isFalse);
      expect(isValidPublicKey('not base64!!'), isFalse);
      expect(isValidPublicKey(''), isFalse);
    });
  });

  group('resolveCatalogPublicKey', () {
    test('빌드 때 준 값이 있으면 파일보다 우선한다', () async {
      final k = await resolveCatalogPublicKey(defined: _good, readAsset: () async => _other);
      expect(k, _good);
    });

    test('준 값이 없으면 앱에 들어 있는 파일을 읽는다 (앞뒤 공백·줄바꿈은 무시)', () async {
      final k = await resolveCatalogPublicKey(defined: '', readAsset: () async => '$_other\r\n');
      expect(k, _other);
    });

    test('둘 다 없거나 형식이 틀리면 빈 값(원격 갱신 끔)이다', () async {
      expect(await resolveCatalogPublicKey(defined: '', readAsset: () async => ''), '');
      expect(await resolveCatalogPublicKey(defined: '', readAsset: () async => 'garbage'), '');
      expect(await resolveCatalogPublicKey(defined: '', readAsset: () async => throw Exception('missing')), '');
      expect(await resolveCatalogPublicKey(defined: 'garbage', readAsset: () async => _good), '',
          reason: '잘못 준 값을 파일로 덮어쓰지 않는다');
    });
  });

  test('저장소의 catalog/public_key.txt 는 공개키 형식(32바이트 base64)이다', () {
    // 잘못 붙여 넣은 값(잘린 키, 줄바꿈이 섞인 값)을 커밋 전에 잡는다.
    final text = File('catalog/public_key.txt').readAsStringSync();
    expect(isValidPublicKey(text), isTrue);
    expect(text.trim().contains(RegExp(r'\s')), isFalse, reason: '키 안에 공백·줄바꿈이 없어야 한다');
  });
}
