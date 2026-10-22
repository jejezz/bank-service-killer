// catalog/catalog.json 을 검사하고 서명해 catalog/catalog.json.sig 를 쓴다.
//
//   $env:CATALOG_SIGNING_KEY = '<keygen 이 낸 SECRET>'
//   dart run tool/catalog/sign.dart
//
// 카탈로그를 고칠 때마다 `version` 을 올리고(되돌리기 방지) 다시 서명한다.
import 'dart:convert';
import 'dart:io';

import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/catalog_lint.dart';
import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  final seedB64 = Platform.environment['CATALOG_SIGNING_KEY'];
  if (seedB64 == null || seedB64.trim().isEmpty) {
    stderr.writeln('CATALOG_SIGNING_KEY is not set (run tool/catalog/keygen.dart once).');
    exit(2);
  }
  final file = File('catalog/catalog.json');
  final bytes = await file.readAsBytes();
  final catalog = Catalog.fromJson(jsonDecode(utf8.decode(bytes)));
  final problems = lintCatalog(catalog);
  if (problems.isNotEmpty) {
    stderr.writeln('Catalog has problems:\n  ${problems.join('\n  ')}');
    exit(1);
  }
  final pair = await Ed25519().newKeyPairFromSeed(base64.decode(seedB64.trim()));
  final sig = await Ed25519().sign(bytes, keyPair: pair);
  await File('catalog/catalog.json.sig').writeAsString(base64.encode(sig.bytes));
  stdout.writeln('Signed catalog version ${catalog.version} (${catalog.products.length} products).');
}
