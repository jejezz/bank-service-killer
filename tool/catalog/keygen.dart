// 카탈로그 서명용 Ed25519 키 쌍을 만든다.
//
//   dart run tool/catalog/keygen.dart
//
// - 공개키(PUBLIC)는 catalog/public_key.txt 에 넣고, 앱을 빌드할 때
//   --dart-define=CATALOG_PUBLIC_KEY=<공개키> 로 박는다.
// - 비밀 시드(SECRET)는 저장소에 넣지 않는다. 비밀번호 관리자에 두고, 카탈로그를 서명할 때만
//   환경 변수 CATALOG_SIGNING_KEY 로 넘긴다.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  final rnd = Random.secure();
  final seed = List<int>.generate(32, (_) => rnd.nextInt(256));
  final pair = await Ed25519().newKeyPairFromSeed(seed);
  final pub = await pair.extractPublicKey();
  stdout.writeln('PUBLIC (commit this): ${base64.encode(pub.bytes)}');
  stdout.writeln('SECRET (keep private, never commit): ${base64.encode(seed)}');
}
