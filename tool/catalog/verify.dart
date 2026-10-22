// catalog/catalog.json 의 형식과 서명을 확인한다. 서명이 없거나 맞지 않으면 실패(종료 코드 1).
//
//   dart run tool/catalog/verify.dart
//
// 공개키는 catalog/public_key.txt 에서 읽는다. CI 가 카탈로그를 고친 PR 마다 이것을 돌린다.
import 'dart:convert';
import 'dart:io';

import 'package:bank_service_killer/catalog/catalog.dart';
import 'package:bank_service_killer/catalog/catalog_lint.dart';
import 'package:bank_service_killer/catalog/catalog_verify.dart';

Future<void> main() async {
  final bytes = await File('catalog/catalog.json').readAsBytes();
  final catalog = Catalog.fromJson(jsonDecode(utf8.decode(bytes)));
  final problems = lintCatalog(catalog);
  if (problems.isNotEmpty) {
    stderr.writeln('Catalog has problems:\n  ${problems.join('\n  ')}');
    exit(1);
  }
  final keyFile = File('catalog/public_key.txt');
  final sigFile = File('catalog/catalog.json.sig');
  if (!await keyFile.exists() || (await keyFile.readAsString()).trim().isEmpty) {
    stdout.writeln('No public key yet (catalog/public_key.txt) — format check only. Version ${catalog.version}.');
    return;
  }
  if (!await sigFile.exists()) {
    stderr.writeln('catalog/catalog.json.sig is missing — run tool/catalog/sign.dart.');
    exit(1);
  }
  final ok = await verifyCatalogSignature(bytes, await sigFile.readAsString(), await keyFile.readAsString());
  if (!ok) {
    stderr.writeln('Signature does not match catalog.json (edited after signing, or wrong key).');
    exit(1);
  }
  stdout.writeln('OK: catalog version ${catalog.version}, ${catalog.products.length} products, signature valid.');
}
