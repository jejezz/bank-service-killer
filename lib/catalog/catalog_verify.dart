import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// 카탈로그는 관리자 권한으로 서비스를 멈추는 근거라서, 서명이 맞지 않으면 쓰지 않는다.
/// 서명은 공개된 `catalog.json` 바이트 전체에 대한 Ed25519 분리 서명(base64)이다.
Future<bool> verifyCatalogSignature(
  List<int> catalogBytes,
  String signatureBase64,
  String publicKeyBase64,
) async {
  try {
    final sig = base64.decode(signatureBase64.trim());
    final pub = base64.decode(publicKeyBase64.trim());
    if (sig.length != 64 || pub.length != 32) return false;
    return await Ed25519().verify(
      catalogBytes,
      signature: Signature(sig, publicKey: SimplePublicKey(pub, type: KeyPairType.ed25519)),
    );
  } catch (_) {
    return false;
  }
}
